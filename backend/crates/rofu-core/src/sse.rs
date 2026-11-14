/// Byte-oriented SSE decoder: UTF-8 and CRLF may both span arbitrary network chunks.
#[derive(Default, Debug)]
pub struct Decoder {
    pending: Vec<u8>,
    data: Vec<String>,
    event: String,
}
#[derive(Debug, PartialEq)]
pub struct Event {
    pub event: String,
    pub data: String,
}
impl Decoder {
    pub fn push(&mut self, chunk: &[u8]) -> Vec<Event> {
        self.pending.extend_from_slice(chunk);
        let mut out = vec![];
        while let Some(end) = self.pending.iter().position(|b| *b == b'\n' || *b == b'\r') {
            let cr = self.pending[end] == b'\r';
            if cr && end + 1 == self.pending.len() {
                break;
            }
            let terminator = if cr && self.pending.get(end + 1) == Some(&b'\n') {
                2
            } else {
                1
            };
            let line = String::from_utf8_lossy(&self.pending[..end]).into_owned();
            self.pending.drain(..end + terminator);
            let line = line.strip_prefix('\u{feff}').unwrap_or(&line);
            if line.is_empty() {
                if let Some(e) = self.flush() {
                    out.push(e);
                }
            } else if let Some(rest) = line.strip_prefix("data:") {
                self.data
                    .push(rest.strip_prefix(' ').unwrap_or(rest).to_owned());
            } else if let Some(rest) = line.strip_prefix("event:") {
                self.event = rest.trim().to_owned();
            }
        }
        out
    }
    fn flush(&mut self) -> Option<Event> {
        if self.data.is_empty() {
            self.event.clear();
            return None;
        }
        Some(Event {
            event: std::mem::take(&mut self.event),
            data: std::mem::take(&mut self.data).join("\n"),
        })
    }
    pub fn finish(&mut self) -> Vec<Event> {
        let mut out = self.push(b"\n");
        if let Some(e) = self.flush() {
            out.push(e);
        }
        out
    }
}
/// Split a leading <think> block, buffering partial tags without leaking them as text.
#[derive(Default)]
pub struct Think {
    buffer: String,
    state: u8,
}
impl Think {
    pub fn push(&mut self, text: &str) -> Vec<(bool, String)> {
        self.buffer.push_str(text);
        self.drain(false)
    }
    pub fn finish(&mut self) -> Vec<(bool, String)> {
        self.drain(true)
    }
    fn drain(&mut self, finish: bool) -> Vec<(bool, String)> {
        let mut out = vec![];
        if self.state == 0 {
            let trimmed = self.buffer.trim_start();
            if let Some(rest) = trimmed.strip_prefix("<think>") {
                self.buffer = rest.to_owned();
                self.state = 1;
            } else if !finish && ("<think>".starts_with(trimmed) || trimmed.is_empty()) {
                return out;
            } else {
                self.state = 2;
            }
        }
        if self.state == 1 {
            if let Some(end) = self.buffer.find("</think>") {
                let reasoning = self.buffer[..end].to_owned();
                if !reasoning.is_empty() {
                    out.push((true, reasoning));
                }
                self.buffer = self.buffer[end + 8..].to_owned();
                self.state = 2;
            } else if finish {
                out.push((true, std::mem::take(&mut self.buffer)));
                return out;
            } else {
                let keep = (1..=8.min(self.buffer.len()))
                    .rev()
                    .find(|n| {
                        self.buffer.is_char_boundary(self.buffer.len() - n)
                            && "</think>".starts_with(&self.buffer[self.buffer.len() - n..])
                    })
                    .unwrap_or(0);
                let end = self.buffer.len() - keep;
                if end > 0 {
                    out.push((true, self.buffer.drain(..end).collect()));
                }
                return out;
            }
        }
        if self.state == 2 && !self.buffer.is_empty() {
            out.push((false, std::mem::take(&mut self.buffer)));
        }
        out
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn cr_lf_and_eof() {
        for wire in ["data: one\r\rdata: two\r", "\u{feff}data: one\ndata: two"] {
            let mut d = Decoder::default();
            let mut events = vec![];
            for byte in wire.as_bytes() {
                events.extend(d.push(&[*byte]));
            }
            events.extend(d.finish());
            assert!(!events.is_empty());
            assert_eq!(
                events
                    .iter()
                    .map(|e| e.data.as_str())
                    .collect::<Vec<_>>()
                    .join("\n"),
                "one\ntwo"
            );
        }
    }
    #[test]
    fn chunks() {
        let wire = "event: text\r\ndata: 你好\r\ndata: two\r\n\r\n:ping\n\ndata: end\n\n";
        let mut d = Decoder::default();
        let mut out = vec![];
        for b in wire.as_bytes() {
            out.extend(d.push(&[*b]));
        }
        assert_eq!(
            out,
            vec![
                Event {
                    event: "text".into(),
                    data: "你好\ntwo".into()
                },
                Event {
                    event: "".into(),
                    data: "end".into()
                }
            ]
        );
    }
    #[test]
    fn think_boundaries() {
        let wire = "<think>思考 here</think>answer";
        for split in 0..wire.len() {
            if !wire.is_char_boundary(split) {
                continue;
            }
            let mut t = Think::default();
            let mut o = t.push(&wire[..split]);
            o.extend(t.push(&wire[split..]));
            o.extend(t.finish());
            let reasoning = o
                .iter()
                .filter(|(r, _)| *r)
                .map(|(_, s)| s.as_str())
                .collect::<String>();
            let text = o
                .iter()
                .filter(|(r, _)| !*r)
                .map(|(_, s)| s.as_str())
                .collect::<String>();
            assert_eq!(reasoning, "思考 here");
            assert_eq!(text, "answer");
        }
    }
}
