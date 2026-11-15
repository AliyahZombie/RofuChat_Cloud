import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../core/i18n.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';

const _colorIcons = {
  'aws', 'baichuan', 'claude', 'cohere', 'deepseek', 'doubao', 'gemini', 'google', 'hunyuan', 'meta', 'microsoft', 'minimax', 'mistral', //
  'nvidia', 'openrouter', 'perplexity', 'qwen', 'siliconflow', 'spark', 'stepfun', 'wenxin', 'yi', 'zhipu',
};
const _monoIcons = {'anthropic', 'grok', 'moonshot', 'ollama', 'openai', 'xai'};

/// All icon keys the picker offers.
List<String> get modelIconKeys => [..._colorIcons, ..._monoIcons]..sort();

/// Client-side fallback detection mirroring the backend table.
String detectIconKey(String name) {
  final l = name.toLowerCase();
  const table = <(List<String>, String)>[
    (['claude'], 'claude'),
    (['anthropic'], 'anthropic'),
    (['gemini', 'gemma', 'learnlm'], 'gemini'),
    (['gpt', 'o1', 'o3', 'o4', 'chatgpt', 'dall-e', 'whisper', 'codex', 'openai'], 'openai'),
    (['deepseek'], 'deepseek'),
    (['qwen', 'qwq', 'tongyi'], 'qwen'),
    (['glm', 'zhipu', 'z-ai', 'bigmodel'], 'zhipu'),
    (['kimi', 'moonshot'], 'moonshot'),
    (['grok', 'x-ai'], 'grok'),
    (['llama', 'meta-'], 'meta'),
    (['mistral', 'mixtral', 'codestral', 'pixtral', 'magistral', 'devstral'], 'mistral'),
    (['doubao', 'seed-', 'volces'], 'doubao'),
    (['minimax', 'abab'], 'minimax'),
    (['ernie', 'wenxin'], 'wenxin'),
    (['hunyuan'], 'hunyuan'),
    (['yi-', '01-ai', 'lingyi'], 'yi'),
    (['command', 'cohere'], 'cohere'),
    (['phi-', 'microsoft', 'azure'], 'microsoft'),
    (['nova', 'titan', 'amazon', 'bedrock'], 'aws'),
    (['step-', 'stepfun'], 'stepfun'),
    (['baichuan'], 'baichuan'),
    (['spark', 'xfyun'], 'spark'),
    (['perplexity', 'sonar'], 'perplexity'),
    (['nemotron', 'nvidia'], 'nvidia'),
    (['openrouter'], 'openrouter'),
    (['siliconflow', 'siliconcloud'], 'siliconflow'),
    (['ollama'], 'ollama'),
  ];
  for (final (keys, icon) in table) {
    if (keys.any(l.contains)) return icon;
  }
  return '';
}

String? _assetFor(String key, Brightness b) {
  if (_colorIcons.contains(key)) return 'assets/model_icons/$key.png';
  if (_monoIcons.contains(key)) return 'assets/model_icons/${key}_${b == Brightness.dark ? 'dark' : 'light'}.png';
  return null;
}

/// Round model/provider icon; falls back to a coloured initial.
class ModelIcon extends StatelessWidget {
  final String iconKey;
  final String name;
  final double size;
  const ModelIcon({super.key, required this.iconKey, required this.name, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final key = iconKey.isNotEmpty ? iconKey : detectIconKey(name);
    final asset = _assetFor(key, Theme.of(context).brightness);
    final (bg, fg) = nameColors(name, Theme.of(context).brightness);
    Widget initial() => _Initial(name: name, size: size * 0.68, color: fg);
    // Brand artwork keeps its colours on a neutral disc; the fallback initial uses the
    // name's tonal pair.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: asset != null ? scheme.surfaceContainerHighest : bg),
      padding: EdgeInsets.all(size * 0.16),
      child: asset != null ? Image.asset(asset, fit: BoxFit.contain, errorBuilder: (_, _, _) => initial()) : initial(),
    );
  }
}

