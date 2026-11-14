import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n.dart';
import '../../core/model_catalog.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../chat/model_picker.dart';

class ProvidersPage extends ConsumerWidget {
  const ProvidersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(providersProvider);
    final models = ref.watch(modelsProvider).value ?? const <ModelCfg>[];
    return Scaffold(
      appBar: AppBar(title: Text(t('模型供应商', 'Model providers'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProviderEditorPage(provider: ProviderCfg.blank()))),
        icon: const Icon(Icons.add),
        label: Text(t('添加供应商', 'Add provider')),
      ),
      body: providers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(child: Text(t('添加一个 OpenAI 兼容或 Responses API 供应商开始使用', 'Add an OpenAI-compatible or Responses API provider to start')))
            : ListView(children: [
                for (final p in list)
                  ListTile(
                    leading: ModelIcon(iconKey: p.icon, name: p.name, size: 36),
                    title: Text(p.name),
                    subtitle: Text('${p.kind == 'responses' ? 'Responses API' : 'OpenAI Compatible'} · ${models.where((m) => m.providerId == p.id).length} ${t('个模型', 'models')}'),
                    trailing: p.enabled ? const Icon(Icons.chevron_right) : Text(t('已停用', 'Disabled')),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProviderEditorPage(provider: p))),
                  ),
              ]),
      ),
    );
  }
}

class ProviderEditorPage extends ConsumerStatefulWidget {
  final ProviderCfg provider;
  const ProviderEditorPage({super.key, required this.provider});
  @override
  ConsumerState<ProviderEditorPage> createState() => _ProviderEditorPageState();
}

class _ProviderEditorPageState extends ConsumerState<ProviderEditorPage> {
  late ProviderCfg p = ProviderCfg(jsonDecode(jsonEncode(widget.provider.json)) as Map<String, dynamic>);
  late final _name = TextEditingController(text: p.name);
  late final _url = TextEditingController(text: p.baseUrl);
  late final _key = TextEditingController(text: p.apiKey);
  late final _headers = TextEditingController(text: p.headers.entries.map((e) => '${e.key}: ${e.value}').join('\n'));
  bool _showKey = false;
  bool _busy = false;
  String? _test;

  void _collect() {
    p.name = _name.text.trim();
    p.baseUrl = _url.text.trim();
    p.apiKey = _key.text.trim();
    final m = <String, String>{};
    for (final line in _headers.text.split('\n')) {
      final i = line.indexOf(':');
      if (i > 0) m[line.substring(0, i).trim()] = line.substring(i + 1).trim();
    }
    p.headers = m;
  }

