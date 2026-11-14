import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:md_single_block_renderer/md_single_block_renderer.dart';

import '../../core/format.dart';
import '../../core/i18n.dart';
import '../../models/models.dart';
import '../../widgets/motion.dart';

/// A chat list item. Messages are flattened into rows so that every markdown block is its
/// own ListView item (md_single_block_renderer: only visible blocks get built).
sealed class ChatRow {
  final Message msg;
  const ChatRow(this.msg);
  String get key;
}

class UserRow extends ChatRow {
  const UserRow(super.msg);
  @override
  String get key => 'u:${msg.id}';
}

class AssistantHeaderRow extends ChatRow {
  const AssistantHeaderRow(super.msg);
  @override
  String get key => 'h:${msg.id}';
}

/// Consecutive reasoning/tool segments.
class StepsRow extends ChatRow {
  final List<Segment> steps;
  final int index;
  final bool live;
  const StepsRow(super.msg, this.steps, this.index, this.live);
  @override
  String get key => 's:${msg.id}:$index';
}

class BlockRow extends ChatRow {
  final Block block;
  final int seg;
  final int index;
  const BlockRow(super.msg, this.block, this.seg, this.index);
  @override
  String get key => 'b:${msg.id}:$seg:$index';
}

class FooterRow extends ChatRow {
  final bool isLastAssistant;
  const FooterRow(super.msg, this.isLastAssistant);
  @override
  String get key => 'f:${msg.id}';
}

class SummaryRow extends ChatRow {
  const SummaryRow(super.msg);
  @override
  String get key => 'sum:${msg.id}';
}

/// Caches parsed markdown blocks per (message, segment, text).
class BlockCache {
  final _cache = <String, (int, List<Block>)>{};

  List<Block> get(String msgId, int seg, String text) {
    final k = '$msgId:$seg';
    final hit = _cache[k];
    final h = text.hashCode ^ text.length;
    if (hit != null && hit.$1 == h) return hit.$2;
    List<Block> blocks;
    try {
      blocks = markdownToBlocks(text);
    } catch (_) {
      blocks = markdownToBlocks(text.replaceAll('`', "'"));
    }
    _cache[k] = (h, blocks);
    return blocks;
  }

  void clear() => _cache.clear();
}

List<ChatRow> buildRows(List<Message> messages, BlockCache cache, {String? streamingId, bool generating = false}) {
  final rows = <ChatRow>[];
  final lastAssistant = messages.lastWhere((m) => m.isAssistant, orElse: () => Message({'id': ''})).id;
  for (final m in messages) {
    if (m.isUser) {
      rows.add(UserRow(m));
    } else if (m.isSummary) {
      rows.add(SummaryRow(m));
    } else if (m.isAssistant) {
      rows.add(AssistantHeaderRow(m));
      final segs = m.segments;
      final live = m.id == streamingId;
      if (segs.isEmpty && m.content.isNotEmpty) {
        final blocks = cache.get(m.id, 0, m.content);
        for (var i = 0; i < blocks.length; i++) {
          rows.add(BlockRow(m, blocks[i], 0, i));
        }
      }
      var steps = <Segment>[];
      var stepIndex = 0;
      for (var si = 0; si < segs.length; si++) {
        final s = segs[si];
        if (s.type == 'text') {
          if (steps.isNotEmpty) {
            rows.add(StepsRow(m, steps, stepIndex++, false));
            steps = [];
          }
          final blocks = cache.get(m.id, si, live && si == segs.length - 1 ? closeStreamingMarkdown(s.text) : s.text);
          for (var i = 0; i < blocks.length; i++) {
            rows.add(BlockRow(m, blocks[i], si, i));
          }
        } else {
          steps.add(s);
        }
      }
      if (steps.isNotEmpty) rows.add(StepsRow(m, steps, stepIndex, live));
      if (!live) rows.add(FooterRow(m, m.id == lastAssistant));
    }
  }
  return rows;
}

/// While a reply streams, its tail can stop inside unfinished syntax (an open code fence,
/// `**bold`, an inline code span). Close it so the half-written text renders as what it will
/// become instead of flickering between raw markers and formatting.
String closeStreamingMarkdown(String text) {
  var out = text;
  final fences = RegExp(r'^\s*(```|~~~)', multiLine: true).allMatches(out).length;
  if (fences.isOdd) return '$out\n```';
  // Only look at the last paragraph: inline markers never span blocks.
  final cut = out.lastIndexOf('\n\n');
  final para = cut < 0 ? out : out.substring(cut + 2);
  final noCode = para.replaceAll(RegExp(r'`[^`]*`'), '');
  if ('`'.allMatches(noCode).length.isOdd) return '$out`';
  if ('**'.allMatches(noCode).length.isOdd) {
    out = out.endsWith('*') && !out.endsWith('**') ? out.substring(0, out.length - 1) : out;
    return '$out**';
  }
  // a lone trailing marker that would otherwise show as a bullet or emphasis start
  if (RegExp(r'(^|\n)\s*[*#>-]\s*$').hasMatch(out)) return out.substring(0, out.lastIndexOf(RegExp(r'[*#>-]')));
  return out;
}

