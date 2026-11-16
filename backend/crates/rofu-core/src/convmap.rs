//! Compact active-message projections. Stream one stored row at a time and skip
//! unused JSON fields (notably images, tool payloads and archived swipe tails).
use crate::{
    api::{ApiError, ApiResult},
    db::Db,
};
use futures_util::TryStreamExt;
use serde::{de, Deserialize, Deserializer, Serialize};
#[cfg(test)]
use serde_json::{json, Value};
use std::{collections::VecDeque, fmt};

#[derive(Deserialize)]
struct Segment {
    #[serde(rename = "type")]
    kind: String,
    #[serde(default)]
    text: String,
}

// Counting arrays without materializing their contents also skips nested tails.
fn array_len<'de, D: Deserializer<'de>>(d: D) -> Result<usize, D::Error> {
    struct Count;
    impl<'de> de::Visitor<'de> for Count {
        type Value = usize;
        fn expecting(&self, f: &mut fmt::Formatter) -> fmt::Result {
            f.write_str("an array or a projected array count")
        }
        fn visit_u64<E: de::Error>(self, count: u64) -> Result<usize, E> {
            usize::try_from(count).map_err(E::custom)
        }
        fn visit_seq<A: de::SeqAccess<'de>>(self, mut a: A) -> Result<usize, A::Error> {
            let mut n = 0;
            while a.next_element::<de::IgnoredAny>()?.is_some() {
                n += 1;
            }
            Ok(n)
        }
    }
    d.deserialize_any(Count)
}

#[derive(Deserialize)]
struct Parts {
    segments: Vec<Segment>,
    #[serde(deserialize_with = "array_len")]
    images: usize,
}

#[derive(Deserialize)]
struct MapMessage {
    id: String,
    seq: i64,
    role: String,
    visible: bool,
    #[serde(default)]
    kind: Option<String>,
    content: String,
    parts: Parts,
    #[serde(deserialize_with = "array_len")]
    swipes: usize,
}

#[derive(Serialize)]
pub struct MapPage {
    items: VecDeque<MapItem>,
    total: usize,
    has_more: bool,
}

#[derive(Serialize)]
struct MapItem {
    id: String,
    seq: i64,
    role: String,
    visible: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    kind: Option<String>,
    preview: String,
    chars: usize,
    has_images: bool,
    swipe_count: usize,
    #[serde(skip_serializing_if = "Option::is_none")]
    match_start: Option<usize>,
    #[serde(skip_serializing_if = "Option::is_none")]
    match_len: Option<usize>,
}

// Each preview scalar retains its source position, so whitespace collapsing and
// removed markdown do not invalidate highlights found in the full original text.
struct Glyph {
    ch: char,
    source: usize,
    end: usize,
}

fn strip_markers(mut line: &str) -> &str {
    line = line.trim_start();
    loop {
        let stripped = if line.starts_with('#') {
            let rest = line.trim_start_matches('#');
            rest.starts_with(char::is_whitespace).then_some(rest)
        } else if let Some(rest) = line.strip_prefix('>') {
            Some(rest)
        } else if matches!(line.chars().next(), Some('-' | '*' | '+')) {
            let rest = &line[1..];
            rest.starts_with(char::is_whitespace).then_some(rest)
        } else {
            let rest = line.trim_start_matches(|c: char| c.is_ascii_digit());
            if rest.len() < line.len() {
                rest.strip_prefix(['.', ')'])
                    .filter(|r| r.starts_with(char::is_whitespace))
            } else {
                None
            }
        };
        match stripped {
            Some(rest) => line = rest.trim_start(),
            None => return line,
        }
    }
}

fn clean(input: &str) -> Vec<Glyph> {
    let mut out: Vec<Glyph> = Vec::new();
    let mut offset = 0;
    let mut pending_space: Option<Glyph> = None;
    for line in input.split_inclusive('\n') {
        let body = strip_markers(line);
        // A fenced block's language and delimiters are not visible body text.
        let body = if body.starts_with("```") || body.starts_with("~~~") {
            ""
        } else {
            body
        };
        let skipped = line[..line.len() - body.len()].chars().count();
        for (i, ch) in body.chars().enumerate() {
            let source = offset + skipped + i;
            if ch.is_whitespace() {
                let space = pending_space.get_or_insert(Glyph {
                    ch: ' ',
                    source,
                    end: source + 1,
                });
                space.end = source + 1;
            } else {
                if !out.is_empty() {
                    if let Some(space) = pending_space.take() {
                        out.push(space);
                    }
                }
                pending_space = None;
                out.push(Glyph {
                    ch,
                    source,
                    end: source + 1,
                });
            }
        }
        if line.ends_with('\n') {
            let source = offset + line.chars().count() - 1;
            let space = pending_space.get_or_insert(Glyph {
                ch: ' ',
                source,
                end: source + 1,
            });
            space.end = source + 1;
        }
        offset += line.chars().count();
    }
    out
}