  Future<bool> _save({bool pop = true}) async {
    _collect();
    if (p.name.isEmpty || p.baseUrl.isEmpty) {
      showError(context, t('请填写名称和 Base URL', 'Name and Base URL are required'));
      return false;
    }
    setState(() => _busy = true);
    try {
      final saved = await ref.read(providersProvider.notifier).save(p);
      setState(() => p = ProviderCfg(saved.json));
      if (pop && mounted) Navigator.pop(context);
      return true;
    } catch (e) {
      if (mounted) showError(context, e);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _fetchModels() async {
    if (p.id.isEmpty && !await _save(pop: false)) return;
    setState(() => _busy = true);
    try {
      final r = await ref.read(apiProvider).post('/api/providers/${p.id}/remote_models');
      final remote = ((r as List?) ?? const []).map((e) => ModelCfg(Map<String, dynamic>.from(e as Map))).toList();
      final catalog = await _catalog();
      if (catalog != null) {
        for (final m in remote) {
          catalog.apply(m);
        }
      }
      if (!mounted) return;
      final existing = (ref.read(modelsProvider).value ?? const <ModelCfg>[]).where((m) => m.providerId == p.id).map((m) => m.modelId).toSet();
      final chosen = await showModalBottomSheet<List<ModelCfg>>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (c) => _RemoteModelsSheet(models: remote, existing: existing),
      );
      if (chosen != null && chosen.isNotEmpty) {
        for (final m in chosen) {
          m.providerId = p.id;
        }
        await ref.read(modelsProvider.notifier).addMany(chosen);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addManual() async {
    if (p.id.isEmpty && !await _save(pop: false)) return;
    if (!mounted) return;
    final id = await promptText(context, t('模型 ID', 'Model ID'), hint: 'gpt-4o-mini');
    if (id == null || id.trim().isEmpty) return;
    try {
      final j = await ref.read(apiProvider).post('/api/models/detect', {'model_id': id.trim()});
      final m = ModelCfg(Map<String, dynamic>.from(j as Map))..providerId = p.id;
      (await _catalog())?.apply(m);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ModelEditorPage(model: m)));
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  /// models.dev metadata; null (silently) when it cannot be downloaded and nothing is cached.
  Future<ModelCatalog?> _catalog({bool force = false}) async {
    try {
      return await ModelCatalog.load(ref.read(storeProvider), force: force);
    } catch (_) {
      return null;
    }
  }

  /// Re-reads context length, max output, capabilities and icon of this provider's models from models.dev.
  Future<void> _syncCatalog() async {
    final models = (ref.read(modelsProvider).value ?? const <ModelCfg>[]).where((m) => m.providerId == p.id).toList();
    setState(() => _busy = true);
    try {
      final catalog = await ModelCatalog.load(ref.read(storeProvider), force: true);
      final changed = <ModelCfg>[];
      for (final m in models) {
        final copy = ModelCfg(jsonDecode(jsonEncode(m.json)) as Map<String, dynamic>);
        if (catalog.apply(copy)) changed.add(copy);
      }
      for (final m in changed) {
        await ref.read(apiProvider).put('/api/models/${m.id}', m.toJson());
      }
      await ref.read(modelsProvider.notifier).refresh();
      if (mounted) {
        showInfo(context, t('已从 models.dev 更新 ${changed.length}/${models.length} 个模型', 'Updated ${changed.length}/${models.length} models from models.dev'));
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _testProvider([ModelCfg? pick]) async {
    final models = (ref.read(modelsProvider).value ?? const <ModelCfg>[]).where((m) => m.providerId == p.id).toList();
    if (models.isEmpty) {
      showError(context, t('先添加一个模型', 'Add a model first'));
      return;
    }
    final model = pick ?? models.first;
    setState(() {
      _busy = true;
      _test = null;
    });
    try {
      // The backend expects the upstream model name, not our config id.
      final r = await ref.read(apiProvider).post('/api/providers/${p.id}/test', {'model_id': model.modelId}) as Map;
      _test = r['ok'] == true
          ? t('${model.name} 成功 · ${r['latency_ms']}ms · ${r['reply']}', '${model.name} OK · ${r['latency_ms']}ms · ${r['reply']}')
          : '${model.name} ${t('失败', 'failed')}: ${r['error']}';
    } catch (e) {
      _test = '${model.name} ${t('失败', 'failed')}: $e';
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final models = (ref.watch(modelsProvider).value ?? const <ModelCfg>[]).where((m) => m.providerId == p.id).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(p.id.isEmpty ? t('添加供应商', 'Add provider') : p.name),
        actions: [
          if (p.id.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await confirm(context, t('删除供应商及其所有模型？', 'Delete this provider and its models?'))) {
                  await ref.read(providersProvider.notifier).remove(p.id);
                  await ref.read(modelsProvider.notifier).refresh();
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          Padding(padding: const EdgeInsets.only(right: 8), child: FilledButton(onPressed: _busy ? null : () => _save(), child: Text(t('保存', 'Save')))),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _name, decoration: InputDecoration(labelText: t('名称', 'Name'), hintText: 'OpenRouter')),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [ButtonSegment(value: 'openai', label: Text('OpenAI Compatible')), ButtonSegment(value: 'responses', label: Text('Responses API'))],
          selected: {p.kind},
          onSelectionChanged: (v) => setState(() => p.kind = v.first),
        ),
        const SizedBox(height: 12),
        TextField(controller: _url, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Base URL', hintText: 'https://api.openai.com/v1')),
        const SizedBox(height: 12),
        TextField(
          controller: _key,
          obscureText: !_showKey,
          decoration: InputDecoration(
            labelText: 'API Key',
            suffixIcon: IconButton(icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showKey = !_showKey)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(controller: _headers, maxLines: 3, minLines: 1, decoration: InputDecoration(labelText: t('额外请求头（每行 Key: Value）', 'Extra headers (one "Key: Value" per line)'))),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t('启用', 'Enabled')), value: p.enabled, onChanged: (v) => setState(() => p.enabled = v)),
        if (_busy) const LinearProgressIndicator(),
        if (_test != null) Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(_test!, style: Theme.of(context).textTheme.bodySmall)),
        Row(children: [
          Expanded(child: Text(t('模型（${models.length}）', 'Models (${models.length})'), style: Theme.of(context).textTheme.titleMedium)),
          IconButton(
            tooltip: t('从 models.dev 更新模型信息', 'Update model info from models.dev'),
            onPressed: _busy || models.isEmpty ? null : _syncCatalog,
            icon: const Icon(Icons.auto_fix_high_outlined),
          ),
          if (models.length > 1)
            PopupMenuButton<ModelCfg>(
              enabled: !_busy,
              tooltip: t('选择模型测试', 'Pick a model to test'),
              onSelected: _testProvider,
              itemBuilder: (_) => [for (final m in models) PopupMenuItem(value: m, child: Text(m.name))],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.network_check, size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(t('测试', 'Test'), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
                ]),
              ),
            )
          else
            TextButton.icon(onPressed: _busy ? null : () => _testProvider(), icon: const Icon(Icons.network_check), label: Text(t('测试', 'Test'))),
        ]),
        Wrap(spacing: 8, children: [
          FilledButton.tonalIcon(onPressed: _busy ? null : _fetchModels, icon: const Icon(Icons.cloud_download_outlined), label: Text(t('获取模型列表', 'Fetch models'))),
          OutlinedButton.icon(onPressed: _busy ? null : _addManual, icon: const Icon(Icons.add), label: Text(t('手动添加', 'Add manually'))),
        ]),
        const SizedBox(height: 8),
        for (final m in models)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ModelIcon(iconKey: m.icon, name: m.name, size: 32),
            title: Text(m.name),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (m.name != m.modelId) Text(m.modelId, style: Theme.of(context).textTheme.labelSmall),
              ModelTags(model: m),
            ]),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref.read(modelsProvider.notifier).remove(m.id),
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ModelEditorPage(model: m))),
          ),
        const SizedBox(height: 60),
      ]),
    );
  }
}

