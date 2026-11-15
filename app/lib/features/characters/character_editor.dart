import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/form_factor.dart';
import '../../core/i18n.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../chat/model_picker.dart';
import '../memory/memory_page.dart';

class CharacterEditorPage extends ConsumerStatefulWidget {
  final Character? character;
  const CharacterEditorPage({super.key, this.character});
  @override
  ConsumerState<CharacterEditorPage> createState() => _CharacterEditorPageState();
}

class _CharacterEditorPageState extends ConsumerState<CharacterEditorPage> {
  late Character c;
  bool _saving = false;
  bool _dirty = false;
  String? _nameError;
  BuildContext? _tabsContext;

  @override
  void initState() {
    super.initState();
    c = widget.character == null ? Character.blank() : Character(jsonDecode(jsonEncode(widget.character!.json)) as Map<String, dynamic>);
    if (widget.character == null) {
      // New characters get the built-in tools (e.g. the dice roller) switched on, also when the
      // tool list has not loaded yet.
      ref
          .read(charactersProvider.notifier)
          .builtinToolIds()
          .then((ids) {
            if (!mounted || ids.isEmpty) return;
            setState(() => c.toolIds = {...c.toolIds, ...ids}.toList());
          })
          .catchError((_) {});
    }
  }

  void _touch(VoidCallback f) => setState(() {
    f();
    _dirty = true;
  });

  Future<void> _save() async {
    if (c.name.trim().isEmpty) {
      // Inline error on the field; jump to the tab that holds it.
      setState(() => _nameError = t('请填写角色名称', 'Name is required'));
      DefaultTabController.maybeOf(_tabsContext ?? context)?.animateTo(0);
      return;
    }
    setState(() => _nameError = null);
    if (c.cardStr('name').isEmpty) c.setCard('name', c.name);
    setState(() => _saving = true);
    try {
      final saved = await ref.read(charactersProvider.notifier).save(c);
      if (widget.character == null) ref.read(selectedCharacterIdProvider.notifier).select(saved.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _export(String format) async {
    try {
      final bytes = await ref.read(apiProvider).getBytes('/api/characters/${c.id}/export', query: {'format': format});
      await FilePicker.saveFile(fileName: '${c.name}.$format', bytes: Uint8List.fromList(bytes), mimeType: format == 'png' ? 'image/png' : 'application/json');
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.isWatch) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(watchInset(context)),
            child: Text(t('请在手机或电脑上编辑角色', 'Please edit characters on a phone or computer'), textAlign: TextAlign.center),
          ),
        ),
      );
    }
    final tabs = [t('基本', 'Basic'), t('角色卡', 'Card'), t('工具', 'Tools'), t('上下文', 'Context'), t('记忆', 'Memory')];
    return DefaultTabController(
      length: tabs.length,
      child: PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (did, _) async {
          if (did) return;
          if (await confirm(context, t('放弃未保存的修改？', 'Discard unsaved changes?'), ok: t('放弃', 'Discard'))) {
            _dirty = false;
            if (context.mounted) Navigator.pop(context);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.character == null ? t('新建角色', 'New character') : c.name),
            actions: [
              if (c.id.isNotEmpty)
                OverflowMenu(
                  icon: Icons.download_rounded,
                  tooltip: t('导出', 'Export'),
                  entries: [
                    MenuEntry(t('导出 PNG 角色卡', 'Export PNG card'), icon: Icons.image_outlined, onPressed: () => _export('png')),
                    MenuEntry(t('导出 JSON', 'Export JSON'), icon: Icons.data_object_rounded, onPressed: () => _export('json')),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton(onPressed: _saving ? null : _save, child: Text(t('保存', 'Save'))),
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [for (final x in tabs) Tab(text: x)],
            ),
          ),
          body: Builder(builder: (tabs) {
            _tabsContext = tabs;
            return TabBarView(
            children: [
              _BasicTab(c: c, touch: _touch, nameError: _nameError),
              _CardTab(c: c, touch: _touch),
              _ToolsTab(c: c, touch: _touch),
              _ContextTab(c: c, touch: _touch),
              _MemoryTab(c: c, touch: _touch),
            ],
          );
          }),
        ),
      ),
    );
  }
}