// ------------------------------------------------------------------ widgets

class UserBubble extends StatelessWidget {
  final Message msg;
  final String userName;
  final bool showName;
  final bool compact;
  final double maxWidthFactor;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final void Function(Offset) onMore;
  final Widget? swipeNav;
  const UserBubble({super.key, required this.msg, required this.userName, required this.showName, required this.onCopy, required this.onEdit, required this.onMore, this.compact = false, this.maxWidthFactor = 0.85, this.swipeNav});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    return Opacity(
      opacity: msg.visible ? 1 : 0.5,
      child: Padding(
        padding: EdgeInsets.only(top: compact ? 6 : 10, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showName)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 4),
                child: Text(userName, style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ),
            if (msg.images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  runSpacing: 4,
                  children: [for (final img in msg.images) _Thumb(dataUrl: img)],
                ),
              ),
            if (msg.content.isNotEmpty)
              GestureDetector(
                onLongPressStart: (d) => onMore(d.globalPosition),
                onSecondaryTapUp: (d) => onMore(d.globalPosition),
                child: Container(
                  constraints: BoxConstraints(maxWidth: width * maxWidthFactor),
                  padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 8 : 10),
                  decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                  child: SelectableText(msg.content, style: text.bodyLarge?.copyWith(color: scheme.onPrimaryContainer, height: 1.35)),
                ),
              ),
            if (!compact)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!msg.visible) _NotInContext(),
                  _MiniIcon(Icons.copy_rounded, t('复制', 'Copy'), onCopy),
                  ?swipeNav,
                  _MiniIcon(Icons.edit_outlined, t('编辑', 'Edit'), onEdit),
                  Builder(builder: (c) => _MiniIcon(Icons.more_vert, t('更多', 'More'), () => onMore(_center(c)))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

Offset _center(BuildContext c) {
  final box = c.findRenderObject() as RenderBox?;
  if (box == null) return Offset.zero;
  return box.localToGlobal(box.size.center(Offset.zero));
}

class _NotInContext extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(border: Border.all(color: scheme.outline), borderRadius: BorderRadius.circular(6)),
      child: Text(t('不在上下文中', 'Not in context'), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.outline)),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String dataUrl;
  const _Thumb({required this.dataUrl});
  @override
  Widget build(BuildContext context) {
    Widget img;
    try {
      img = dataUrl.startsWith('data:')
          ? Image.memory(base64Decode(dataUrl.substring(dataUrl.indexOf(',') + 1)), fit: BoxFit.cover)
          : Image.network(dataUrl, fit: BoxFit.cover);
    } catch (_) {
      img = const Icon(Icons.broken_image_outlined);
    }
    return GestureDetector(
      onTap: () => showDialog(context: context, builder: (c) => Dialog(child: InteractiveViewer(child: img))),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 96, height: 96, child: img)),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final String tip;
  final VoidCallback onTap;
  final Color? color;
  const _MiniIcon(this.icon, this.tip, this.onTap, {this.color});
  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tip,
        onPressed: onTap,
        iconSize: 18,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        icon: Icon(icon),
      );
}

class MiniIconButton extends _MiniIcon {
  const MiniIconButton(super.icon, super.tip, super.onTap, {super.color});
}

/// Collapsible card for reasoning + tool steps (RikkaHub style).
class StepsCard extends StatefulWidget {
  final List<Segment> steps;
  final bool live;
  final bool compact;
  const StepsCard({super.key, required this.steps, required this.live, this.compact = false});
  @override
  State<StepsCard> createState() => _StepsCardState();
}

class _StepsCardState extends State<StepsCard> {
  bool _expanded = false;
  final Set<int> _open = {};

  String _title(Segment s, bool live) {
    if (s.type == 'reasoning') {
      if (live && s.durationMs == 0) return t('思考中…', 'Thinking…');
      final secs = (s.durationMs / 1000).toStringAsFixed(1);
      return t('思考了 $secs 秒', 'Thought for $secs seconds');
    }
    return s.name;
  }

