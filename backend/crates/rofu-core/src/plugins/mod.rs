//! Plugin packages. Metadata is never discovered by executing untrusted code.
pub mod hooks;
pub mod host;
pub mod routes;
pub mod runtime;
pub mod storage;

use crate::model::{flag, text};
use anyhow::{bail, ensure, Result};
use serde_json::{json, Value};

pub const HOOK_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(2);
pub const INVOCATION_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(10);
pub const MAX_FOLLOW_UPS: usize = 2;
pub const MEMORY_LIMIT: usize = 64 * 1024 * 1024;
pub const STACK_LIMIT: usize = 1024 * 1024;

pub fn legacy_plugin(mut tool: Value) -> Value {
    tool["format"] = json!("legacy-main");
    tool["version"] = json!("1");
    tool["manifest"] = json!({"api_version":1,"permissions":["network"],"tools":[{
        "id":"main","name":tool["name"],"description":tool["description"],
        "parameters":tool["parameters"],"handler":"main"
    }],"hooks":{},"menus":[]});
    tool["granted_permissions"] = if flag(&tool, "enabled", true) {
        json!(["network"])
    } else {
        json!([])
    };
    tool
}
pub fn legacy_tool(mut plugin: Value) -> Value {
    if let Some(obj) = plugin.as_object_mut() {
        for key in ["format", "version", "manifest", "granted_permissions"] {
            obj.remove(key);
        }
    }
    plugin
}
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
        matches!(plugin["format"].as_str(), Some("module-v1" | "legacy-main")),
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

/// Keep the old tool_ids view while exposing the complete ordered plugin list.
pub async fn project_character(
    s: &crate::server::AppState,
    uid: &str,
    c: &mut Value,
) -> Result<()> {
    c["plugin_ids"] = c["tool_ids"].clone();
    let mut legacy = vec![];
    for id in c["plugin_ids"].as_array().into_iter().flatten() {
        if s.db
            .get(uid, "tool", id.as_str().unwrap_or(""))
            .await?
            .is_some()
        {
            legacy.push(id.clone());
        }
    }
    c["tool_ids"] = json!(legacy);
    Ok(())
}