typedef Touch = void Function(VoidCallback);

class _Field extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String? hint;
  final TextInputType? keyboard;
  final String? error;
  const _Field({super.key, required this.label, required this.value, required this.onChanged, this.maxLines = 1, this.hint, this.keyboard, this.error});
  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final _c = TextEditingController(text: widget.value);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: TextField(
      controller: _c,
      minLines: widget.maxLines > 1 ? 2 : 1,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboard,
      decoration: InputDecoration(labelText: widget.label, hintText: widget.hint, alignLabelWithHint: true, errorText: widget.error),
      onChanged: widget.onChanged,
    ),
  );
}

class _BasicTab extends ConsumerWidget {
  final Character c;
  final Touch touch;
  final String? nameError;
  const _BasicTab({required this.c, required this.touch, this.nameError});

  Future<void> _pickAvatar(BuildContext context) async {
    final f = await FilePicker.pickFile(type: FileType.image);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024 && context.mounted) {
      showError(context, t('图片较大（>2MB），建议先压缩', 'Image is large (>2MB); consider compressing it'));
    }
    final ext = (f.extension ?? 'png').toLowerCase();
    touch(() => c.avatar = 'data:image/${ext == 'jpg' ? 'jpeg' : ext};base64,${base64Encode(bytes)}');
  }

  double? _num(String s) => s.trim().isEmpty ? null : double.tryParse(s.trim());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(characterModelProvider(c.modelId));
    final p = c.params;
    return FormListView(
      horizontal: 0,
      vertical: 8,
      children: [
        Center(
          child: Stack(
            children: [
              Tooltip(
                message: t('更换头像', 'Change avatar'),
                child: Semantics(
                  button: true,
                  label: t('更换头像', 'Change avatar'),
                  excludeSemantics: true,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _pickAvatar(context),
                    child: CharacterAvatar(character: c, size: 88),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(radius: 14, child: Icon(Icons.edit, size: 14, color: Theme.of(context).colorScheme.onPrimaryContainer)),
              ),
            ],
          ),
        ),
        if (c.avatar.isNotEmpty)
          Center(
            child: TextButton(onPressed: () => touch(() => c.avatar = ''), child: Text(t('移除头像', 'Remove avatar'))),
          ),
        _Field(label: t('名称', 'Name'), value: c.name, error: nameError, onChanged: (v) => touch(() => c.name = v)),
        ListTile(
          leading: ModelIcon(iconKey: model?.icon ?? '', name: model?.name ?? '?', size: 32),
          title: Text(t('对话模型', 'Chat model')),
          subtitle: Text(c.modelId.isEmpty ? t('使用默认模型（${model?.name ?? '未设置'}）', 'Default model (${model?.name ?? 'not set'})') : (model?.name ?? c.modelId)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final id = await showModelPicker(context, ref, selected: c.modelId, allowDefault: true);
            if (id != null) touch(() => c.modelId = id);
          },
        ),
        SectionTitle(t('生成参数（留空 = 供应商默认）', 'Generation (empty = provider default)')),
        Row(
          children: [
            Expanded(
              child: _Field(label: 'temperature', value: p['temperature']?.toString() ?? '', keyboard: TextInputType.number, onChanged: (v) => touch(() => p['temperature'] = _num(v))),
            ),
            Expanded(
              child: _Field(label: 'top_p', value: p['top_p']?.toString() ?? '', keyboard: TextInputType.number, onChanged: (v) => touch(() => p['top_p'] = _num(v))),
            ),
          ],
        ),
        _Field(label: 'max_tokens', value: p['max_tokens']?.toString() ?? '', keyboard: TextInputType.number, onChanged: (v) => touch(() => p['max_tokens'] = int.tryParse(v.trim()))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LayoutBuilder(
            builder: (context, box) => DropdownMenu<String>(
              width: box.maxWidth,
              label: Text(t('推理强度', 'Reasoning effort')),
              initialSelection: c.reasoningEffort,
              dropdownMenuEntries: [
                DropdownMenuEntry(value: '', label: t('关闭 / 默认', 'Off / default')),
                DropdownMenuEntry(value: 'low', label: t('低', 'Low')),
                DropdownMenuEntry(value: 'medium', label: t('中', 'Medium')),
                DropdownMenuEntry(value: 'high', label: t('高', 'High')),
              ],
              onSelected: (v) => touch(() => p['reasoning_effort'] = v ?? ''),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardTab extends StatelessWidget {
  final Character c;
  final Touch touch;
  const _CardTab({required this.c, required this.touch});

  @override
  Widget build(BuildContext context) {
    Widget f(String key, String label, {int lines = 6, String? hint}) => _Field(label: label, value: c.cardStr(key), maxLines: lines, hint: hint, onChanged: (v) => touch(() => c.setCard(key, v)));
    final greetings = ((c.card['alternate_greetings'] as List?) ?? const []).map((e) => e.toString()).toList();
    final book = c.card['character_book'];
    final entries = book is Map ? ((book['entries'] as List?) ?? const []) : const [];
    return FormListView(
      horizontal: 0,
      vertical: 8,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(t('兼容 SillyTavern 角色卡 V2，可用 {{char}} / {{user}} 宏。', 'SillyTavern Card V2 compatible; {{char}} / {{user}} macros supported.'), style: Theme.of(context).textTheme.bodySmall),
        ),
        f('description', t('描述 description', 'Description'), lines: 12),
        f('personality', t('性格 personality', 'Personality'), lines: 4),
        f('scenario', t('场景 scenario', 'Scenario'), lines: 4),
        f('first_mes', t('开场白 first_mes', 'First message'), lines: 8),
        SectionTitle(t('备选开场白', 'Alternate greetings')),
        for (var i = 0; i < greetings.length; i++)
          Row(
            children: [
              Expanded(
                child: _Field(
                  key: ValueKey('g$i${greetings.length}'),
                  label: '#${i + 2}',
                  value: greetings[i],
                  maxLines: 6,
                  onChanged: (v) => touch(() {
                    greetings[i] = v;
                    c.setCard('alternate_greetings', greetings);
                  }),
                ),
              ),
              IconButton(
                tooltip: t('删除开场白 #${i + 2}', 'Remove greeting #${i + 2}'),
                onPressed: () => touch(() => c.setCard('alternate_greetings', [...greetings]..removeAt(i))),
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(onPressed: () => touch(() => c.setCard('alternate_greetings', [...greetings, ''])), icon: const Icon(Icons.add), label: Text(t('添加开场白', 'Add greeting'))),
        ),
        f('mes_example', t('示例对话 mes_example', 'Example dialogue'), lines: 8, hint: '<START>\n{{user}}: …\n{{char}}: …'),
        f('system_prompt', t('系统提示 system_prompt（留空使用内置）', 'System prompt (empty = built-in)'), lines: 6),
        f('post_history_instructions', t('历史后指令 post_history_instructions', 'Post-history instructions'), lines: 4),
        f('creator_notes', t('作者备注 creator_notes', 'Creator notes'), lines: 3),
        _Field(
          label: t('标签（逗号分隔）', 'Tags (comma separated)'),
          value: ((c.card['tags'] as List?) ?? const []).join(', '),
          onChanged: (v) => touch(() => c.setCard('tags', v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList())),
        ),
        SectionTitle(t('世界书（${entries.length} 条）', 'Lorebook (${entries.length})')),
        for (var i = 0; i < entries.length; i++)
          _LoreEntry(entry: Map<String, dynamic>.from(entries[i] as Map), onChanged: (e) => touch(() => _setEntry(i, e)), onDelete: () => touch(() => _setEntry(i, null))),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => touch(() => _setEntry(-1, {'keys': <String>[], 'content': '', 'enabled': true, 'constant': false, 'insertion_order': 100})),
            icon: const Icon(Icons.add),
            label: Text(t('添加条目', 'Add entry')),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _setEntry(int i, Map<String, dynamic>? e) {
    final book = Map<String, dynamic>.from((c.card['character_book'] as Map?) ?? {'entries': <dynamic>[]});
    final entries = List<dynamic>.from((book['entries'] as List?) ?? const []);
    if (i < 0) {
      entries.add(e);
    } else if (e == null) {
      entries.removeAt(i);
    } else {
      entries[i] = e;
    }
    book['entries'] = entries;
    c.setCard('character_book', book);
  }
}

class _LoreEntry extends StatelessWidget {
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final VoidCallback onDelete;
  const _LoreEntry({required this.entry, required this.onChanged, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    final keys = ((entry['keys'] as List?) ?? const []).join(', ');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Text(keys.isEmpty ? t('（无关键词）', '(no keys)') : keys, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text((entry['content'] as String? ?? ''), maxLines: 1, overflow: TextOverflow.ellipsis),
        children: [
          _Field(label: t('关键词（逗号分隔）', 'Keys (comma separated)'), value: keys, onChanged: (v) => onChanged({...entry, 'keys': v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()})),
          _Field(label: t('内容', 'Content'), value: entry['content'] as String? ?? '', maxLines: 8, onChanged: (v) => onChanged({...entry, 'content': v})),
          _Field(
            label: t('插入顺序', 'Insertion order'),
            value: '${entry['insertion_order'] ?? 100}',
            keyboard: TextInputType.number,
            onChanged: (v) => onChanged({...entry, 'insertion_order': int.tryParse(v) ?? 100}),
          ),
          // Lorebook flags are saved with the character: checkboxes, not switches.
          CheckboxListTile(title: Text(t('启用', 'Enabled')), value: entry['enabled'] != false, onChanged: (v) => onChanged({...entry, 'enabled': v ?? false})),
          CheckboxListTile(title: Text(t('常驻（总是注入）', 'Constant (always on)')), value: entry['constant'] == true, onChanged: (v) => onChanged({...entry, 'constant': v ?? false})),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onDelete, child: Text(t('删除条目', 'Delete entry'))),
          ),
        ],
      ),
    );
  }
}

class _ToolsTab extends ConsumerWidget {
  final Character c;
  final Touch touch;
  const _ToolsTab({required this.c, required this.touch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tools = ref.watch(toolsProvider).value ?? const <LocalTool>[];
    final models = ref.watch(modelsProvider).value ?? const <ModelCfg>[];
    final model = ref.watch(characterModelProvider(c.modelId));
    final scheme = Theme.of(context).colorScheme;
    final mcp = c.mcp;
    return FormListView(
      horizontal: 0,
      vertical: 8,
      children: [
        if (model != null && !model.toolCall)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(8)),
            child: Text(t('当前模型未标记为支持工具调用，工具不会发送给模型。', 'The current model is not marked as tool-capable; tools will not be sent.'), style: TextStyle(color: scheme.onErrorContainer)),
          ),
        SectionTitle(t('本地工具（JS）', 'Local tools (JS)')),
        if (tools.isEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(t('还没有本地工具，可在侧边栏「本地工具」中创建。', 'No local tools yet. Create them under "Local tools".'))),
        for (final tool in tools)
          Builder(
            builder: (context) {
              final allowed = tool.models.isEmpty || (model != null && tool.models.contains(model.id));
              final names = tool.models.map((id) => models.where((m) => m.id == id).firstOrNull?.name ?? id).join(', ');
              return CheckboxListTile(
                value: c.toolIds.contains(tool.id),
                onChanged: (v) => touch(() => c.toolIds = v == true ? [...c.toolIds, tool.id] : c.toolIds.where((x) => x != tool.id).toList()),
                // Still selectable for configuration: keep the label readable and explain the
                // restriction in the supporting text instead of fading it.
                title: Text(tool.name),
                subtitle: Text(
                  [
                    if (tool.description.isNotEmpty) tool.description,
                    tool.models.isEmpty ? t('所有模型可用', 'All models') : t('仅：$names', 'Only: $names'),
                    if (!allowed) t('当前模型不在允许列表中', 'Not enabled for the current model'),
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        SectionTitle(t('MCP 服务器', 'MCP servers')),
        for (var i = 0; i < mcp.length; i++) _McpTile(server: mcp[i], onChanged: (s) => touch(() => c.mcp = [...mcp]..[i] = s), onDelete: () => touch(() => c.mcp = [...mcp]..removeAt(i))),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(onPressed: () => touch(() => c.mcp = [...mcp, McpServerCfg.blank()]), icon: const Icon(Icons.add), label: Text(t('添加 MCP 服务器', 'Add MCP server'))),
        ),
      ],
    );
  }
}

class _McpTile extends ConsumerStatefulWidget {
  final McpServerCfg server;
  final ValueChanged<McpServerCfg> onChanged;
  final VoidCallback onDelete;
  const _McpTile({required this.server, required this.onChanged, required this.onDelete});
  @override
  ConsumerState<_McpTile> createState() => _McpTileState();
}

class _McpTileState extends ConsumerState<_McpTile> {
  String? _result;
  bool _testing = false;

  McpServerCfg _copy() => McpServerCfg(jsonDecode(jsonEncode(widget.server.json)) as Map<String, dynamic>);

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _result = null;
    });
    try {
      final r = await ref.read(apiProvider).post('/api/mcp/test', widget.server.json) as Map;
      if (r['ok'] == true) {
        final tools = (r['tools'] as List? ?? const []).map((e) => (e as Map)['name']).join(', ');
        _result = t('连接成功，${(r['tools'] as List? ?? const []).length} 个工具：$tools', 'OK, ${(r['tools'] as List? ?? const []).length} tools: $tools');
      } else {
        _result = '${t('失败', 'Failed')}: ${r['error']}';
      }
    } catch (e) {
      _result = '${t('失败', 'Failed')}: $e';
    }
    if (mounted) setState(() => _testing = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.server;
    final headers = s.headers.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        initiallyExpanded: s.url.isEmpty,
        // Saved with the character, so a named checkbox rather than a bare switch.
        leading: Checkbox(
          semanticLabel: t('启用 ${s.name.isEmpty ? 'MCP 服务器' : s.name}', 'Enable ${s.name.isEmpty ? 'MCP server' : s.name}'),
          value: s.enabled,
          onChanged: (v) => widget.onChanged(_copy()..enabled = v ?? false),
        ),
        title: Text(s.name.isEmpty ? t('未命名', 'Unnamed') : s.name),
        subtitle: Text('${s.transport == 'sse' ? 'SSE' : 'Streamable HTTP'} · ${s.url}', maxLines: 1, overflow: TextOverflow.ellipsis),
        children: [
          _Field(label: t('名称（工具前缀）', 'Name (tool prefix)'), value: s.name, onChanged: (v) => widget.onChanged(_copy()..name = v)),
          _Field(label: 'URL', value: s.url, onChanged: (v) => widget.onChanged(_copy()..url = v.trim())),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ChoiceField<String>(
              label: t('传输方式', 'Transport'),
              value: s.transport,
              minSegmentWidth: 150,
              options: const [('http', 'Streamable HTTP'), ('sse', 'SSE')],
              onChanged: (v) => widget.onChanged(_copy()..transport = v),
            ),
          ),
          _Field(
            label: t('请求头（每行 Key: Value）', 'Headers (one "Key: Value" per line)'),
            value: headers,
            maxLines: 4,
            onChanged: (v) {
              final m = <String, String>{};
              for (final line in v.split('\n')) {
                final i = line.indexOf(':');
                if (i > 0) m[line.substring(0, i).trim()] = line.substring(i + 1).trim();
              }
              widget.onChanged(_copy()..headers = m);
            },
          ),
          if (_result != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(_result!, style: Theme.of(context).textTheme.bodySmall),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: widget.onDelete, child: Text(t('删除服务器', 'Delete server'))),
              const SizedBox(width: 8),
              FilledButton.tonal(onPressed: _testing ? null : _test, child: Text(_testing ? t('测试中…', 'Testing…') : t('测试', 'Test'))),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ContextTab extends StatelessWidget {
  final Character c;
  final Touch touch;
  const _ContextTab({required this.c, required this.touch});
  @override
  Widget build(BuildContext context) {
    final ctx = c.context;
    final small = Theme.of(context).textTheme.bodySmall;
    int n(String k, int d) => (ctx[k] as num?)?.toInt() ?? d;
    return FormListView(
      horizontal: 0,
      vertical: 8,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            t(
              '两种压缩可以同时开启：即时压缩让较早的回复以短摘要发送，摘要压缩在达到阈值时再把更早的历史合并成摘要卡（会优先使用即时压缩的结果）。',
              'Both can be on: instant sends older replies as short notes, and summary compression merges even older history into a card at the threshold (using the instant notes when available).',
            ),
            style: small,
          ),
        ),
        CheckboxListTile(
          secondary: const Icon(Icons.compress_rounded),
          title: Text(t('摘要压缩', 'Summary compression')),
          value: c.summarize,
          onChanged: (v) => touch(() => c.setCompression(summarize: v ?? false)),
        ),
        if (c.summarize) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              t(
                '上下文达到阈值时，用 Fast model 把较早的消息压缩成一张摘要卡。原消息保留可见，但不再发送给模型。',
                'When the context reaches the threshold, older messages are summarised into a card by the fast model. Originals stay visible but are no longer sent.',
              ),
              style: small,
            ),
          ),
          _Field(
            label: t('压缩阈值（token，0 = 模型上下文的 75%）', 'Threshold (tokens, 0 = 75% of model context)'),
            value: '${n('compress_threshold', 0)}',
            keyboard: TextInputType.number,
            onChanged: (v) => touch(() => ctx['compress_threshold'] = int.tryParse(v) ?? 0),
          ),
          _Field(
            label: t('保留最近 n 条不压缩', 'Keep latest n messages'),
            value: '${n('keep_recent', 6)}',
            keyboard: TextInputType.number,
            onChanged: (v) => touch(() => ctx['keep_recent'] = int.tryParse(v) ?? 6),
          ),
        ],
        CheckboxListTile(
          secondary: const Icon(Icons.bolt_rounded),
          title: Text(t('即时压缩', 'Instant compression')),
          value: c.instant,
          onChanged: (v) => touch(() => c.setCompression(instant: v ?? false)),
        ),
        if (c.instant) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              t(
                '每次回复后用 Fast model 压缩该回复，较早的消息以压缩内容发送；显示内容不受影响。压缩失败时消息上会出现感叹号，并回退发送完整内容。',
                'After every reply the fast model compresses it; older messages are sent compressed while the display stays intact. Failures show a ! on the message and fall back to the full text.',
              ),
              style: small,
            ),
          ),
          _Field(
            label: t('最近 n 条发送原文', 'Send latest n messages in full'),
            value: '${n('display_recent', 4)}',
            keyboard: TextInputType.number,
            onChanged: (v) => touch(() => ctx['display_recent'] = int.tryParse(v) ?? 4),
          ),
        ],
      ],
    );
  }
}

class _MemoryTab extends StatelessWidget {
  final Character c;
  final Touch touch;
  const _MemoryTab({required this.c, required this.touch});
  @override
  Widget build(BuildContext context) {
    final m = c.memory;
    return FormListView(
      horizontal: 0,
      vertical: 8,
      children: [
        CheckboxListTile(
          title: Text(t('启用长期记忆', 'Enable long-term memory')),
          subtitle: Text(t('角色可以通过工具搜索、添加、修改、删除记忆；置顶记忆总是可见。', 'The character can search/add/update/delete memories via tools; pinned ones are always visible.')),
          value: m['enabled'] != false,
          onChanged: (v) => touch(() => m['enabled'] = v ?? false),
        ),
        CheckboxListTile(
          title: Text(t('空闲时自动整理', 'Auto-extract when idle')),
          subtitle: Text(t('对话空闲一段时间后，用 Fast model 从最近对话中提取记忆。', 'After a chat goes idle, the fast model extracts memories from it.')),
          value: m['auto_scan'] != false,
          onChanged: (v) => touch(() => m['auto_scan'] = v ?? false),
        ),
        CheckboxListTile(
          title: Text(t('共享全局记忆', 'Share global memory')),
          subtitle: Text(t('可以读写所有角色共享的关于你的记忆。', 'Read/write memories about you shared by all characters.')),
          value: m['share_global'] != false,
          onChanged: (v) => touch(() => m['share_global'] = v ?? false),
        ),
        if (c.id.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.psychology_alt_outlined),
            title: Text(t('查看此角色的记忆', "View this character's memories")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MemoryPage(characterId: c.id))),
          ),
      ],
    );
  }
}