  String _subtitle(Segment s) {
    if (s.type != 'tool') return '';
    try {
      final j = jsonDecode(s.arguments.isEmpty ? '{}' : s.arguments);
      if (j is Map && j.isNotEmpty) {
        for (final k in ['url', 'query', 'q', 'path', 'content', 'id', 'expr']) {
          if (j[k] is String) return j[k] as String;
        }
        return j.values.first.toString();
      }
    } catch (_) {}
    return s.arguments;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final steps = widget.steps;
    final folds = steps.length > 2;
    final hidden = steps.length - 1;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (folds)
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(children: [
                  TurnChevron(open: _expanded, size: 20, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_expanded ? t('收起步骤', 'Hide steps') : t('显示另外 $hidden 个步骤', 'Show $hidden more steps'),
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: text.labelLarge?.copyWith(color: scheme.primary)),
                  ),
                ]),
              ),
            ),
          for (var i = 0; i < steps.length; i++)
            if (folds && i < steps.length - 1)
              Collapsible(open: _expanded, child: _step(context, steps[i], i, false))
            else
              _step(context, steps[i], i, widget.live && i == steps.length - 1),
        ],
      ),
    );
  }

  Widget _step(BuildContext context, Segment s, int i, bool live) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final open = _open.contains(i) || (live && s.type == 'reasoning');
    final isTool = s.type == 'tool';
    final running = isTool && s.result == null;
    final sub = _subtitle(s);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => open ? _open.remove(i) : _open.add(i)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.compact ? 8 : 14, vertical: 6),
            child: Row(children: [
              if (running)
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Icon(isTool ? (s.isError ? Icons.error_outline : Icons.build_circle_outlined) : Icons.lightbulb_outline,
                    size: 18, color: s.isError ? scheme.error : scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_title(s, live), style: text.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (sub.isNotEmpty && !widget.compact)
                    Text(sub, style: text.bodySmall?.copyWith(color: scheme.primary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ]),
              ),
              if (isTool && !running) Text(fmtDuration(s.durationMs), style: text.labelSmall?.copyWith(color: scheme.outline)),
              TurnChevron(open: open, sideways: isTool, color: scheme.onSurfaceVariant),
            ]),
          ),
        ),
        Collapsible(
          open: open,
          child: Padding(
            padding: EdgeInsets.fromLTRB(widget.compact ? 12 : 44, 0, widget.compact ? 8 : 14, 8),
            child: isTool
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t('参数', 'Arguments'), style: text.labelSmall?.copyWith(color: scheme.outline)),
                    _Mono(_pretty(s.arguments)),
                    const SizedBox(height: 6),
                    Text(t('结果', 'Result'), style: text.labelSmall?.copyWith(color: scheme.outline)),
                    _Mono(s.result ?? t('运行中…', 'Running…'), maxLines: 30),
                  ])
                : Text(
                    live ? _tail(s.text) : s.text,
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
                  ),
          ),
        ),
      ],
    );
  }

  String _tail(String s) {
    final lines = s.trimRight().split('\n');
    return lines.length <= 6 ? s : lines.sublist(lines.length - 6).join('\n');
  }

  String _pretty(String args) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(args));
    } catch (_) {
      return args;
    }
  }
}

class _Mono extends StatelessWidget {
  final String text;
  final int? maxLines;
  const _Mono(this.text, {this.maxLines});
  @override
  Widget build(BuildContext context) => SelectableText(
        text,
        maxLines: maxLines,
        style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
}

class SummaryCard extends StatefulWidget {
  final Message msg;
  final VoidCallback onEdit;
  const SummaryCard({super.key, required this.msg, required this.onEdit});
  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 6, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.compress_rounded, size: 18, color: scheme.tertiary),
              const SizedBox(width: 8),
              Expanded(child: Text(t('上下文已压缩', 'Context compressed'), style: text.labelLarge?.copyWith(color: scheme.tertiary))),
              MiniIconButton(Icons.edit_outlined, t('编辑摘要', 'Edit summary'), widget.onEdit),
              TurnChevron(open: _open, color: scheme.onSurfaceVariant),
            ]),
            const SizedBox(height: 4),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Text(widget.msg.content, maxLines: _open ? null : 3, overflow: _open ? null : TextOverflow.ellipsis, style: text.bodySmall?.copyWith(height: 1.4)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// The ! / pending indicator for instant-mode compression.
class ActualStatusIcon extends StatelessWidget {
  final Message msg;
  final bool pending;
  final VoidCallback onTapFailed;
  const ActualStatusIcon({super.key, required this.msg, required this.pending, required this.onTapFailed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (pending || msg.actualStatus == 'pending') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: scheme.outline)),
      );
    }
    if (msg.actualStatus == 'failed') {
      return InkResponse(
        onTap: onTapFailed,
        radius: 16,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.error_rounded, size: 16, color: scheme.error),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

void copyText(BuildContext context, String s) {
  Clipboard.setData(ClipboardData(text: s));
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(t('已复制', 'Copied')), duration: const Duration(seconds: 1)));
}


/// `< x/n >` switcher between a message's swipes; hidden when there is only one.
class SwipeNav extends StatelessWidget {
  final int index;
  final int count;
  final bool enabled;
  final ValueChanged<int> onSwipe;
  const SwipeNav({super.key, required this.index, required this.count, required this.onSwipe, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    if (count < 2) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    Widget arrow(IconData icon, String tip, int to) => IconButton(
          tooltip: tip,
          onPressed: enabled && to >= 0 && to < count ? () => onSwipe(to) : null,
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 32),
          color: scheme.onSurfaceVariant,
          icon: Icon(icon),
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      arrow(Icons.chevron_left_rounded, t('上一个版本', 'Previous version'), index - 1),
      Text('${index + 1}/$count', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()])),
      arrow(Icons.chevron_right_rounded, t('下一个版本', 'Next version'), index + 1),
    ]);
  }
}
