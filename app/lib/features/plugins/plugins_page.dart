import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/i18n.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

/// What each coarse permission group allows (docs/api.md, Plugins).
String permissionHelp(String label) {
  final name = label.split(' ').first;
  return switch (name) {
    'read' => t('读取对话、角色卡、上下文、消息和当前角色记忆', 'Read the conversation, character card, context, messages and memories'),
    'write' => t('修改、插入消息和 swipe，修改记忆', 'Edit and insert messages and swipes, edit memories'),
    'storage' => t('使用插件自己的 KV 数据库', 'Use its own key-value storage'),
    'hooks' => t('在发送、工具调用、回复完成时运行并修改参数', 'Run on send, tool calls and finished replies, and change their parameters'),
    'send' => t('替你发送消息并触发回复', 'Send messages for you and trigger replies'),
    'ui' => t('弹出提示、通知和对话框', 'Show toasts, notifications and dialogs'),
    'network' => t('联网（可以把读到的数据发出去）', 'Network access (can send out what it reads)'),
    _ => '',
  };
}

/// Shows the declared permissions before enabling; true when the user accepts.
Future<bool> confirmPluginPermissions(BuildContext context, Plugin p) async {
  final perms = p.permissionLabels;
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.extension_rounded),
      title: Text(t('启用「${p.name}」？', 'Enable "${p.name}"?')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(perms.isEmpty ? t('这个插件没有声明任何权限。', 'This plugin declares no permissions.') : t('这个插件需要以下权限：', 'This plugin asks for:')),
            const SizedBox(height: 8),
            for (final l in perms)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(l),
                subtitle: permissionHelp(l).isEmpty ? null : Text(permissionHelp(l)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('取消', 'Cancel'))),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('启用', 'Enable'))),
      ],
    ),
  );
  return r ?? false;
}

class PluginsPage extends ConsumerWidget {
  const PluginsPage({super.key});

  Future<void> _toggle(BuildContext context, WidgetRef ref, Plugin p, bool v) async {
    if (v && !await confirmPluginPermissions(context, p)) return;
    try {
      await ref.read(pluginsProvider.notifier).setEnabled(p.id, v);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugins = ref.watch(pluginsProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t('插件', 'Plugins'))),
      floatingActionButton: FloatingActionButton(
        tooltip: t('新建插件', 'New plugin'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PluginEditorPage(plugin: Plugin.blank()))),
        child: const Icon(Icons.add_rounded),
      ),
      body: plugins.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (all) {
          final list = all;
          return ListView(children: [
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  t('插件是运行在服务端 QuickJS 中的 JS 模块：可以注册工具、加号菜单按钮和发送/回复 hook，读写消息、记忆和自己的数据库。启用后在角色设置的「工具」页挂到角色上。',
                      'Plugins are JS modules run by the server\'s QuickJS: they can register tools, + menu buttons and send/reply hooks, and read and write messages, memories and their own storage. Attach them to a character in its Tools tab.'),
                  textAlign: TextAlign.center,
                ),
              ),
            for (final p in list)
              ListTile(
                leading: Icon(Icons.extension_rounded, color: p.enabled ? scheme.primary : scheme.onSurfaceVariant),
                title: Text(p.name),
                subtitle: Text(
                  [
                    if (p.description.isNotEmpty) p.description,
                    'v${p.version}',
                    if (p.toolCount > 0) t('${p.toolCount} 个工具', '${p.toolCount} tools'),
                    if (p.menuCount > 0) t('${p.menuCount} 个菜单', '${p.menuCount} menus'),
                    if (p.hookNames.isNotEmpty) p.hookNames.join(', '),
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Switch(value: p.enabled, onChanged: (v) => _toggle(context, ref, p, v)),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PluginEditorPage(plugin: p))),
              ),
            const SizedBox(height: 80),
          ]);
        },
      ),
    );
  }
}

class PluginEditorPage extends ConsumerStatefulWidget {
  final Plugin plugin;
  const PluginEditorPage({super.key, required this.plugin});
  @override
  ConsumerState<PluginEditorPage> createState() => _PluginEditorPageState();
}

