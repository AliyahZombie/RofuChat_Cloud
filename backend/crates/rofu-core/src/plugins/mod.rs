//! Plugin packages. Metadata is never discovered by executing untrusted code.
pub mod hooks;
pub mod host;
pub mod routes;
pub mod runtime;
pub mod storage;

use crate::model::text;
use anyhow::{bail, ensure, Result};
use serde_json::{json, Value};

pub const HOOK_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(2);
pub const INVOCATION_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(10);
pub const MAX_FOLLOW_UPS: usize = 2;
pub const MEMORY_LIMIT: usize = 64 * 1024 * 1024;
pub const STACK_LIMIT: usize = 1024 * 1024;

pub fn defaults() -> Value {
    json!({"name":"","version":"1","description":"","code":"","enabled":false,"models":[],"format":"module-v1",
        "manifest":{"api_version":1,"permissions":[],"tools":[],"hooks":{},"menus":[]},"granted_permissions":[]})
}
pub fn validate(plugin: &Value) -> Result<()> {
    ensure!(plugin.is_object(), "E_VALIDATION: expected plugin object");
    ensure!(
        plugin["code"].is_string() && plugin["name"].is_string(),
        "E_VALIDATION: code and name must be strings"
    );
    ensure!(
        text(plugin, "code").len() <= 1024 * 1024,
        "E_LIMIT: code exceeds 1 MiB"
    );
    ensure!(
        plugin["format"] == "module-v1",
        "E_VALIDATION: unknown format"
    );
    ensure!(
        plugin["enabled"].is_boolean()
            && plugin["version"].is_string()
            && plugin["description"].is_string()
            && plugin["models"]
                .as_array()
                .is_some_and(|a| a.iter().all(Value::is_string)),
        "E_VALIDATION: invalid plugin metadata"
    );
    let m = &plugin["manifest"];
    ensure!(m["api_version"] == 1, "E_VALIDATION: api_version must be 1");
    let permissions = m["permissions"]
        .as_array()
        .ok_or_else(|| anyhow::anyhow!("E_VALIDATION: permissions must be an array"))?;
    for p in permissions {
        let name = p
            .as_str()
            .unwrap_or_else(|| p["name"].as_str().unwrap_or(""));
        ensure!(
            matches!(
                name,
                "read" | "write" | "storage" | "hooks" | "send" | "ui" | "network"
            ),
            "E_VALIDATION: unknown permission {name}"
        );
        if p.is_object() {
            ensure!(
                name == "network" && p["origins"].as_array().is_some(),
                "E_VALIDATION: only network supports options"
            );
            for origin in p["origins"].as_array().unwrap() {
                let u = url::Url::parse(origin.as_str().unwrap_or(""))?;
                ensure!(
                    matches!(u.scheme(), "http" | "https")
                        && u.origin().ascii_serialization() == origin.as_str().unwrap_or(""),
                    "E_VALIDATION: expected HTTP origin"
                );
            }
        }
    }
    for (field, limit) in [("tools", 32), ("menus", 16)] {
        let items = m[field]
            .as_array()
            .ok_or_else(|| anyhow::anyhow!("E_VALIDATION: {field} must be an array"))?;
        ensure!(items.len() <= limit, "E_LIMIT: too many {field}");
        let mut ids = std::collections::HashSet::new();
        for item in items {
            let tid = text(item, "id");
            ensure!(
                !tid.is_empty()
                    && tid.len() <= 20
                    && tid.bytes().all(|b| b.is_ascii_alphanumeric() || b == b'_')
                    && ids.insert(tid),
                "E_VALIDATION: invalid or duplicate {field} id"
            );
            ensure!(
                !text(item, "handler").is_empty(),
                "E_VALIDATION: missing handler"
            );
            ensure!(
                item[if field == "tools" { "name" } else { "label" }].is_string(),
                "E_VALIDATION: missing label/name"
            );
            if field == "tools" {
                validate_schema(&item["parameters"])?;
            }
        }
    }
    let hooks = m["hooks"]
        .as_object()
        .ok_or_else(|| anyhow::anyhow!("E_VALIDATION: hooks must be an object"))?;
    for (name, handler) in hooks {
        ensure!(
            matches!(
                name.as_str(),
                "beforeSend" | "beforeToolCall" | "afterToolCall" | "afterReply"
            ) && handler.as_str().is_some_and(|s| !s.is_empty()),
            "E_VALIDATION: invalid hook"
        );
    }
    Ok(())
}
fn validate_schema(v: &Value) -> Result<()> {
    let o = v
        .as_object()
        .ok_or_else(|| anyhow::anyhow!("E_VALIDATION: expected JSON schema object"))?;
    for (k, value) in o {
        match k.as_str() {
            "type" => ensure!(
                matches!(
                    value.as_str(),
                    Some("object" | "array" | "string" | "number" | "integer" | "boolean" | "null")
                ),
                "E_VALIDATION: invalid schema type"
            ),
            "properties" => {
                for s in value
                    .as_object()
                    .ok_or_else(|| anyhow::anyhow!("E_VALIDATION: properties must be object"))?
                    .values()
                {
                    validate_schema(s)?;
                }
            }
            "items" => validate_schema(value)?,
            "required" => ensure!(
                value
                    .as_array()
                    .is_some_and(|a| a.iter().all(Value::is_string)),
                "E_VALIDATION: required must be strings"
            ),
            "enum" => ensure!(value.is_array(), "E_VALIDATION: enum must be array"),
            "additionalProperties" => ensure!(
                value.is_boolean(),
                "E_VALIDATION: additionalProperties must be boolean"
            ),
            "minimum" | "maximum" => {
                ensure!(value.is_number(), "E_VALIDATION: bound must be numeric")
            }
            "minLength" | "maxLength" | "minItems" | "maxItems" => ensure!(
                value.as_u64().is_some(),
                "E_VALIDATION: bound must be unsigned integer"
            ),
            "description" | "title" => ensure!(
                value.is_string(),
                "E_VALIDATION: description must be string"
            ),
            _ => bail!("E_VALIDATION: unsupported schema keyword {k}"),
        }
    }
    Ok(())
}
pub fn validate_args(schema: &Value, v: &Value) -> Result<()> {
    let valid = match schema["type"].as_str() {
        Some("object") => v.is_object(),
        Some("array") => v.is_array(),
        Some("string") => v.is_string(),
        Some("number") => v.is_number(),
        Some("integer") => v.as_i64().is_some() || v.as_u64().is_some(),
        Some("boolean") => v.is_boolean(),
        Some("null") => v.is_null(),
        _ => true,
    };
    ensure!(valid, "E_VALIDATION: tool argument type mismatch");
    if let Some(a) = schema["enum"].as_array() {
        ensure!(a.contains(v), "E_VALIDATION: argument not in enum");
    }
    if let Some(o) = v.as_object() {
        if let Some(required) = schema["required"].as_array() {
            for k in required {
                ensure!(
                    o.contains_key(k.as_str().unwrap_or("")),
                    "E_VALIDATION: missing required argument"
                );
            }
        }
        for (k, value) in o {
            if let Some(s) = schema["properties"].get(k) {
                validate_args(s, value)?;
            } else {
                ensure!(
                    schema["additionalProperties"] != false,
                    "E_VALIDATION: unexpected argument {k}"
                );
            }
        }
    }
    if let Some(a) = v.as_array() {
        for value in a {
            if !schema["items"].is_null() {
                validate_args(&schema["items"], value)?;
            }
        }
    }
    for (low, high, n) in [
        (
            "minLength",
            "maxLength",
            v.as_str().map(|s| s.chars().count() as f64),
        ),
        ("minItems", "maxItems", v.as_array().map(|a| a.len() as f64)),
        ("minimum", "maximum", v.as_f64()),
    ] {
        if let Some(n) = n {
            ensure!(
                schema[low].as_f64().is_none_or(|x| n >= x)
                    && schema[high].as_f64().is_none_or(|x| n <= x),
                "E_VALIDATION: argument outside bounds"
            );
        }
    }
    Ok(())
}

