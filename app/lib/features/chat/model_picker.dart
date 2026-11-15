import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

/// Bottom sheet listing models grouped by provider. Returns the chosen Model.id,
/// '' for "use default" (when [allowDefault]), or null when dismissed.
Future<String?> showModelPicker(BuildContext context, WidgetRef ref, {String? selected, bool allowDefault = false, String? title}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    // Keeps the search field above the keyboard; the list scrolls.
    builder: (c) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (c, scroll) => _ModelList(scroll: scroll, selected: selected, allowDefault: allowDefault, title: title),
      ),
    ),
  );
}

class _ModelList extends ConsumerStatefulWidget {
  final ScrollController scroll;
  final String? selected;
  final bool allowDefault;
  final String? title;
  const _ModelList({required this.scroll, required this.selected, required this.allowDefault, this.title});
  @override
  ConsumerState<_ModelList> createState() => _ModelListState();
}

class _ModelListState extends ConsumerState<_ModelList> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final models = ref.watch(modelsProvider).value ?? const <ModelCfg>[];
    final providers = ref.watch(providersProvider).value ?? const <ProviderCfg>[];
    final scheme = Theme.of(context).colorScheme;
    final q = _q.toLowerCase();
    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.title != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(widget.title!, style: Theme.of(context).textTheme.titleMedium)),
          TextField(
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: t('搜索模型', 'Search models')),
            onChanged: (v) => setState(() => _q = v),
          ),
        ]),
      ),
      if (widget.allowDefault)
        ListTile(
          leading: const Icon(Icons.settings_suggest_outlined),
          title: Text(t('使用默认模型', 'Use default model')),
          selected: (widget.selected ?? '').isEmpty,
          trailing: (widget.selected ?? '').isEmpty ? Icon(Icons.check, color: scheme.primary) : null,
          onTap: () => Navigator.pop(context, ''),
        ),
    ];
    for (final p in providers) {
      final ms = models.where((m) => m.providerId == p.id && (q.isEmpty || m.name.toLowerCase().contains(q) || m.modelId.toLowerCase().contains(q))).toList();
      if (ms.isEmpty) continue;
      children.add(SectionTitle(p.name));
      for (final m in ms) {
        children.add(ListTile(
          selected: m.id == widget.selected,
          leading: ModelIcon(iconKey: m.icon, name: m.name, size: 40),
          title: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: ModelTags(model: m),
          trailing: m.id == widget.selected ? Icon(Icons.check, color: scheme.primary) : null,
          onTap: () => Navigator.pop(context, m.id),
        ));
      }
    }
    if (models.isEmpty) {
      children.add(Padding(padding: const EdgeInsets.all(24), child: Text(t('还没有模型，请先在设置中添加模型供应商。', 'No models yet. Add a provider in Settings first.'))));
    }
    return ListView(controller: widget.scroll, children: children);
  }
}

class ModelTags extends StatelessWidget {
  final ModelCfg model;
  const ModelTags({super.key, required this.model});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelSmall;
    // Non-interactive metadata: a tiny glyph (documented exception) beside a readable label.
    Widget tag(IconData i, String s) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            ExcludeSemantics(child: Icon(i, size: 14, color: scheme.primary)),
            const SizedBox(width: 4),
            Text(s, style: style?.copyWith(color: scheme.onSurfaceVariant)),
          ]),
        );
    return Wrap(children: [
      if (model.contextLength > 0) tag(Icons.notes, model.contextLength >= 1000 ? '${(model.contextLength / 1000).round()}k' : '${model.contextLength}'),
      if (model.vision) tag(Icons.image_outlined, t('视觉', 'Vision')),
      if (model.toolCall) tag(Icons.build_outlined, t('工具', 'Tools')),
      if (model.reasoning) tag(Icons.lightbulb_outline, t('推理', 'Reasoning')),
    ]);
  }
}

/// Change the model of a character from the chat header / input bar.
Future<void> pickModelForCharacter(BuildContext context, WidgetRef ref, Character ch) async {
  final id = await showModelPicker(context, ref, selected: ch.modelId, allowDefault: true, title: t('${ch.name} 的对话模型', 'Model for ${ch.name}'));
  if (id == null) return;
  final c = Character(ch.json)..modelId = id;
  try {
    await ref.read(charactersProvider.notifier).save(c);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}