class _PluginEditorPageState extends ConsumerState<PluginEditorPage> {
  late final Plugin p = Plugin(jsonDecode(jsonEncode(widget.plugin.json)) as Map<String, dynamic>);
  late final _name = TextEditingController(text: p.name);
  late final _version = TextEditingController(text: p.version);
  late final _desc = TextEditingController(text: p.description);
  late final _manifest = TextEditingController(text: const JsonEncoder.withIndent('  ').convert(p.manifest));
  late final _code = TextEditingController(text: p.code);
  late bool _codeLoaded = p.hasCode || p.id.isEmpty;
  String? _codeError, _manifestError, _nameError;
  bool _saving = false;

  /// Storage usage of a saved plugin (GET /api/plugins/{id}/storage).
  Map<String, dynamic>? _storage;

  @override
  void initState() {
    super.initState();
    p.json.remove('code_chars');
    if (p.id.isNotEmpty) {
      if (!_codeLoaded) _load();
      _loadStorage();
    }
  }

  Future<void> _load() async {
    try {
      final full = await ref.read(pluginsProvider.notifier).full(p.id);
      if (!mounted) return;
      setState(() {
        _code.text = full.code;
        _codeLoaded = true;
        _codeError = null;
      });
    } catch (e) {
      if (mounted) setState(() => _codeError = '$e');
    }
  }

  Future<void> _loadStorage() async {
    try {
      final j = await ref.read(apiProvider).get('/api/plugins/${p.id}/storage');
      if (mounted && j is Map) setState(() => _storage = Map<String, dynamic>.from(j));
    } catch (_) {}
  }

