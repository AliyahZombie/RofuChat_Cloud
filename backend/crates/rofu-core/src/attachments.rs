//! Immutable, owner-scoped image blobs. JSON contains metadata only.
use crate::db::Db;
use anyhow::{bail, Context, Result};
use base64::{engine::general_purpose::STANDARD, Engine};
use serde_json::{json, Value};
use sha2::{Digest, Sha256};
use sqlx::Row;

impl Db {
    pub async fn put_attachment(&self, uid: &str, url: &str) -> Result<Value> {
        let prepared = prepare_attachment(uid, url)?;
        let reference = prepared.reference;
        let id = reference["id"].as_str().unwrap();
        let mime = reference["mime"].as_str().unwrap();
        let bytes = prepared.bytes;
        sqlx::query("INSERT INTO attachments(id,user_id,mime,data,metadata) VALUES ($1,$2,$3,$4,$5) ON CONFLICT(id) DO NOTHING")
            .bind(id).bind(uid).bind(mime).bind(bytes).bind(reference.to_string()).execute(&self.pool).await?;
        Ok(reference)
    }

    pub async fn attachment(&self, uid: &str, id: &str) -> Result<Option<(Vec<u8>, String)>> {
        let row = sqlx::query("SELECT data,mime FROM attachments WHERE user_id=$1 AND id=$2")
            .bind(uid)
            .bind(id)
            .fetch_optional(&self.pool)
            .await?;
        row.map(|r| Ok((r.try_get("data")?, r.try_get("mime")?)))
            .transpose()
    }

    async fn attachment_reference(&self, uid: &str, id: &str) -> Result<Value> {
        let metadata: Option<String> =
            sqlx::query_scalar("SELECT metadata FROM attachments WHERE user_id=$1 AND id=$2")
                .bind(uid)
                .bind(id)
                .fetch_optional(&self.pool)
                .await?;
        Ok(serde_json::from_str(
            &metadata.context("image attachment not found")?,
        )?)
    }

    /// Also visits inactive swipes and archived tails so switching never revives inline bytes.
    pub fn externalize_images<'a>(
        &'a self,
        uid: &'a str,
        value: &'a mut Value,
    ) -> std::pin::Pin<Box<dyn std::future::Future<Output = Result<()>> + Send + 'a>> {
        Box::pin(async move {
            match value {
                Value::Object(object) => {
                    if let Some(images) = object.get_mut("images").and_then(Value::as_array_mut) {
                        for image in images {
                            if let Some(url) = image.as_str().filter(|s| s.starts_with("data:")) {
                                *image = self.put_attachment(uid, url).await?;
                            } else if let Some(id) = image.get("id").and_then(Value::as_str) {
                                *image = self.attachment_reference(uid, id).await?;
                            } else if !image.is_string() {
                                bail!("image must be a data URL, URL or attachment reference");
                            }
                        }
                    }
                    if let Some(url) = object
                        .get("avatar")
                        .and_then(Value::as_str)
                        .filter(|s| s.starts_with("data:"))
                    {
                        let reference = self.put_attachment(uid, url).await?;
                        object.insert(
                            "avatar".into(),
                            json!(format!(
                                "/api/attachments/{}",
                                reference["id"].as_str().unwrap()
                            )),
                        );
                        object.insert("avatar_attachment".into(), reference);
                    }
                    // Visit only the message/snapshot containers. Arbitrary card/tool
                    // extension JSON may have unrelated fields named images or avatar.
                    for key in ["parts", "swipes", "tail"] {
                        if let Some(child) = object.get_mut(key) {
                            self.externalize_images(uid, child).await?;
                        }
                    }
                }
                Value::Array(array) => {
                    for child in array {
                        self.externalize_images(uid, child).await?;
                    }
                }
                _ => {}
            }
            Ok(())
        })
    }

    pub async fn resolve_image(&self, uid: &str, image: &Value) -> Result<Value> {
        let id = image.get("id").and_then(Value::as_str).or_else(|| {
            image
                .as_str()
                .and_then(|s| s.strip_prefix("/api/attachments/"))
        });
        if let Some(id) = id {
            let (bytes, mime) = self
                .attachment(uid, id)
                .await?
                .context("image attachment not found")?;
            Ok(json!(format!(
                "data:{mime};base64,{}",
                STANDARD.encode(bytes)
            )))
        } else {
            Ok(image.clone())
        }
    }

    /// Only call on the already-selected provider context (never on API history).
    pub async fn resolve_provider_images(&self, uid: &str, messages: &mut [Value]) -> Result<()> {
        for message in messages {
            if let Some(images) = message["images"].as_array_mut() {
                for image in images {
                    *image = self.resolve_image(uid, image).await?;
                }
            }
        }
        Ok(())
    }
}

