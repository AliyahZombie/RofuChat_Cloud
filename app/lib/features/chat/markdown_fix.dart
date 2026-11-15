/// Source fixes applied before markdown is split into blocks, for syntax the renderer
/// misses. Code fences and inline code spans are left untouched.
///
/// - `$$` block math: the opening line may follow a paragraph line directly, which a block
///   syntax cannot interrupt, so the formula rendered as raw text. A blank line is
///   inserted before and after each `$$ … $$` block.
/// - Pandoc-style superscript `X^2^` and subscript `H~2~O` become inline math (`$^{2}$`,
///   `$_{2}$`). Without this a single `~` pair would turn into strikethrough.
String preprocessMarkdown(String src) {
  if (!src.contains(r'$$') && !src.contains('^') && !src.contains('~')) return src;
  final lines = src.split('\n');
  final out = <String>[];
  var fence = '';
  var inMath = false;
  for (final line in lines) {
    final trimmed = line.trimLeft();
    if (!inMath) {
      final f = RegExp(r'^(```+|~~~+)').firstMatch(trimmed);
      if (fence.isEmpty && f != null) {
        fence = f.group(1)!.substring(0, 3);
        out.add(line);
        continue;
      }
      if (fence.isNotEmpty) {
        if (trimmed.startsWith(fence)) fence = '';
        out.add(line);
        continue;
      }
    }
    final isMathFence = RegExp(r'^\s*\$\$\s*$').hasMatch(line);
    if (inMath) {
      out.add(line);
      if (isMathFence || line.trimRight().endsWith(r'$$')) {
        inMath = false;
        out.add('');
      }
      continue;
    }
    if (trimmed.startsWith(r'$$')) {
      // Opening $$ (a fence line or a formula starting on it). Separate it from a preceding
      // paragraph line.
      if (out.isNotEmpty && out.last.trim().isNotEmpty) out.add('');
      out.add(line);
      final single = RegExp(r'^\s*\$\$.+\$\$\s*$').hasMatch(line);
      if (single) {
        out.add('');
      } else {
        inMath = true;
      }
      continue;
    }
    out.add(_supSub(line));
  }
  // Collapse runs of blank lines that the insertions may have created.
  return out.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n');
}

final _code = RegExp(r'(`+)[\s\S]*?\1|\$[^$\n]+\$');
final _sup = RegExp(r'(?<![\\^])\^([A-Za-z0-9+\-=()]{1,12})\^(?!\^)');
final _sub = RegExp(r'(?<![~\\])~([A-Za-z0-9+\-=()]{1,12})~(?!~)');

/// Rewrites `^x^` and `~x~` outside code spans and existing inline math.
String _supSub(String line) {
  if (!line.contains('^') && !line.contains('~')) return line;
  final b = StringBuffer();
  var last = 0;
  for (final m in _code.allMatches(line)) {
    b.write(_supSubPlain(line.substring(last, m.start)));
    b.write(m.group(0));
    last = m.end;
  }
  b.write(_supSubPlain(line.substring(last)));
  return b.toString();
}

String _supSubPlain(String s) => s
    .replaceAllMapped(_sup, (m) => '\$^{${m.group(1)}}\$')
    .replaceAllMapped(_sub, (m) => '\$_{${m.group(1)}}\$');