  Future<void> _clearStorage([String? table]) async {
    final ok = await confirm(
      context,
      table == null ? t('清空这个插件的全部数据？', 'Clear all of this plugin\'s data?') : t('清空数据表「$table」？', 'Clear table "$table"?'),
      ok: t('清空', 'Clear'),
    );
    if (!ok) return;
    try {
      await ref.read(apiProvider).delete(table == null ? '/api/plugins/${p.id}/storage' : '/api/plugins/${p.id}/storage/${Uri.encodeComponent(table)}');
      await _loadStorage();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _version, _desc, _manifest, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _collect() {
    p.name = _name.text.trim();
    p.version = _version.text.trim().isEmpty ? '1' : _version.text.trim();
    p.description = _desc.text.trim();
    if (_codeLoaded) {
      p.code = _code.text;
    } else {
      p.json.remove('code');
    }
    if (p.name.isEmpty) {
      setState(() => _nameError = t('请填写名称', 'Name is required'));
      return false;
    }
    try {
      final m = jsonDecode(_manifest.text);
      if (m is! Map) throw const FormatException();
      p.manifest = Map<String, dynamic>.from(m);
    } catch (_) {
      setState(() => _manifestError = t('Manifest 不是合法的 JSON 对象', 'Manifest is not a valid JSON object'));
      return false;
    }
    setState(() {
      _nameError = null;
      _manifestError = null;
    });
    return true;
  }

  Future<void> _save() async {
    if (!_collect()) return;
    setState(() => _saving = true);
    try {
      final wantEnabled = p.enabled;
      var saved = await ref.read(pluginsProvider.notifier).save(p);
      // A changed permission list disables the plugin on the server; the user already
      // confirmed the list when switching it on here, so grant it again.
      if (wantEnabled && !saved.enabled) saved = await ref.read(pluginsProvider.notifier).setEnabled(saved.id, true);
      ref.invalidate(pluginMenusProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _setEnabled(bool v) async {
    if (v) {
      if (!_collect()) return;
      if (!await confirmPluginPermissions(context, p)) return;
    }
    setState(() => p.enabled = v);
  }

  @override
  Widget build(BuildContext context) {
    final models = ref.watch(modelsProvider).value ?? const <ModelCfg>[];
    final scheme = Theme.of(context).colorScheme;
    final mono = AppTypography.code(context);
    final storage = _storage;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.id.isEmpty ? t('新建插件', 'New plugin') : p.name),
        actions: [
          if (p.id.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: t('删除插件', 'Delete plugin'),
              onPressed: () async {
                if (await confirm(context, t('删除这个插件？', 'Delete this plugin?'), body: t('它的数据库也会一起删除。', 'Its stored data is deleted too.'), ok: t('删除', 'Delete'))) {
                  await ref.read(pluginsProvider.notifier).remove(p.id);
                  ref.invalidate(pluginMenusProvider);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(onPressed: _saving ? null : _save, child: Text(t('保存', 'Save'))),
          ),
        ],
      ),
      body: FormListView(children: [
        TextField(controller: _name, decoration: InputDecoration(labelText: t('名称', 'Name'), errorText: _nameError)),
        const SizedBox(height: 12),
        Row(children: [
          SizedBox(width: 120, child: TextField(controller: _version, decoration: InputDecoration(labelText: t('版本', 'Version')))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _desc, decoration: InputDecoration(labelText: t('描述', 'Description')))),
        ]),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t('启用', 'Enabled')),
          subtitle: p.enabled && p.grantedLabels.isNotEmpty ? Text(t('已授权：${p.grantedLabels.join(', ')}', 'Granted: ${p.grantedLabels.join(', ')}')) : null,
          value: p.enabled,
          onChanged: (v) => _setEnabled(v ?? false),
        ),
        SectionTitle(t('Manifest（权限、工具、hook、菜单）', 'Manifest (permissions, tools, hooks, menus)')),
        TextField(
          controller: _manifest,
          maxLines: 16,
          minLines: 6,
          style: mono,
          decoration: InputDecoration(
            errorText: _manifestError,
            helperText: t('permissions: read / write / storage / hooks / send / ui / network；handler 填导出函数名', 'permissions: read / write / storage / hooks / send / ui / network; handler = exported function name'),
            helperMaxLines: 2,
            alignLabelWithHint: true,
          ),
        ),
        SectionTitle(t('代码（ES 模块）', 'Code (ES module)')),
        TextField(
          controller: _code,
          enabled: _codeLoaded,
          maxLines: null,
          minLines: 14,
          style: mono,
          decoration: InputDecoration(
            hintText: _codeLoaded ? null : t('正在加载代码…', 'Loading code…'),
            errorText: _codeError,
            filled: true,
            fillColor: scheme.surfaceContainerHigh,
            border: const UnderlineInputBorder(),
          ),
        ),
        SectionTitle(t('工具对哪些模型可用（不选 = 所有模型）', 'Tools available for models (none = all)')),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final m in models)
            FilterChip(
              avatar: ModelIcon(iconKey: m.icon, name: m.name, size: 18),
              label: Text(m.name),
              selected: p.models.contains(m.id),
              onSelected: (v) => setState(() => p.models = v ? [...p.models, m.id] : p.models.where((x) => x != m.id).toList()),
            ),
        ]),
        if (p.id.isNotEmpty) ...[
          SectionTitle(t('数据库占用', 'Storage')),
          if (storage == null)
            const LinearProgressIndicator()
          else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${fmtBytes((storage['used_bytes'] as num?)?.toInt() ?? 0)} / ${fmtBytes((storage['quota_bytes'] as num?)?.toInt() ?? 0)}'),
              subtitle: Text(t('${storage['entry_count'] ?? 0} 条', '${storage['entry_count'] ?? 0} entries')),
              trailing: TextButton(onPressed: ((storage['entry_count'] as num?) ?? 0) > 0 ? () => _clearStorage() : null, child: Text(t('全部清空', 'Clear all'))),
            ),
            LinearProgressIndicator(
              value: (((storage['used_bytes'] as num?) ?? 0) / (((storage['quota_bytes'] as num?) ?? 1).clamp(1, double.infinity))).toDouble().clamp(0.0, 1.0),
            ),
            for (final tb in (storage['tables'] as List?) ?? const [])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.table_chart_outlined),
                title: Text('${(tb as Map)['name']}'),
                subtitle: Text('${fmtBytes((tb['used_bytes'] as num?)?.toInt() ?? 0)} · ${t('${tb['entry_count'] ?? 0} 条', '${tb['entry_count'] ?? 0} entries')}'),
                trailing: IconButton(
                  tooltip: t('清空此表', 'Clear table'),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () => _clearStorage('${tb['name']}'),
                ),
              ),
          ],
        ],
        const SizedBox(height: 40),
      ]),
    );
  }
}