/// Installed once, in the same transaction that creates its owner.
pub async fn install_dice(tx: &mut sqlx::Transaction<'_, sqlx::Any>, uid: &str) -> Result<()> {
    let mut plugin = defaults();
    plugin["id"] = json!(crate::model::id());
    plugin["name"] = json!("骰子 / Dice");
    plugin["description"] = json!("D&D / TRPG dice roller");
    plugin["enabled"] = json!(true);
    plugin["code"] = json!(include_str!("dice.js"));
    plugin["manifest"]["tools"] = json!([{
        "id":"roll_dice", "name":"roll_dice", "handler":"roll_dice",
        "description":"Roll dice: kh/kl/dl/dh, adv/dis, exploding !/!!, rerolls r/ro, success counting, N#expr, labels, dF and d%.",
        "parameters":{"type":"object","properties":{"expression":{"type":"string","description":"Dice expression, e.g. 4d6kh3 or 1d20+5 attack"},"reason":{"type":"string"}},"required":["expression"],"additionalProperties":false}
    }]);
    let now = crate::model::now();
    plugin["created_at"] = json!(now);
    plugin["updated_at"] = json!(now);
    validate(&plugin)?;
    sqlx::query("INSERT INTO entities(id,user_id,kind,parent_id,data,created_at,updated_at) VALUES ($1,$2,'plugin','',$3,$4,$4)")
        .bind(text(&plugin,"id")).bind(uid).bind(plugin.to_string()).bind(now).execute(&mut **tx).await?;
    sqlx::query(
        "INSERT INTO plugin_storage(user_id,plugin_id,used_bytes,entry_count) VALUES ($1,$2,0,0)",
    )
    .bind(uid)
    .bind(text(&plugin, "id"))
    .execute(&mut **tx)
    .await?;
    Ok(())
}

