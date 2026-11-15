import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/builtin_tools.dart';
import '../../core/format.dart';
import '../../core/i18n.dart';
import '../../core/theme.dart';
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
        OverflowMenu(entries: [
          MenuEntry(t('恢复内置工具', 'Restore built-in tools'), icon: Icons.restore_rounded, onPressed: () => ref.read(toolsProvider.notifier).restoreBuiltins()),
        ]),
      ]),
      floatingActionButton: FloatingActionButton(
        tooltip: t('新建工具', 'New tool'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ToolEditorPage(tool: LocalTool.blank()))),
        child: const Icon(Icons.add_rounded),
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
                    leading: Icon(builtinToolNames.contains(tool.name) ? Icons.casino_rounded : Icons.code_rounded, color: tool.enabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
                    title: Text(tool.name),
                    subtitle: Text(tool.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                    // Immediate setting: a switch is the right control here.
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
  String? _nameError;
  Map<String, dynamic>? _run;
  bool _running = false;

  /// The tool list is a summary without code (GET /api/tools?summary=1); the editor
  /// fetches the full tool. Until it arrives, saving leaves the stored code untouched.
  late bool _codeLoaded = tool.json.containsKey('code') || tool.id.isEmpty;
  String? _codeError;

  @override
  void initState() {
    super.initState();
    tool.json.remove('code_chars');
    if (!_codeLoaded) _loadCode();
  }

  Future<void> _loadCode() async {
    try {
      final j = await ref.read(apiProvider).get('/api/tools/${tool.id}');
      if (!mounted) return;
      final code = (j is Map ? j['code'] : null) as String? ?? '';
      setState(() {
        _code.text = code;
        _codeLoaded = true;
        _codeError = null;
      });
    } catch (e) {
      if (mounted) setState(() => _codeError = '$e');
    }
  }

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
    if (_codeLoaded) {
      tool.code = _code.text;
    } else {
      tool.json.remove('code');
    }
    try {
      tool.parameters = jsonDecode(_params.text);
      _paramsError = null;
    } catch (e) {
      setState(() => _paramsError = t('参数 Schema 不是合法 JSON', 'Parameters schema is not valid JSON'));
      return false;
    }
    if (!RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(tool.name)) {
      setState(() => _nameError = t('名称只能包含字母、数字、_ 和 -（1–64 个）', 'Use 1–64 letters, digits, _ or -'));
      return false;
    }
    setState(() => _nameError = null);
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
    final mono = AppTypography.code(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(tool.id.isEmpty ? t('新建工具', 'New tool') : tool.name),
        actions: [
          if (tool.id.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: t('删除工具', 'Delete tool'),
              onPressed: () async {
                if (await confirm(context, t('删除这个工具？', 'Delete this tool?'), ok: t('删除', 'Delete'))) {
                  await ref.read(toolsProvider.notifier).remove(tool.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          Padding(padding: const EdgeInsets.only(right: 8), child: FilledButton(onPressed: _save, child: Text(t('保存', 'Save')))),
        ],
      ),
      body: FormListView(children: [
        TextField(controller: _name, decoration: InputDecoration(labelText: t('名称（模型看到的函数名）', 'Name (function name the model sees)'), errorText: _nameError)),
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
        // A conventional filled M3 field: focus, hover and error states come from the theme.
        TextField(
          controller: _code,
          enabled: _codeLoaded,
          maxLines: null,
          minLines: 12,
          style: mono,
          decoration: InputDecoration(
            hintText: _codeLoaded ? null : t('正在加载代码…', 'Loading code…'),
            errorText: _codeError,
            filled: true,
            fillColor: scheme.surfaceContainerHigh,
            border: const UnderlineInputBorder(),
            labelText: t('代码（定义 function main(args)）', 'Code (define function main(args))'),
            alignLabelWithHint: true,
          ),
        ),
        // Saved with the form, so a checkbox (M3: switches act immediately).
        CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(t('启用', 'Enabled')), value: tool.enabled, onChanged: (v) => setState(() => tool.enabled = v ?? false)),
        SectionTitle(t('启用的模型（不选 = 所有模型）', 'Enabled for models (none = all)')),
        Wrap(spacing: 8, runSpacing: 8, children: [
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
            padding: const EdgeInsets.all(12),
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
              // Paired foreground for the container role.
              style: mono.copyWith(color: _run!['is_error'] == true ? scheme.onErrorContainer : scheme.onSurface),
            ),
          ),
        const SizedBox(height: 40),
      ]),
    );
  }
}
