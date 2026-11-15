import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/form_factor.dart';
import '../../core/format.dart';
import '../../core/i18n.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

/// Long-term memory manager. [characterId]: null = all, 'global' = global only.
class MemoryPage extends ConsumerStatefulWidget {
  final String? characterId;
  const MemoryPage({super.key, this.characterId});
  @override
  ConsumerState<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends ConsumerState<MemoryPage> {
  late String? _filter = widget.characterId;
  String _q = '';
  List<Memory>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final q = <String, String>{'character_id': ?_filter, if (_q.isNotEmpty) 'q': _q};
      final items = await ref.read(apiProvider).list('/api/memories', Memory.new, query: q);
      items.sort((a, b) => (b.pinned ? 1 : 0).compareTo(a.pinned ? 1 : 0) != 0 ? (b.pinned ? 1 : 0).compareTo(a.pinned ? 1 : 0) : b.updatedAt.compareTo(a.updatedAt));
      setState(() {
        _items = items;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  Future<void> _edit(Memory? m) async {
    final content = TextEditingController(text: m?.content ?? '');
    final tags = TextEditingController(text: m?.tags.join(', ') ?? '');
    var pinned = m?.pinned ?? false;
    var scope = m == null ? (_filter == null || _filter == 'global' ? 'global' : _filter!) : (m.characterId ?? 'global');
    final chars = ref.read(charactersProvider).value ?? const <Character>[];
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: Text(m == null ? t('新增记忆', 'New memory') : t('编辑记忆', 'Edit memory')),
          content: SizedBox(
            width: 480,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: content, maxLines: 5, minLines: 2, autofocus: true, decoration: InputDecoration(labelText: t('内容', 'Content'))),
              const SizedBox(height: 8),
              TextField(controller: tags, decoration: InputDecoration(labelText: t('标签（逗号分隔）', 'Tags (comma separated)'))),
              const SizedBox(height: 8),
              if (m == null)
                DropdownButtonFormField<String>(
                  initialValue: scope,
                  decoration: InputDecoration(labelText: t('归属', 'Scope')),
                  items: [
                    DropdownMenuItem(value: 'global', child: Text(t('全局（所有角色）', 'Global (all characters)'))),
                    for (final ch in chars) DropdownMenuItem(value: ch.id, child: Text(ch.name)),
                  ],
                  onChanged: (v) => set(() => scope = v ?? 'global'),
                ),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t('置顶（总是注入系统提示）', 'Pinned (always in system prompt)')), value: pinned, onChanged: (v) => set(() => pinned = v)),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('取消', 'Cancel'))),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t('保存', 'Save'))),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final body = {
      ...?m?.json,
      'content': content.text.trim(),
      'tags': tags.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'pinned': pinned,
      if (m == null) 'character_id': scope == 'global' ? null : scope,
    };
    try {
      final api = ref.read(apiProvider);
      if (m == null) {
        await api.post('/api/memories', body);
      } else {
        await api.put('/api/memories/${m.id}', body);
      }
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chars = ref.watch(charactersProvider).value ?? const <Character>[];
    final scheme = Theme.of(context).colorScheme;
    final watch = context.isWatch;
    final items = _items;
    String scopeName(String? id) => id == null ? t('全局', 'Global') : (chars.where((c) => c.id == id).firstOrNull?.name ?? id);
    return Scaffold(
      appBar: watch ? null : AppBar(title: Text(t('长期记忆', 'Long-term memory'))),
      floatingActionButton: watch ? null : FloatingActionButton(tooltip: t('新增记忆', 'New memory'), onPressed: () => _edit(null), child: const Icon(Icons.add)),
      body: Column(children: [
        if (!watch)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: Row(children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: t('搜索记忆', 'Search memory')),
                  onSubmitted: (v) {
                    _q = v.trim();
                    _load();
                  },
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: _filter,
                items: [
                  DropdownMenuItem(value: null, child: Text(t('全部', 'All'))),
                  DropdownMenuItem(value: 'global', child: Text(t('全局', 'Global'))),
                  for (final c in chars) DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) {
                  _filter = v;
                  _load();
                },
              ),
            ]),
          ),
        Expanded(
          child: _error != null
              ? Center(child: Text(_error!))
              : items == null
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? Center(child: Text(t('暂无记忆', 'No memories')))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: watch ? watchInset(context) : 8, vertical: 4),
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (c, i) {
                              final m = items[i];
                              return ListTile(
                                onTap: watch ? null : () => _edit(m),
                                leading: Icon(
                                  m.source == 'agent' ? Icons.smart_toy_outlined : (m.source == 'scan' ? Icons.auto_awesome_outlined : Icons.person_outline),
                                  color: scheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                title: Text(m.content),
                                subtitle: Text([scopeName(m.characterId), if (m.tags.isNotEmpty) m.tags.map((e) => '#$e').join(' '), fmtTime(m.updatedAt)].join(' · '), style: Theme.of(context).textTheme.labelSmall),
                                trailing: watch
                                    ? null
                                    : Row(mainAxisSize: MainAxisSize.min, children: [
                                        IconButton(
                                          // Toggle: selected state drives the glyph, color and semantics.
                                          tooltip: m.pinned ? t('取消置顶', 'Unpin') : t('置顶', 'Pin'),
                                          isSelected: m.pinned,
                                          icon: const Icon(Icons.push_pin_outlined),
                                          selectedIcon: const Icon(Icons.push_pin),
                                          onPressed: () async {
                                            await ref.read(apiProvider).put('/api/memories/${m.id}', {...m.json, 'pinned': !m.pinned});
                                            await _load();
                                          },
                                        ),
                                        IconButton(
                                          tooltip: t('删除', 'Delete'),
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () async {
                                            if (await confirm(context, t('删除这条记忆？', 'Delete this memory?'), ok: t('删除', 'Delete'))) {
                                              await ref.read(apiProvider).delete('/api/memories/${m.id}');
                                              await _load();
                                            }
                                          },
                                        ),
                                      ]),
                              );
                            },
                          ),
                        ),
        ),
      ]),
    );
  }
}
