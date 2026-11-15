import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';

import '../../core/form_factor.dart';
import '../../core/i18n.dart';
import '../../core/tokens.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../../widgets/slide_drawer.dart';
import '../characters/character_editor.dart';
import '../memory/memory_page.dart';
import '../settings/settings_page.dart';
import '../tools/tools_page.dart';

/// Drawer / side panel: character switcher on top, conversation list, then navigation.
class Sidebar extends ConsumerStatefulWidget {
  final void Function(Character) onNewConversation;
  final bool inDrawer;
  const Sidebar({super.key, required this.onNewConversation, this.inDrawer = false});
  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  String _q = '';
  bool _charsOpen = false;

  void _close() {
    final drawer = SlideDrawer.maybeOf(context);
    if (drawer != null) {
      drawer.close();
    } else if (widget.inDrawer || context.isWatch) {
      Navigator.of(context).maybePop();
    }
  }

  /// In-place conversation filter (not a primary search, so no SearchBar): a filled,
  /// full-shape field at least 48dp tall.
  Widget _searchField() {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: t('搜索对话', 'Search chats'),
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        isDense: true,
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding: const EdgeInsets.symmetric(vertical: Insets.x3),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(28)), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(28)), borderSide: BorderSide(color: scheme.primary, width: 2)),
      ),
      onChanged: (v) => setState(() => _q = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chars = ref.watch(charactersProvider);
    final current = ref.watch(currentCharacterProvider);
    final convId = ref.watch(selectedConversationIdProvider);
    final convs = current == null ? null : ref.watch(conversationsProvider(current.id));
    final app = ref.watch(appProvider);
    final watch = context.isWatch;
    final compact = ref.watch(appearanceProvider.select((a) => a.compact));
    final inset = watchInset(context);
    // Watch and phone share the RikkaHub layout; only the desktop side panel keeps the
    // character strip on top.
    final rikka = !context.isDesktop;

    final switcher = SizedBox(
      height: watch ? 64 : 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: watch ? inset : 12, vertical: 8),
        children: [
          for (final c in chars.value ?? const <Character>[])
            _CharChip(
              character: c,
              selected: c.id == current?.id,
              compact: watch,
              onTap: () {
                ref.read(selectedCharacterIdProvider.notifier).select(c.id);
                ref.read(selectedConversationIdProvider.notifier).select(null);
              },
              onMenu: (at) => _charMenu(c, at: at),
            ),
          if (!watch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Semantics(
                    button: true,
                    label: t('添加角色', 'Add character'),
                    excludeSemantics: true,
                    child: Material(
                      color: scheme.surfaceContainerHighest,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _addCharacter,
                        child: const SizedBox.square(dimension: 48, child: Icon(Icons.add_rounded)),
                      ),
                    ),
                  ),
                  const SizedBox(height: Insets.x1),
                  Text(t('添加', 'Add'), style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
        ],
      ),
    );

    final list = convs == null
        ? const SizedBox.shrink()
        : convs.when(
            loading: () => const Center(
              child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('$e')),
            data: (items) {
              final q = _q.toLowerCase();
              final filtered = q.isEmpty ? items : items.where((c) => c.title.toLowerCase().contains(q)).toList();
              final groups = <String, List<Conversation>>{};
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              for (final c in filtered) {
                final d = DateTime.fromMillisecondsSinceEpoch(c.updatedAt);
                final day = DateTime(d.year, d.month, d.day);
                final diff = today.difference(day).inDays;
                final g = diff <= 0
                    ? t('今天', 'Today')
                    : diff == 1
                    ? t('昨天', 'Yesterday')
                    : diff < 7
                    ? t('7 天内', 'Last 7 days')
                    : t('更早', 'Earlier');
                groups.putIfAbsent(g, () => []).add(c);
              }
              final tiles = <Widget>[
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(t('暂无对话', 'No chats yet'), style: Theme.of(context).textTheme.bodySmall),
                  ),
                for (final e in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Insets.x4, Insets.x3, Insets.x4, Insets.x1),
                    child: Text(e.key, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
                  for (final c in e.value)
                    GestureDetector(
                      onSecondaryTapUp: (d) => _convMenu(c, at: d.globalPosition),
                      // Selected chat: opaque secondaryContainer / onSecondaryContainer with a
                      // full-shape indicator (navigation-drawer item anatomy); 48dp minimum.
                      child: ListTile(
                        minTileHeight: compact ? 48 : 56,
                        selected: c.id == convId,
                        selectedTileColor: scheme.secondaryContainer,
                        selectedColor: scheme.onSecondaryContainer,
                        shape: const StadiumBorder(),
                        title: Text(c.title.isEmpty ? t('新对话', 'New chat') : c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: c.generating
                            ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, semanticsLabel: t('正在生成', 'Generating')))
                            : null,
                        onTap: () {
                          ref.read(selectedConversationIdProvider.notifier).select(c.id);
                          _close();
                        },
                        onLongPress: () => _convMenu(c),
                      ),
                    ),
                ],
              ];
              if (rikka) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: tiles);
              return ListView(padding: const EdgeInsets.symmetric(horizontal: Insets.x3), children: tiles);
            },
          );

    if (rikka) return _rikkaLayout(chars.value ?? const <Character>[], current, list, app, inset, watch);

    final header = current == null
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.fromLTRB(watch ? inset : 12, 4, watch ? inset : 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: watch
                      ? Text(current.name, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis)
                      : _searchField(),
                ),
                IconButton(
                  tooltip: t('新对话', 'New chat'),
                  onPressed: () async {
                    _close();
                    widget.onNewConversation(current);
                  },
                  icon: const Icon(Icons.add_comment_rounded),
                ),
              ],
            ),
          );

    final footer = Column(
      children: [
        const Divider(),
        _NavTile(icon: Icons.psychology_alt_rounded, label: t('记忆', 'Memory'), onTap: () => _push(const MemoryPage())),
        _NavTile(icon: Icons.code_rounded, label: t('本地工具', 'Local tools'), onTap: () => _push(const ToolsPage())),
        _NavTile(icon: Icons.settings_rounded, label: t('设置', 'Settings'), onTap: () => _push(const SettingsPage())),
        ListTile(
          leading: Icon(app.active?.isLocal == true ? Icons.phone_android_rounded : Icons.cloud_rounded),
          title: Text(app.active?.isLocal == true ? t('本地后端', 'Local backend') : (app.active?.name ?? ''), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(app.user?.username ?? '', maxLines: 1),
          trailing: const Icon(Icons.swap_horiz_rounded),
          onTap: () => ref.read(appProvider.notifier).showConnect(),
        ),
      ],
    );

    return SafeArea(
      child: Material(
        color: widget.inDrawer ? Colors.transparent : scheme.surfaceContainerLow,
        child: Column(
          children: [
            switcher,
            header,
            Expanded(child: list),
            footer,
          ],
        ),
      ),
    );
  }

  /// Watch and phone (as in RikkaHub): the chats scroll in the middle; the current character
  /// and a row of round buttons stay fixed at the bottom. Tapping the character expands a
  /// picker above it.
  Widget _rikkaLayout(List<Character> chars, Character? current, Widget convs, AppState app, double inset, bool watch) {
    final scheme = Theme.of(context).colorScheme;
    final h = MediaQuery.sizeOf(context).height;
    final compact = ref.watch(appearanceProvider.select((a) => a.compact));
    // Standard tonal icon buttons: 40dp visual, 48dp target. On narrow windows (watch) the
    // row wraps instead of shrinking the targets.
    Widget round(IconData icon, String tip, VoidCallback onTap) => IconButton.filledTonal(
      tooltip: tip,
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.padded, visualDensity: VisualDensity.standard),
    );
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(inset + Insets.x2, Insets.x2, inset + Insets.x2, Insets.x2),
                children: [
                  if (!watch && current != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Insets.x1, Insets.x1, Insets.x1, Insets.x2),
                      child: _searchField(),
                    ),
                  if (current != null)
                    ListTile(
                      minTileHeight: compact ? 48 : 56,
                      contentPadding: const EdgeInsets.symmetric(horizontal: Insets.x4),
                      shape: const StadiumBorder(),
                      leading: const Icon(Icons.add_comment_rounded),
                      title: Text(t('新对话', 'New chat')),
                      onTap: () {
                        _close();
                        widget.onNewConversation(current);
                      },
                    ),
                  convs,
                ],
              ),
            ),
            Collapsible(
              open: _charsOpen,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: h * 0.45),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: inset + Insets.x2),
                  children: [
                    for (final c in chars)
                      ListTile(
                        minTileHeight: 48,
                        contentPadding: const EdgeInsets.symmetric(horizontal: Insets.x4),
                        shape: const StadiumBorder(),
                        selected: c.id == current?.id,
                        selectedTileColor: scheme.secondaryContainer,
                        selectedColor: scheme.onSecondaryContainer,
                        leading: CharacterAvatar(character: c, size: watch ? 24 : 32),
                        title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: c.id == current?.id ? const Icon(Icons.check_rounded) : null,
                        onTap: () {
                          ref.read(selectedCharacterIdProvider.notifier).select(c.id);
                          ref.read(selectedConversationIdProvider.notifier).select(null);
                          setState(() => _charsOpen = false);
                        },
                        onLongPress: () => _charMenu(c),
                      ),
                    if (!watch)
                      ListTile(
                        minTileHeight: 48,
                        contentPadding: const EdgeInsets.symmetric(horizontal: Insets.x4),
                        shape: const StadiumBorder(),
                        leading: CircleAvatar(radius: 16, backgroundColor: scheme.surfaceContainerHighest, child: const Icon(Icons.add_rounded, size: 20)),
                        title: Text(t('添加角色', 'Add character')),
                        onTap: () {
                          setState(() => _charsOpen = false);
                          _addCharacter();
                        },
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: inset + Insets.x2),
              child: ListTile(
                minTileHeight: watch ? 48 : 56,
                shape: const StadiumBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: Insets.x3),
                leading: current == null ? const Icon(Icons.person_outline_rounded) : CharacterAvatar(character: current, size: watch ? 26 : 32),
                title: Text(current?.name ?? t('选择角色', 'Pick a character'), maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: TurnChevron(open: !_charsOpen),
                onTap: () => setState(() => _charsOpen = !_charsOpen),
                onLongPress: current == null ? null : () => _charMenu(current),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(inset + Insets.x1, 0, inset + Insets.x1, Insets.x2),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: watch ? 0 : 8,
                children: [
                  round(Icons.psychology_alt_rounded, t('记忆', 'Memory'), () => _push(const MemoryPage())),
                  round(Icons.code_rounded, t('本地工具', 'Local tools'), () => _push(const ToolsPage())),
                  round(Icons.swap_horiz_rounded, t('连接', 'Connection'), () => ref.read(appProvider.notifier).showConnect()),
                  round(Icons.settings_rounded, t('设置', 'Settings'), () => _push(const SettingsPage())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(Widget page) {
    _close();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _addCharacter() async {
    final v = await showActionSheet<String>(
      context,
      (c) => [
        ListTile(leading: const Icon(Icons.person_add_alt_rounded), title: Text(t('新建角色', 'New character')), onTap: () => Navigator.pop(c, 'new')),
        ListTile(leading: const Icon(Icons.file_open_rounded), title: Text(t('导入角色卡（PNG / JSON）', 'Import card (PNG / JSON)')), onTap: () => Navigator.pop(c, 'import')),
      ],
    );
    if (!mounted || v == null) return;
    if (v == 'new') {
      _push(const CharacterEditorPage());
    } else {
      await importCharacterCard(context, ref);
    }
  }

  Future<void> _charMenu(Character c, {Offset? at}) async {
    final v = await showActions(context, [
      MenuAction('edit', Icons.edit_rounded, t('编辑', 'Edit')),
      MenuAction('dup', Icons.copy_all_rounded, t('复制', 'Duplicate')),
      MenuAction('up', Icons.arrow_back_rounded, t('前移', 'Move earlier')),
      MenuAction('down', Icons.arrow_forward_rounded, t('后移', 'Move later')),
      MenuAction('del', Icons.delete_outline_rounded, t('删除', 'Delete'), danger: true),
    ], at: at);
    if (!mounted || v == null) return;
    final ctl = ref.read(charactersProvider.notifier);
    try {
      switch (v) {
        case 'edit':
          _push(CharacterEditorPage(character: c));
        case 'dup':
          final copy = Character(jsonDecode(jsonEncode(c.json)) as Map<String, dynamic>);
          copy.json.remove('id');
          copy.name = '${c.name} (copy)';
          await ctl.save(copy);
        case 'up' || 'down':
          final ids = (ref.read(charactersProvider).value ?? const <Character>[]).map((e) => e.id).toList();
          final i = ids.indexOf(c.id);
          final j = v == 'up' ? i - 1 : i + 1;
          if (j >= 0 && j < ids.length) {
            ids[i] = ids[j];
            ids[j] = c.id;
            await ctl.reorder(ids);
          }
        case 'del':
          if (await confirm(context, t('删除角色「${c.name}」？', 'Delete "${c.name}"?'), body: t('该角色的所有对话和专属记忆都会被删除。', 'All of its chats and memories will be deleted.'), ok: t('删除', 'Delete'))) {
            await ctl.remove(c.id);
          }
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _convMenu(Conversation c, {Offset? at}) async {
    final v = await showActions(context, [MenuAction('rename', Icons.drive_file_rename_outline_rounded, t('重命名', 'Rename')), MenuAction('del', Icons.delete_outline_rounded, t('删除', 'Delete'), danger: true)], at: at);
    if (!mounted || v == null) return;
    final api = ref.read(apiProvider);
    try {
      if (v == 'rename') {
        final s = await promptText(context, t('重命名对话', 'Rename chat'), initial: c.title, ok: t('重命名', 'Rename'));
        if (s != null) await api.patch('/api/conversations/${c.id}', {'title': s});
      } else if (await confirm(context, t('删除这个对话？', 'Delete this chat?'), ok: t('删除', 'Delete'))) {
        await api.delete('/api/conversations/${c.id}');
        if (ref.read(selectedConversationIdProvider) == c.id) ref.read(selectedConversationIdProvider.notifier).select(null);
      }
      ref.invalidate(conversationsProvider(c.characterId));
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavTile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(minTileHeight: 48, shape: const StadiumBorder(), leading: Icon(icon), title: Text(label), onTap: onTap);
}

class _CharChip extends StatelessWidget {
  final Character character;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;
  final void Function(Offset? at) onMenu;
  const _CharChip({required this.character, required this.selected, required this.onTap, required this.onMenu, this.compact = false});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 36.0 : 48.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Semantics(
        button: true,
        selected: selected,
        label: character.name,
        excludeSemantics: true,
        child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: () => onMenu(null),
        onSecondaryTapUp: (d) => onMenu(d.globalPosition),
        child: SizedBox(
          width: size + 14,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? scheme.primary : Colors.transparent, width: 2),
                ),
                child: CharacterAvatar(character: character, size: size),
              ),
              if (!compact) ...[
                const SizedBox(height: 2),
                Text(
                  character.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: selected ? scheme.primary : null),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}

/// Pick a PNG/JSON SillyTavern card and import it.
Future<void> importCharacterCard(BuildContext context, WidgetRef ref) async {
  final f = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['png', 'json']);
  if (f == null) return;
  try {
    final bytes = await f.readAsBytes();
    final isPng = (f.extension ?? '').toLowerCase() == 'png';
    final body = isPng ? {'png_base64': base64Encode(bytes)} : {'json': jsonDecode(utf8.decode(bytes))};
    final c = await ref.read(charactersProvider.notifier).import(body);
    ref.read(selectedCharacterIdProvider.notifier).select(c.id);
    if (context.mounted) {
      showInfo(context, t('已导入 ${c.name}', 'Imported ${c.name}'));
    }
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}