/// A deterministic tonal pair for a name: the hash picks a hue, and an M3 tonal scheme of
/// that hue supplies an accessible container / on-container pair for the brightness.
(Color, Color) nameColors(String name, Brightness b) {
  final hue = (name.hashCode % 360).abs();
  return _nameColors.putIfAbsent((hue, b), () {
    final s = ColorScheme.fromSeed(seedColor: HSLColor.fromAHSL(1, hue.toDouble(), 0.6, 0.5).toColor(), brightness: b);
    return (s.primaryContainer, s.onPrimaryContainer);
  });
}

final _nameColors = <(int, Brightness), (Color, Color)>{};

/// The initial of a name in an avatar. The size follows the avatar (a decorative, local
/// exception) on top of the titleMedium role; screen readers get the name from the
/// enclosing control instead.
class _Initial extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  const _Initial({required this.name, required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    final txt = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    return ExcludeSemantics(
      child: Center(
        child: Text(
          txt,
          textScaler: TextScaler.noScaling, // must fit its circle; the name is announced elsewhere
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: size * 0.45, height: 1, fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
  }
}

/// Character avatar from data URL / http URL / API path, with initial fallback.
class CharacterAvatar extends ConsumerWidget {
  final Character? character;
  final double size;
  const CharacterAvatar({super.key, required this.character, this.size = 32});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = character;
    final name = c?.name ?? '?';
    final (bg, fg) = nameColors(name, Theme.of(context).brightness);
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: _Initial(name: name, size: size, color: fg),
    );
    final av = c?.avatar ?? '';
    if (av.isEmpty) return fallback;
    Widget img;
    if (av.startsWith('data:')) {
      try {
        img = Image.memory(base64Decode(av.substring(av.indexOf(',') + 1)), fit: BoxFit.cover, gaplessPlayback: true, errorBuilder: (_, _, _) => fallback);
      } catch (_) {
        return fallback;
      }
    } else {
      final api = ref.watch(apiProvider);
      img = Image.network(api.authedUrl(av), fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback);
    }
    return ClipOval(child: SizedBox(width: size, height: size, child: img));
  }
}

/// Ring showing context usage, sitting between the + and send buttons. The ring itself is
/// small (22dp by default); when it is tappable it sits in a 48dp target.
class ContextRing extends StatelessWidget {
  final ContextInfo info;
  final double size;
  final double stroke;
  final VoidCallback? onTap;
  const ContextRing({super.key, required this.info, this.size = 22, this.stroke = 3, this.onTap});

  /// Spoken summary: "Context 12k of 128k tokens, 9 percent", plus the warning range.
  static String describe(ContextInfo info) {
    final pct = (info.ratio * 100).round();
    final level = info.ratio > 0.85
        ? t('，即将用尽', ', nearly full')
        : info.ratio > 0.6
            ? t('，偏高', ', high')
            : '';
    return t(
      '上下文 ${info.estimated ? '约' : ''}${fmtTokens(info.tokens)} / ${fmtTokens(info.max)} token，$pct%$level',
      'Context ${info.estimated ? 'about ' : ''}${fmtTokens(info.tokens)} of ${fmtTokens(info.max)} tokens, $pct percent$level',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = info.ratio;
    final color = r > 0.85 ? scheme.error : (r > 0.6 ? AppColors.resolve(context).warning : scheme.primary);
    final ring = CustomPaint(
      size: Size.square(size),
      painter: _RingPainter(
        ratio: r,
        color: color,
        track: scheme.outlineVariant.withValues(alpha: 0.5),
        stroke: stroke,
      ),
    );
    final box = onTap == null ? size + 8 : math.max(size + 8, kMinInteractiveDimension);
    return Tooltip(
      message: '${fmtTokens(info.tokens)} / ${fmtTokens(info.max)}',
      child: Semantics(
        button: onTap != null,
        label: describe(info),
        excludeSemantics: true,
        onTap: onTap,
        child: InkResponse(
          onTap: onTap,
          radius: box / 2,
          child: SizedBox.square(dimension: box, child: Center(child: ring)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double ratio;
  final Color color;
  final Color track;
  final double stroke;
  _RingPainter({required this.ratio, required this.color, required this.track, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, radius, p..color = track);
    if (ratio > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: radius), -math.pi / 2, 2 * math.pi * ratio.clamp(0.02, 1.0), false, p..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) => o.ratio != ratio || o.color != color || o.track != track;
}

/// "↑1.2k ↓350 ⚡800 · 5.3s"
class TokenIndicator extends StatelessWidget {
  final Usage usage;
  const TokenIndicator({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()]);
    final est = usage.estimated ? '~' : '';
    final parts = <String>[
      '↑$est${fmtTokens(usage.input)}',
      '↓$est${fmtTokens(usage.output)}',
      if (usage.cached > 0) '⚡${fmtTokens(usage.cached)}',
    ];
    final tip = [
      '${t('输入', 'Input')}: ${usage.input}',
      '${t('输出', 'Output')}: ${usage.output}',
      '${t('缓存', 'Cached')}: ${usage.cached}',
      if (usage.reasoning > 0) '${t('推理', 'Reasoning')}: ${usage.reasoning}',
      '${t('首字', 'First token')}: ${fmtDuration(usage.ttftMs)}',
      '${t('总耗时', 'Total')}: ${fmtDuration(usage.durationMs)}',
      if (usage.estimated) t('（估算值）', '(estimated)'),
    ].join('\n');
    final spoken = [
      t('输入 ${usage.estimated ? '约' : ''}${fmtTokens(usage.input)} token', 'Input ${usage.estimated ? 'about ' : ''}${fmtTokens(usage.input)} tokens'),
      t('输出 ${fmtTokens(usage.output)}', 'output ${fmtTokens(usage.output)}'),
      if (usage.cached > 0) t('缓存 ${fmtTokens(usage.cached)}', 'cached ${fmtTokens(usage.cached)}'),
      t('用时 ${fmtDuration(usage.durationMs)}', 'took ${fmtDuration(usage.durationMs)}'),
    ].join(t('，', ', '));
    return Tooltip(
      message: tip,
      triggerMode: TooltipTriggerMode.longPress,
      child: Semantics(
        label: spoken,
        excludeSemantics: true,
        child: Text('${parts.join(' ')} · ${fmtDuration(usage.durationMs)}', style: style),
      ),
    );
  }
}

/// Section header used across settings pages.
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

/// A basic M3 dialog asking to confirm an action. [ok] names the outcome ("Delete",
/// "Rename"); plain "OK" is only for acknowledgements.
Future<bool> confirm(BuildContext context, String title, {String? body, String? ok}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('取消', 'Cancel'))),
        TextButton(onPressed: () => Navigator.pop(c, true), child: Text(ok ?? t('确定', 'OK'))),
      ],
    ),
  );
  return r ?? false;
}

/// Asks for one text value. Short single-line prompts use a basic dialog; multi-line
/// editing on a compact window uses a full-screen dialog so the keyboard and large text
/// never squeeze the field (M3 full-screen dialog guidance).
Future<String?> promptText(
  BuildContext context,
  String title, {
  String initial = '',
  int maxLines = 1,
  String? hint,
  String? label,
  String? ok,
  TextInputType? keyboard,
}) async {
  final ctl = TextEditingController(text: initial);
  final okLabel = ok ?? t('保存', 'Save');
  final fullscreen = maxLines > 1 && MediaQuery.sizeOf(context).width < 600;
  final field = TextField(
    controller: ctl,
    autofocus: true,
    maxLines: fullscreen ? null : maxLines,
    minLines: fullscreen ? 6 : 1,
    keyboardType: keyboard ?? (maxLines > 1 ? TextInputType.multiline : null),
    decoration: InputDecoration(hintText: hint, labelText: label),
  );
  final r = await showDialog<String>(
    context: context,
    builder: (c) => fullscreen
        ? Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: t('取消', 'Cancel'),
                  onPressed: () => Navigator.pop(c),
                ),
                title: Text(title),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(c, ctl.text), child: Text(okLabel)),
                  const SizedBox(width: 8),
                ],
              ),
              body: ListView(padding: const EdgeInsets.all(16), children: [field]),
            ),
          )
        : AlertDialog(
            scrollable: true,
            title: Text(title),
            content: field,
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: Text(t('取消', 'Cancel'))),
              TextButton(onPressed: () => Navigator.pop(c, ctl.text), child: Text(okLabel)),
            ],
          ),
  );
  return r;
}

