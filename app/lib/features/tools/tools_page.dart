import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/builtin_tools.dart';
import '../../core/format.dart';
import '../../core/i18n.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

class ToolsPage extends ConsumerWidget {
  const ToolsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tools = ref.watch(toolsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t('本地工具', 'Local tools')), actions: [
        PopupMenuButton<String>(
          onSelected: (_) => ref.read(toolsProvider.notifier).restoreBuiltins(),
          itemBuilder: (_) => [PopupMenuItem(value: 'restore', child: Text(t('恢复内置工具', 'Restore built-in tools')))],
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ToolEditorPage(tool: LocalTool.blank()))),
        child: const Icon(Icons.add),
      ),
      body: tools.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(t('本地工具是运行在内置 QuickJS 引擎中的 JavaScript 函数，可在角色设置中为角色启用。', 'Local tools are JavaScript functions run by the embedded QuickJS engine. Enable them per character.'), textAlign: TextAlign.center),
                ),
              )
            : ListView(children: [
                for (final tool in list)
                  ListTile(
                    leading: Icon(builtinToolNames.contains(tool.name) ? Icons.casino_outlined : Icons.code_rounded, color: tool.enabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
                    title: Text(tool.name),
                    subtitle: Text(tool.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Switch(
                      value: tool.enabled,
                      onChanged: (v) => ref.read(toolsProvider.notifier).save(LocalTool(tool.json)..enabled = v),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ToolEditorPage(tool: tool))),
                  ),
              ]),
      ),
    );
  }
}

class ToolEditorPage extends ConsumerStatefulWidget {
  final LocalTool tool;
  const ToolEditorPage({super.key, required this.tool});
  @override
  ConsumerState<ToolEditorPage> createState() => _ToolEditorPageState();
}

class _ToolEditorPageState extends ConsumerState<ToolEditorPage> {
  late final LocalTool tool = LocalTool(jsonDecode(jsonEncode(widget.tool.json)) as Map<String, dynamic>);
  late final _name = TextEditingController(text: tool.name);
  late final _desc = TextEditingController(text: tool.description);
  late final _params = TextEditingController(text: const JsonEncoder.withIndent('  ').convert(tool.parameters ?? {'type': 'object', 'properties': {}}));
  late final _code = TextEditingController(text: tool.code);
  final _args = TextEditingController(text: '{}');
  String? _paramsError;
  Map<String, dynamic>? _run;
  bool _running = false;

  @override
  void dispose() {
    for (final c in [_name, _desc, _params, _code, _args]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _collect() {
    tool.name = _name.text.trim();
    tool.description = _desc.text.trim();
    tool.code = _code.text;
    try {
      tool.parameters = jsonDecode(_params.text);
      _paramsError = null;
    } catch (e) {
      setState(() => _paramsError = t('参数 Schema 不是合法 JSON', 'Parameters schema is not valid JSON'));
      return false;
    }
    if (!RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(tool.name)) {
      showError(context, t('名称只能包含字母、数字、_ 和 -', 'Name may only contain letters, digits, _ and -'));
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_collect()) return;
    try {
      await ref.read(toolsProvider.notifier).save(tool);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _test() async {
    Object args;
    try {
      args = jsonDecode(_args.text);
    } catch (_) {
      showError(context, t('测试参数不是合法 JSON', 'Test arguments are not valid JSON'));
      return;
    }
    setState(() {
      _running = true;
      _run = null;
    });
    try {
      final r = await ref.read(apiProvider).post('/api/tools/run', {'code': _code.text, 'args': args});
      setState(() => _run = Map<String, dynamic>.from(r as Map));
    } catch (e) {
      setState(() => _run = {'result': '$e', 'is_error': true, 'logs': <dynamic>[]});
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final models = ref.watch(modelsProvider).value ?? const <ModelCfg>[];
    final scheme = Theme.of(context).colorScheme;
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4);
    return Scaffold(
      appBar: AppBar(
        title: Text(tool.id.isEmpty ? t('新建工具', 'New tool') : tool.name),
        actions: [
          if (tool.id.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await confirm(context, t('删除这个工具？', 'Delete this tool?'))) {
                  await ref.read(toolsProvider.notifier).remove(tool.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          Padding(padding: const EdgeInsets.only(right: 8), child: FilledButton(onPressed: _save, child: Text(t('保存', 'Save')))),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _name, decoration: InputDecoration(labelText: t('名称（模型看到的函数名）', 'Name (function name the model sees)'))),
        const SizedBox(height: 12),
        TextField(controller: _desc, maxLines: 3, minLines: 1, decoration: InputDecoration(labelText: t('描述（告诉模型何时使用）', 'Description (tell the model when to use it)'))),
        const SizedBox(height: 12),
        TextField(
          controller: _params,
          maxLines: 10,
          minLines: 3,
          style: mono,
          decoration: InputDecoration(labelText: t('参数 JSON Schema', 'Parameters JSON Schema'), errorText: _paramsError, alignLabelWithHint: true),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _code,
            maxLines: null,
            minLines: 12,
            style: mono,
            decoration: InputDecoration(border: InputBorder.none, labelText: t('代码（定义 function main(args)）', 'Code (define function main(args))'), alignLabelWithHint: true),
          ),
        ),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t('启用', 'Enabled')), value: tool.enabled, onChanged: (v) => setState(() => tool.enabled = v)),
        SectionTitle(t('启用的模型（不选 = 所有模型）', 'Enabled for models (none = all)')),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final m in models)
            FilterChip(
              avatar: ModelIcon(iconKey: m.icon, name: m.name, size: 18),
              label: Text(m.name),
              selected: tool.models.contains(m.id),
              onSelected: (v) => setState(() => tool.models = v ? [...tool.models, m.id] : tool.models.where((x) => x != m.id).toList()),
            ),
        ]),
        SectionTitle(t('试运行', 'Test run')),
        TextField(controller: _args, style: mono, maxLines: 4, minLines: 1, decoration: InputDecoration(labelText: t('参数 JSON', 'Arguments JSON'))),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(onPressed: _running ? null : _test, icon: const Icon(Icons.play_arrow_rounded), label: Text(_running ? t('运行中…', 'Running…') : t('运行', 'Run'))),
        ),
        if (_run != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _run!['is_error'] == true ? scheme.errorContainer : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              [
                '${t('结果', 'Result')} (${fmtDuration((_run!['duration_ms'] as num?)?.toInt() ?? 0)}):',
                '${_run!['result']}',
                if (((_run!['logs'] as List?) ?? const []).isNotEmpty) '\nconsole:\n${(_run!['logs'] as List).join('\n')}',
              ].join('\n'),
              style: mono,
            ),
          ),
        const SizedBox(height: 40),
      ]),
    );
  }
}
