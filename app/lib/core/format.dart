String fmtTokens(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(n >= 10000000 ? 0 : 1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 100000 ? 0 : 1)}k';
  return '$n';
}

String fmtDuration(int ms) {
  if (ms < 1000) return '${ms}ms';
  final s = ms / 1000;
  if (s < 60) return '${s.toStringAsFixed(1)}s';
  final m = s ~/ 60;
  return '${m}m${(s - m * 60).round()}s';
}

String fmtTime(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final now = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  if (d.year == now.year && d.month == now.month && d.day == now.day) return '${two(d.hour)}:${two(d.minute)}';
  if (d.year == now.year) return '${d.month}/${d.day}';
  return '${d.year}/${d.month}/${d.day}';
}

/// 12345 -> "12,345".
String fmtCount(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

/// Byte size as B / KB / MB.
String fmtBytes(int b) {
  if (b < 1024) return '$b B';
  if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(b < 10 * 1024 ? 1 : 0)} KB';
  return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
}

/// Rough transfer size of [chars] characters of chat history: UTF-8 CJK text is ~3 bytes a
/// character, plus ~20% JSON/metadata overhead (the server reports the real size per page).
int estimateHistoryBytes(int chars) => (chars * 3 * 1.2).round();