/// Error feedback. Errors stay until dismissed or for the M3 long duration (10s) and carry
/// a close button, so they are not missed.
void showError(BuildContext context, Object e) {
  final m = ScaffoldMessenger.maybeOf(context);
  m
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$e'), showCloseIcon: true, duration: const Duration(seconds: 10)));
}

/// Short informational feedback (M3 4s snackbar).
void showInfo(BuildContext context, String msg) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 4)));
}

/// One entry of an item's action menu.
class MenuAction {
  final String value;
  final IconData icon;
  final String label;
  final bool danger;
  const MenuAction(this.value, this.icon, this.label, {this.danger = false});
}

/// An item's action menu, dispatched by input origin (never by window width):
/// a popup at the pointer when [at] is given (secondary click, or an anchored "More"
/// button), otherwise a bottom sheet (long press, touch).
Future<String?> showActions(BuildContext context, List<MenuAction> actions, {Offset? at}) {
  final scheme = Theme.of(context).colorScheme;
  final text = Theme.of(context).textTheme;
  if (at != null) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final size = overlay?.size ?? MediaQuery.sizeOf(context);
    return showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(at.dx, at.dy, size.width - at.dx, size.height - at.dy),
      items: [
        for (final a in actions)
          PopupMenuItem(
            value: a.value,
            height: kMinInteractiveDimension,
            // M3 menu item anatomy: 24dp leading icon, 12dp gap, labelLarge text.
            child: Row(
              children: [
                Icon(a.icon, size: 24, color: a.danger ? scheme.error : scheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Flexible(child: Text(a.label, style: text.labelLarge?.copyWith(color: a.danger ? scheme.error : scheme.onSurface))),
              ],
            ),
          ),
      ],
    );
  }
  return showActionSheet<String>(
    context,
    (ctx) => [
      for (final a in actions)
        ListTile(
          leading: Icon(a.icon, color: a.danger ? scheme.error : null),
          title: Text(a.label, style: a.danger ? TextStyle(color: scheme.error) : null),
          onTap: () => Navigator.pop(ctx, a.value),
        ),
    ],
  );
}