class _RemoteModelsSheet extends StatefulWidget {
  final List<ModelCfg> models;
  final Set<String> existing;
  const _RemoteModelsSheet({required this.models, required this.existing});
  @override
  State<_RemoteModelsSheet> createState() => _RemoteModelsSheetState();
}

class _RemoteModelsSheetState extends State<_RemoteModelsSheet> {
  final Set<String> _sel = {};
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final q = _q.toLowerCase();
    final list = widget.models.where((m) => q.isEmpty || m.modelId.toLowerCase().contains(q) || m.name.toLowerCase().contains(q)).toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (c, scroll) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: t('搜索（共 ${widget.models.length} 个）', 'Search (${widget.models.length})')), onChanged: (v) => setState(() => _q = v))),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _sel.isEmpty ? null : () => Navigator.pop(context, widget.models.where((m) => _sel.contains(m.modelId)).toList()),
              child: Text(t('添加 ${_sel.length}', 'Add ${_sel.length}')),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            controller: scroll,
            itemCount: list.length,
            itemBuilder: (c, i) {
              final m = list[i];
              final have = widget.existing.contains(m.modelId);
              return CheckboxListTile(
                dense: true,
                value: have || _sel.contains(m.modelId),
                onChanged: have ? null : (v) => setState(() => v == true ? _sel.add(m.modelId) : _sel.remove(m.modelId)),
                secondary: ModelIcon(iconKey: m.icon, name: m.name, size: 28),
                title: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: ModelTags(model: m),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class ModelEditorPage extends ConsumerStatefulWidget {
  final ModelCfg model;
  const ModelEditorPage({super.key, required this.model});
  @override
  ConsumerState<ModelEditorPage> createState() => _ModelEditorPageState();
}

class _ModelEditorPageState extends ConsumerState<ModelEditorPage> {
  late final ModelCfg m = ModelCfg(jsonDecode(jsonEncode(widget.model.json)) as Map<String, dynamic>);
  late final _id = TextEditingController(text: m.modelId);
  late final _name = TextEditingController(text: m.name);
  late final _ctx = TextEditingController(text: '${m.contextLength}');
  late final _out = TextEditingController(text: '${m.maxOutput}');

  Future<void> _save() async {
    m.modelId = _id.text.trim();
    m.name = _name.text.trim().isEmpty ? m.modelId : _name.text.trim();
    m.contextLength = int.tryParse(_ctx.text.trim()) ?? 0;
    m.maxOutput = int.tryParse(_out.text.trim()) ?? 0;
    try {
      await ref.read(modelsProvider.notifier).save(m);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _fromCatalog() async {
    try {
      final catalog = await ModelCatalog.load(ref.read(storeProvider));
      m.modelId = _id.text.trim();
      if (!catalog.apply(m, overwriteIcon: true)) {
        if (mounted) showInfo(context, t('models.dev 里没有找到这个模型', 'Not found on models.dev'));
        return;
      }
      setState(() {
        _ctx.text = '${m.contextLength}';
        _out.text = '${m.maxOutput}';
      });
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(m.id.isEmpty ? t('添加模型', 'Add model') : m.name),
        actions: [
          IconButton(tooltip: t('从 models.dev 填充', 'Fill from models.dev'), onPressed: _fromCatalog, icon: const Icon(Icons.auto_fix_high_outlined)),
          Padding(padding: const EdgeInsets.only(right: 8), child: FilledButton(onPressed: _save, child: Text(t('保存', 'Save')))),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _id, decoration: InputDecoration(labelText: t('模型 ID（发送给 API）', 'Model ID (sent to the API)'))),
        const SizedBox(height: 12),
        TextField(controller: _name, decoration: InputDecoration(labelText: t('显示名', 'Display name'))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: _ctx, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('上下文长度', 'Context length')))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _out, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('最大输出（0=未知）', 'Max output (0=unknown)')))),
        ]),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.image_outlined), title: Text(t('多模态（图片输入）', 'Vision (image input)')), value: m.vision, onChanged: (v) => setState(() => m.vision = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.build_outlined), title: Text(t('工具调用', 'Tool calling')), value: m.toolCall, onChanged: (v) => setState(() => m.toolCall = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.lightbulb_outline), title: Text(t('推理 / 思考', 'Reasoning')), value: m.reasoning, onChanged: (v) => setState(() => m.reasoning = v)),
        SectionTitle(t('图标', 'Icon')),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final k in ['', ...modelIconKeys])
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () => setState(() => m.icon = k),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: m.icon == k ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2)),
                child: Tooltip(message: k.isEmpty ? t('自动', 'Auto') : k, child: ModelIcon(iconKey: k.isEmpty ? '-' : k, name: k.isEmpty ? m.name : k, size: 34)),
              ),
            ),
        ]),
      ]),
    );
  }
}
