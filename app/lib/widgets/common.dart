import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../core/i18n.dart';
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.surfaceContainerHighest),
      padding: EdgeInsets.all(size * 0.16),
      child: asset != null
          ? Image.asset(asset, fit: BoxFit.contain, errorBuilder: (_, _, _) => _Initial(name: name, size: size))
          : _Initial(name: name, size: size),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  final double size;
  const _Initial({required this.name, required this.size});
  @override
  Widget build(BuildContext context) {
    final txt = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    final hue = (name.hashCode % 360).abs().toDouble();
    return Center(
      child: Text(txt, style: TextStyle(fontSize: size * 0.5, fontWeight: FontWeight.w700, color: HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor())),
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
    final scheme = Theme.of(context).colorScheme;
    final name = c?.name ?? '?';
    final hue = (name.hashCode % 360).abs().toDouble();
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: HSLColor.fromAHSL(1, hue, 0.45, Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.75).toColor()),
      child: Text(name.isEmpty ? '?' : name.characters.first.toUpperCase(), style: TextStyle(fontSize: size * 0.45, color: scheme.onSurface, fontWeight: FontWeight.w600)),
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

/// Ring showing context usage, sitting between the + and send buttons.
class ContextRing extends StatelessWidget {
  final ContextInfo info;
  final double size;
  final double stroke;
  final VoidCallback? onTap;
  const ContextRing({super.key, required this.info, this.size = 22, this.stroke = 3, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = info.ratio;
    final color = r > 0.85 ? scheme.error : (r > 0.6 ? Colors.orange : scheme.primary);
    return Tooltip(
      message: '${fmtTokens(info.tokens)} / ${fmtTokens(info.max)}',
      child: InkResponse(
        onTap: onTap,
        radius: size,
        child: SizedBox(
          width: size + 8,
          height: size + 8,
          child: Center(
            child: CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(
                ratio: r,
                color: color,
                track: scheme.outlineVariant.withValues(alpha: 0.5),
                stroke: stroke,
              ),
            ),
          ),
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
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline, fontFeatures: const [FontFeature.tabularFigures()]);
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
    return Tooltip(
      message: tip,
      triggerMode: TooltipTriggerMode.longPress,
      child: Text('${parts.join(' ')} · ${fmtDuration(usage.durationMs)}', style: style),
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

Future<bool> confirm(BuildContext context, String title, {String? body, String? ok}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('取消', 'Cancel'))),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(ok ?? t('确定', 'OK'))),
      ],
    ),
  );
  return r ?? false;
}

Future<String?> promptText(BuildContext context, String title, {String initial = '', int maxLines = 1, String? hint}) async {
  final ctl = TextEditingController(text: initial);
  final r = await showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 480,
        child: TextField(controller: ctl, autofocus: true, maxLines: maxLines, minLines: 1, decoration: InputDecoration(hintText: hint)),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text(t('取消', 'Cancel'))),
        FilledButton(onPressed: () => Navigator.pop(c, ctl.text), child: Text(t('确定', 'OK'))),
      ],
    ),
  );
  return r;
}

void showError(BuildContext context, Object e) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text('$e')));
}

void showInfo(BuildContext context, String msg) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(msg)));
}