/// A modal bottom sheet whose content always stays reachable: it scrolls when it is taller
/// than the window (short windows, watches, large text) and clears the keyboard.
Future<T?> showActionSheet<T>(BuildContext context, List<Widget> Function(BuildContext) children, {EdgeInsetsGeometry? padding}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: ListView(
        shrinkWrap: true,
        padding: padding ?? const EdgeInsets.only(bottom: 16),
        children: children(ctx),
      ),
    ),
  );
}

/// A scrolling form/settings body whose content keeps a readable width on large windows
/// (M3: fields should not span a whole large screen). The scroll area stays full-width.
class FormListView extends StatelessWidget {
  final List<Widget> children;
  final double horizontal;
  final double vertical;
  final double maxWidth;
  const FormListView({super.key, required this.children, this.horizontal = 16, this.vertical = 16, this.maxWidth = kFormMaxWidth});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final side = math.max(horizontal, (box.maxWidth - maxWidth) / 2);
          return ListView(padding: EdgeInsets.symmetric(horizontal: side, vertical: vertical), children: children);
        },
      );
}

/// A multi-field editor presented by window size: a full-screen dialog on compact widths
/// (keyboard input, M3 full-screen dialog), a scrollable basic dialog otherwise. [body]
/// gets a `setState` for local state. Returns true when the user confirmed with [ok].
Future<bool> showEditorDialog(
  BuildContext context, {
  required String title,
  required String ok,
  required Widget Function(BuildContext context, StateSetter setState) body,
  bool Function()? validate,
}) async {
  final compact = MediaQuery.sizeOf(context).width < 600;
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, set) {
        void submit() {
          if (validate == null || validate()) Navigator.pop(c, true);
          set(() {});
        }

        if (compact) {
          return Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(icon: const Icon(Icons.close), tooltip: t('取消', 'Cancel'), onPressed: () => Navigator.pop(c, false)),
                title: Text(title),
                actions: [TextButton(onPressed: submit, child: Text(ok)), const SizedBox(width: 8)],
              ),
              body: ListView(padding: const EdgeInsets.all(16), children: [body(c, set)]),
            ),
          );
        }
        return AlertDialog(
          scrollable: true,
          title: Text(title),
          content: SizedBox(width: double.maxFinite, child: body(c, set)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('取消', 'Cancel'))),
            TextButton(onPressed: submit, child: Text(ok)),
          ],
        );
      },
    ),
  );
  return r ?? false;
}