/// A blob prepared without writes, so plugin rollback and beforeSend cancellation
/// also leave the attachment store untouched.
#[derive(Clone)]
pub struct PreparedAttachment {
    pub reference: Value,
    pub bytes: Vec<u8>,
}
fn prepare_attachment(uid: &str, url: &str) -> Result<PreparedAttachment> {
    let (meta, payload) = url.split_once(',').context("invalid image data URL")?;
    let mime = meta
        .strip_prefix("data:")
        .and_then(|m| m.strip_suffix(";base64"))
        .filter(|m| {
            matches!(
                *m,
                "image/png"
                    | "image/jpeg"
                    | "image/gif"
                    | "image/webp"
                    | "image/avif"
                    | "image/bmp"
            )
        })
        .context("unsupported image MIME type")?;
    let bytes = STANDARD.decode(payload).context("invalid image base64")?;
    if bytes.len() > 24 * 1024 * 1024 {
        bail!("image exceeds 24MB");
    }
    let mut hash = Sha256::new();
    hash.update(uid.as_bytes());
    hash.update([0]);
    hash.update(mime.as_bytes());
    hash.update([0]);
    hash.update(&bytes);
    let id = format!("{:x}", hash.finalize());
    let mut reference = json!({"id":id,"mime":mime,"bytes":bytes.len()});
    if bytes.starts_with(b"\x89PNG\r\n\x1a\n") && bytes.len() >= 24 {
        reference["width"] = json!(u32::from_be_bytes(bytes[16..20].try_into()?));
        reference["height"] = json!(u32::from_be_bytes(bytes[20..24].try_into()?));
    }
    Ok(PreparedAttachment { reference, bytes })
}
impl Db {
    pub fn stage_images<'a>(
        &'a self,
        uid: &'a str,
        value: &'a mut Value,
        blobs: &'a mut Vec<PreparedAttachment>,
    ) -> std::pin::Pin<Box<dyn std::future::Future<Output = Result<()>> + Send + 'a>> {
        Box::pin(async move {
            match value {
                Value::Object(object) => {
                    if let Some(images) = object.get_mut("images") {
                        let images = images.as_array_mut().context("images must be array")?;
                        for image in images {
                            if let Some(url) = image.as_str().filter(|s| s.starts_with("data:")) {
                                let blob = prepare_attachment(uid, url)?;
                                *image = blob.reference.clone();
                                blobs.push(blob);
                            } else if let Some(id) = image.get("id").and_then(Value::as_str) {
                                *image = self.attachment_reference(uid, id).await?;
                            } else if !image.is_string() {
                                bail!("image must be a data URL, URL or attachment reference");
                            }
                        }
                    }
                    for key in ["parts", "swipes", "tail"] {
                        if let Some(child) = object.get_mut(key) {
                            self.stage_images(uid, child, blobs).await?;
                        }
                    }
                }
                Value::Array(a) => {
                    for child in a {
                        self.stage_images(uid, child, blobs).await?;
                    }
                }
                _ => {}
            }
            Ok(())
        })
    }
}
pub async fn store_prepared(
    tx: &mut sqlx::Transaction<'_, sqlx::Any>,
    uid: &str,
    blobs: &[PreparedAttachment],
) -> Result<()> {
    for blob in blobs {
        sqlx::query("INSERT INTO attachments(id,user_id,mime,data,metadata) VALUES ($1,$2,$3,$4,$5) ON CONFLICT(id) DO NOTHING").bind(blob.reference["id"].as_str().unwrap()).bind(uid).bind(blob.reference["mime"].as_str().unwrap()).bind(&blob.bytes).bind(blob.reference.to_string()).execute(&mut **tx).await?;
    }
    Ok(())
}