// Unicode lowercasing can expand a scalar (e.g. İ). Track original indices rather
// than using byte offsets from a lowercased string as offsets into the original.
fn find(input: &str, needle: &str) -> Option<(usize, usize)> {
    let mut folded = String::new();
    let mut sources = Vec::new();
    for (i, ch) in input.chars().enumerate() {
        for lower in ch.to_lowercase() {
            sources.extend(std::iter::repeat_n(i, lower.len_utf8()));
            folded.push(lower);
        }
    }
    let start = folded.find(needle)?;
    Some((sources[start], sources[start + needle.len() - 1] + 1))
}

impl MapMessage {
    fn item(self, width: usize, needle: Option<&str>) -> Option<MapItem> {
        let active = if self.role == "assistant" {
            self.parts
                .segments
                .iter()
                .filter(|s| s.kind == "text")
                .map(|s| s.text.as_str())
                .collect::<String>()
        } else {
            self.content
        };
        let hit = match needle {
            Some(needle) => Some(find(&active, needle)?),
            None => None,
        };
        let chars = active.chars().count();
        let glyphs = clean(&active);
        let (start, end, highlight) = if let Some((from, to)) = hit {
            let a = glyphs.partition_point(|g| g.end <= from);
            let b = glyphs.partition_point(|g| g.source < to);
            let size = width.max(b - a);
            let start = a
                .saturating_sub((size - (b - a)) / 2)
                .min(glyphs.len().saturating_sub(size));
            let end = (start + size).min(glyphs.len());
            (start, end, Some((a - start, b - a)))
        } else {
            (0, width.min(glyphs.len()), None)
        };
        let prefix = hit.is_some() && start > 0;
        let mut preview = String::new();
        if prefix {
            preview.push('…');
        }
        preview.extend(glyphs[start..end].iter().map(|g| g.ch));
        if hit.is_some() && end < glyphs.len() {
            preview.push('…');
        }
        let kind = self
            .kind
            .or_else(|| (self.role == "summary").then(|| "summary".into()));
        Some(MapItem {
            id: self.id,
            seq: self.seq,
            role: self.role,
            visible: self.visible,
            kind,
            preview,
            chars,
            has_images: self.parts.images > 0,
            swipe_count: self.swipes,
            match_start: highlight.map(|(start, _)| start + usize::from(prefix)),
            match_len: highlight.map(|(_, len)| len),
        })
    }
}