/// One entry of an [OverflowMenu].
class MenuEntry {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool danger;
  const MenuEntry(this.label, {this.icon, this.onPressed, this.danger = false});
}

/// An anchored overflow ("more") menu built from MenuAnchor + MenuItemButton (baseline M3
/// menu anatomy: 48dp items, 24dp leading icons, 4dp corners).
class OverflowMenu extends StatelessWidget {
  final List<MenuEntry> entries;
  final IconData icon;
  final String? tooltip;
  const OverflowMenu({super.key, required this.entries, this.icon = Icons.more_vert, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      menuChildren: [
        for (final e in entries)
          MenuItemButton(
            leadingIcon: e.icon == null ? null : Icon(e.icon, color: e.danger ? scheme.error : null),
            onPressed: e.onPressed,
            style: e.danger ? MenuItemButton.styleFrom(foregroundColor: scheme.error) : null,
            child: Text(e.label),
          ),
      ],
      builder: (context, menu, _) => IconButton(
        icon: Icon(icon),
        tooltip: tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      ),
    );
  }
}

/// A single-choice control that adapts to the space it gets: a SegmentedButton when every
/// label fits, otherwise a DropdownMenu (watch, narrow windows, long labels, large text).
class ChoiceField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  /// Minimum width per segment before switching to the menu.
  final double minSegmentWidth;
  const ChoiceField({super.key, required this.label, required this.value, required this.options, required this.onChanged, this.minSegmentWidth = 104});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
          if (box.maxWidth >= options.length * minSegmentWidth * scale) {
            return Semantics(
              label: label,
              container: true,
              child: SegmentedButton<T>(
                showSelectedIcon: false,
                segments: [for (final (v, l) in options) ButtonSegment(value: v, label: Text(l, maxLines: 1, overflow: TextOverflow.ellipsis))],
                selected: {value},
                onSelectionChanged: (v) => onChanged(v.first),
              ),
            );
          }
          return DropdownMenu<T>(
            label: Text(label),
            width: box.maxWidth,
            initialSelection: value,
            dropdownMenuEntries: [for (final (v, l) in options) DropdownMenuEntry(value: v, label: l)],
            onSelected: (v) {
              if (v != null) onChanged(v);
            },
          );
        },
      );
}