#[cfg(test)]
mod builtin_tests {
    use super::*;
    #[tokio::test]
    async fn dice_full_syntax() {
        let host: runtime::Host = std::sync::Arc::new(|_, _| {
            Box::pin(async { anyhow::bail!("dice must not use host permissions") })
        });
        for expression in [
            "4d6kh3",
            "4d6kl2",
            "4d6dl1",
            "4d6dh1",
            "adv+5",
            "dis",
            "d6!",
            "d6!!",
            "2d10r1",
            "2d10ro<2",
            "10d6>=5",
            "3#1d20+4 attack",
            "4dF",
            "d%",
            "(1d8+2)*2",
        ] {
            let code = format!("Math.random = () => 0.4;\n{}", include_str!("dice.js"));
            let result = runtime::run(
                code,
                "roll_dice".into(),
                json!({"expression":expression,"reason":"Test"}),
                json!({}),
                host.clone(),
                false,
                tokio_util::sync::CancellationToken::new(),
            )
            .await
            .unwrap();
            assert!(
                result.as_str().unwrap().starts_with("🎲 Test\n"),
                "{expression}: {result}"
            );
            assert!(
                result.as_str().unwrap().contains("= **"),
                "{expression}: {result}"
            );
        }
        for (expression, expected) in [
            ("d6!", "**9**"),
            ("d6!!", "**9**"),
            ("d6r6", "**3**"),
            ("d6ro6", "**3**"),
        ] {
            let code = format!(
                "let draws=[0.99,0.4]; Math.random=()=>draws.shift() ?? 0.4;\n{}",
                include_str!("dice.js")
            );
            let result = runtime::run(
                code,
                "roll_dice".into(),
                json!({"expression":expression}),
                json!({}),
                host.clone(),
                false,
                tokio_util::sync::CancellationToken::new(),
            )
            .await
            .unwrap();
            assert!(
                result.as_str().unwrap().contains(expected),
                "{expression}: {result}"
            );
        }
    }
}
