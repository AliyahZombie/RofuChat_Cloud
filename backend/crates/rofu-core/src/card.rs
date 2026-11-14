use crate::model::{normalized, text};
use anyhow::{bail, Context, Result};
use base64::{engine::general_purpose::STANDARD, Engine};
use serde_json::{json, Value};
use std::io::Cursor;

const FIELDS: &[&str] = &[
    "name",
    "description",
    "personality",
    "scenario",
    "first_mes",
    "mes_example",
    "creator_notes",
    "system_prompt",
    "post_history_instructions",
    "alternate_greetings",
    "character_book",
    "tags",
    "creator",
    "character_version",
    "extensions",
];
pub fn parse_card(input: &Value) -> Value {
    let v = if input["data"].is_object() {
        &input["data"]
    } else {
        input
    };
    let mut card = json!({"name":"","description":"","personality":"","scenario":"","first_mes":"","mes_example":"","creator_notes":"","system_prompt":"","post_history_instructions":"","alternate_greetings":[],"character_book":null,"tags":[],"creator":"","character_version":"","extensions":{}});
    for field in FIELDS {
        if let Some(x) = v.get(*field) {
            card[*field] = x.clone();
        }
    }
    for (old, new) in [
        ("char_name", "name"),
        ("char_persona", "description"),
        ("world_scenario", "scenario"),
        ("char_greeting", "first_mes"),
        ("example_dialogue", "mes_example"),
    ] {
        if text(&card, new).is_empty() {
            if let Some(x) = v.get(old) {
                card[new] = x.clone();
            }
        }
    }
    if !card["extensions"].is_object() {
        card["extensions"] = json!({});
    }
    if input["spec"] == "chara_card_v3" {
        if let Some(obj) = v.as_object() {
            for (k, val) in obj {
                if !FIELDS.contains(&k.as_str()) {
                    card["extensions"][k] = val.clone();
                }
            }
        }
    }
    card
}
pub fn import(body: &Value) -> Result<Value> {
    let (raw, avatar) = if let Some(png) = body["png_base64"].as_str() {
        let data = STANDARD.decode(png.split_once(',').map(|(_, s)| s).unwrap_or(png))?;
        (
            png_card(&data)?,
            format!("data:image/png;base64,{}", STANDARD.encode(data)),
        )
    } else {
        (
            body.get("json")
                .cloned()
                .context("json or png_base64 is required")?,
            String::new(),
        )
    };
    let card = parse_card(&raw);
    Ok(normalized(
        "character",
        &json!({"name":card["name"],"card":card,"avatar":avatar}),
    ))
}
pub fn export_json(character: &Value) -> Value {
    json!({"spec":"chara_card_v2","spec_version":"2.0","data":parse_card(&character["card"])})
}
pub fn avatar(character: &Value) -> Result<(Vec<u8>, String)> {
    let data = text(character, "avatar");
    let (meta, b64) = data.split_once(',').context("avatar is not a data URL")?;
    let mime = meta
        .strip_prefix("data:")
        .and_then(|m| m.strip_suffix(";base64"))
        .context("avatar is not base64 encoded")?;
    Ok((STANDARD.decode(b64)?, mime.to_owned()))
}
pub fn export_png(character: &Value) -> Result<Vec<u8>> {
    let source = avatar(character)
        .ok()
        .filter(|(_, mime)| mime == "image/png")
        .map(|(b, _)| b);
    let data = if let Some(data) = source {
        data
    } else {
        let mut b = vec![];
        {
            let mut enc = png::Encoder::new(&mut b, 1, 1);
            enc.set_color(png::ColorType::Rgba);
            enc.set_depth(png::BitDepth::Eight);
            enc.write_header()?.write_image_data(&[84, 68, 100, 255])?;
        }
        b
    };
    let mut reader = png::Decoder::new(Cursor::new(&data)).read_info()?;
    let mut pixels = vec![0; reader.output_buffer_size()];
    let output = reader.next_frame(&mut pixels)?;
    let mut out = vec![];
    {
        let mut enc = png::Encoder::new(&mut out, output.width, output.height);
        enc.set_color(output.color_type);
        enc.set_depth(output.bit_depth);
        if let Some(palette) = &reader.info().palette {
            enc.set_palette(palette.to_vec());
        }
        if let Some(trns) = &reader.info().trns {
            enc.set_trns(trns.to_vec());
        }
        enc.add_text_chunk(
            "chara".into(),
            STANDARD.encode(export_json(character).to_string()),
        )?;
        enc.write_header()?
            .write_image_data(&pixels[..output.buffer_size()])?;
    }
    Ok(out)
}
pub fn png_card(bytes: &[u8]) -> Result<Value> {
    let mut reader = png::Decoder::new(Cursor::new(bytes)).read_info()?;
    let mut pixels = vec![0; reader.output_buffer_size()];
    reader.next_frame(&mut pixels)?;
    // Read chunks after IDAT too.
    reader.finish()?;
    for keyword in ["ccv3", "chara"] {
        for chunk in &reader.info().utf8_text {
            if chunk.keyword == keyword {
                if let Ok(v) = decode_card(&chunk.get_text()?) {
                    return Ok(v);
                }
            }
        }
        for chunk in &reader.info().uncompressed_latin1_text {
            if chunk.keyword == keyword {
                if let Ok(v) = decode_card(&chunk.text) {
                    return Ok(v);
                }
            }
        }
    }
    bail!("PNG contains no valid ccv3/chara card")
}
fn decode_card(v: &str) -> Result<Value> {
    Ok(serde_json::from_slice(&STANDARD.decode(v.trim())?)?)
}
pub fn macros(input: &str, char_name: &str, user_name: &str) -> String {
    let patterns = [
        ("{{char}}", char_name),
        ("{{user}}", user_name),
        ("<bot>", char_name),
        ("<user>", user_name),
    ];
    let mut out = String::new();
    let mut pos = 0;
    while pos < input.len() {
        let rest = &input[pos..];
        if let Some((pat, value)) = patterns.iter().find(|(pat, _)| {
            rest.get(..pat.len())
                .is_some_and(|s| s.eq_ignore_ascii_case(pat))
        }) {
            out.push_str(value);
            pos += pat.len();
        } else {
            let ch = rest.chars().next().unwrap();
            out.push(ch);
            pos += ch.len_utf8();
        }
    }
    out
}
pub fn worldbook(card: &Value, messages: &[Value]) -> Vec<String> {
    let recent = messages
        .iter()
        .rev()
        .filter(|m| m["visible"] != false)
        .take(6)
        .map(|m| text(m, "content"))
        .collect::<Vec<_>>()
        .join("\n")
        .to_lowercase();
    let mut entries: Vec<&Value> = card["character_book"]["entries"]
        .as_array()
        .map(|a| {
            a.iter()
                .filter(|e| {
                    e["enabled"] != false
                        && (e["constant"] == true
                            || e["keys"].as_array().is_some_and(|keys| {
                                keys.iter().any(|k| {
                                    k.as_str()
                                        .is_some_and(|key| recent.contains(&key.to_lowercase()))
                                })
                            }))
                })
                .collect()
        })
        .unwrap_or_default();
    entries.sort_by_key(|e| e["insertion_order"].as_i64().unwrap_or(0));
    entries.into_iter().map(|e| text(e, "content")).collect()
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn versions_and_png() {
        for v in [
            json!({"char_name":"Rofu","char_persona":"kind"}),
            json!({"spec":"chara_card_v2","data":{"name":"Rofu","description":"kind"}}),
            json!({"spec":"chara_card_v3","data":{"name":"Rofu","description":"kind","assets":[]}}),
        ] {
            let c = import(&json!({"json":v})).unwrap();
            assert_eq!(c["name"], "Rofu");
            assert_eq!(c["card"]["description"], "kind");
            let png = export_png(&c).unwrap();
            let decoded = import(&json!({"png_base64":STANDARD.encode(png)})).unwrap();
            assert_eq!(export_json(&c), export_json(&decoded));
        }
    }
    #[test]
    fn macro_and_worldbook() {
        assert_eq!(
            macros("{{CHAR}} <USER> <BoT> {{user}}", "露芙", "Me"),
            "露芙 Me 露芙 Me"
        );
        let c = json!({"character_book":{"entries":[{"constant":true,"content":"a","insertion_order":2},{"keys":["Forest"],"content":"b","insertion_order":1},{"constant":true,"enabled":false,"content":"c"}]}});
        assert_eq!(
            worldbook(&c, &[json!({"content":"FOREST","visible":true})]),
            vec!["b", "a"]
        );
    }
}