pub async fn map(
    db: &Db,
    uid: &str,
    cid: &str,
    q: &std::collections::HashMap<String, String>,
) -> ApiResult<MapPage> {
    let width = q
        .get("chars")
        .map(|s| s.parse::<i64>())
        .transpose()
        .map_err(|_| ApiError::bad("chars must be an integer"))?
        .unwrap_or(48)
        .clamp(8, 200) as usize;
    let limit = q
        .get("limit")
        .map(|s| {
            s.parse::<usize>()
                .ok()
                .filter(|n| *n > 0)
                .ok_or_else(|| ApiError::bad("limit must be a positive integer"))
        })
        .transpose()?
        .map(|n| n.min(5000));
    let before = q
        .get("before_seq")
        .map(|s| s.parse::<i64>())
        .transpose()
        .map_err(|_| ApiError::bad("before_seq must be an integer"))?;
    let needle = q
        .get("q")
        .filter(|s| !s.is_empty())
        .map(|s| s.chars().flat_map(char::to_lowercase).collect::<String>());
    // SQLite's bundled JSON functions project in C before crossing the worker
    // channel. This avoids copying/decoding duplicate snapshots and private tool
    // or reasoning text for every entry in a large history. PostgreSQL streams
    // the same projection through the selective Rust decoder above.
    let sql = if db.pool.connect_options().database_url.scheme() == "sqlite" {
        r#"SELECT json_object(
            'id',id,'seq',seq,'role',data->>'role',
            'visible',json(data->'visible'),
            'kind',data->>'kind','content',data->>'content',
            'swipes',json_array_length(data->'swipes'),
            'parts',json_object(
                'images',json(CASE WHEN json_array_length(data->'parts'->'images')>0 THEN '[null]' ELSE '[]' END),
                'segments',json(COALESCE((SELECT json_group_array(json_object(
                    'type',value->>'type',
                    'text',CASE WHEN value->>'type'='text' THEN COALESCE(value->>'text','') ELSE '' END
                )) FROM json_each(data->'parts'->'segments')),'[]'))
            )
        ) FROM messages WHERE user_id=$1 AND conversation_id=$2 ORDER BY seq,id"#
    } else {
        "SELECT data FROM messages WHERE user_id=$1 AND conversation_id=$2 ORDER BY seq,id"
    };
    let mut rows = sqlx::query_scalar::<_, String>(sql)
        .bind(uid)
        .bind(cid)
        .fetch(&db.pool);
    let mut items = VecDeque::new();
    let (mut total, mut eligible) = (0usize, 0usize);
    while let Some(row) = rows.try_next().await? {
        let message: MapMessage = serde_json::from_str(&row).map_err(anyhow::Error::from)?;
        let seq = message.seq;
        if let Some(item) = message.item(width, needle.as_deref()) {
            total += 1;
            if before.is_none_or(|n| seq < n) {
                eligible += 1;
                if limit.is_some_and(|n| items.len() == n) {
                    items.pop_front();
                }
                items.push_back(item);
            }
        }
    }
    Ok(MapPage {
        has_more: eligible > items.len(),
        items,
        total,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn item(content: &str, width: usize, q: Option<&str>) -> Value {
        serde_json::from_value::<MapMessage>(json!({
            "id":"m", "seq":1000, "role":"user", "visible":true, "content":content, "parts":{"images":[],"segments":[]},"swipes":[{}],
        }))
        .unwrap()
        .item(
            width,
            q.map(|s| s.chars().flat_map(char::to_lowercase).collect::<String>())
                .as_deref(),
        )
        .map(serde_json::to_value)
        .unwrap()
        .unwrap()
    }

    fn highlighted(item: &Value) -> String {
        item["preview"]
            .as_str()
            .unwrap()
            .chars()
            .skip(item["match_start"].as_u64().unwrap() as usize)
            .take(item["match_len"].as_u64().unwrap() as usize)
            .collect()
    }

    #[test]
    fn unicode_markdown_and_full_visible_length() {
        let content = "  ## > - 你好🙂\t 世界\n1. 第二行\n```rust\n代码\n```\n+ 结尾";
        let full = item(content, 200, None);
        assert_eq!(full["preview"], "你好🙂 世界 第二行 代码 结尾");
        assert_eq!(full["chars"], content.chars().count());
        assert_eq!(item(content, 8, None)["preview"], "你好🙂 世界 第");
        for content in ["", "  \n\t", "```rust\n```", "### "] {
            assert_eq!(item(content, 48, None)["preview"], "");
        }
    }

    #[test]
    fn first_match_window_and_scalar_highlight() {
        let text = "# 开始🙂 很长很长很长 很长很长目标🙂之后还有很长很长结尾 目标🙂";
        let hit = item(text, 8, Some("目标🙂"));
        assert_eq!(highlighted(&hit), "目标🙂");
        assert!(hit["preview"].as_str().unwrap().starts_with('…'));
        assert!(hit["preview"].as_str().unwrap().ends_with('…'));
        let hit = item("## Straße İSTANBUL 中文", 10, Some("i\u{307}stanbul"));
        assert_eq!(highlighted(&hit), "İSTANBUL");
        assert_eq!(
            highlighted(&item("# Hello\t\n WORLD", 48, Some("hello\t\n world"))),
            "Hello WORLD"
        );
        assert_eq!(highlighted(&item("a  \tb", 48, Some(" \t"))), " ");
        for literal in ["%", "_", "\\", "' OR 1=1 --"] {
            assert_eq!(
                highlighted(&item(&format!("prefix {literal} suffix"), 8, Some(literal))),
                literal
            );
        }
    }

    #[test]
    fn assistant_segments_are_the_only_searchable_text() {
        let m: MapMessage = serde_json::from_value(json!({
            "id":"m", "seq":0, "role":"assistant", "visible":false,
            "content":"stale content", "actual":"secret actual",
            "parts":{"segments":[
                {"type":"reasoning","text":"secret reasoning"},
                {"type":"text","text":"# Visible "},
                {"type":"tool","arguments":"secret arguments","result":"secret result"},
                {"type":"text","text":"你好🙂"}
            ],"images":[{"url":"secret image"}]},
            "swipes":[{"content":"secret inactive","tail":[{"content":"secret tail"}]},{}]
        }))
        .unwrap();
        let v = serde_json::to_value(m.item(48, Some("你好")).unwrap()).unwrap();
        assert_eq!(v["preview"], "Visible 你好🙂");
        assert_eq!(v["chars"], "# Visible 你好🙂".chars().count());
        assert_eq!(v["visible"], false);
        assert_eq!(v["has_images"], true);
        assert_eq!(v["swipe_count"], 2);
        assert!(!v.to_string().contains("secret"));
        let m: MapMessage = serde_json::from_value(json!({
            "id":"m", "seq":0, "role":"assistant", "visible":true,"swipes":[{}], "content":"secret fallback",
            "parts":{"images":[],"segments":[{"type":"reasoning","text":"secret"}]}
        }))
        .unwrap();
        assert!(m.item(48, Some("secret")).is_none());
    }
}
