import 'dart:convert';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:md_single_block_renderer/md_single_block_renderer.dart';

import '../../core/form_factor.dart';
import '../../core/format.dart';
import '../../core/i18n.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../characters/character_editor.dart';
import '../memory/memory_page.dart';
import '../sidebar/sidebar.dart';
import 'chat_controller.dart';
import 'message_rows.dart';
import 'model_picker.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  ChatController? _ctl;
  String? _ctlConv;
  final _cache = BlockCache();
  final _scroll = ScrollController();
  final _scaffold = GlobalKey<ScaffoldState>();
  bool _sidebarOpen = true;
  bool _atBottom = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final at = _scroll.hasClients && _scroll.offset < 80;
      if (at != _atBottom) setState(() => _atBottom = at);
    });
  }

  @override
  void dispose() {
    _ctl?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  ChatController? _controllerFor(String? convId) {
    if (convId == _ctlConv) return _ctl;
    _ctl?.dispose();
    _cache.clear();
    _ctlConv = convId;
    if (convId == null) {
      _ctl = null;
    } else {
      _ctl = ChatController(ref.read(apiProvider), convId)..load();
    }
    return _ctl;
  }

  Future<String?> _ensureConversation(Character ch) async {
    final cur = ref.read(selectedConversationIdProvider);
    if (cur != null) return cur;
    final j = await ref.read(apiProvider).post('/api/conversations', ch.newConversationBody(0));
    final id = (j as Map)['id'] as String;
    ref.invalidate(conversationsProvider(ch.id));
    ref.read(selectedConversationIdProvider.notifier).select(id);
    return id;
  }

  Future<void> newConversation(Character ch) async {
    var idx = 0;
    final greetings = ch.greetings;
    if (greetings.length > 1) {
      final r = await showModalBottomSheet<int>(
        context: context,
        showDragHandle: true,
        builder: (c) => SafeArea(
          child: ListView(shrinkWrap: true, children: [
            Padding(padding: const EdgeInsets.all(12), child: Text(t('选择开场白', 'Choose a greeting'), style: Theme.of(c).textTheme.titleMedium)),
            for (var i = 0; i < greetings.length; i++)
              ListTile(
                leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
                title: Text(greetings[i], maxLines: 3, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.pop(c, i),
              ),
          ]),
        ),
      );
      if (r == null) return;
      idx = r;
    }
    try {
      final j = await ref.read(apiProvider).post('/api/conversations', ch.newConversationBody(idx));
      ref.invalidate(conversationsProvider(ch.id));
      ref.read(selectedConversationIdProvider.notifier).select((j as Map)['id'] as String);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.formFactor;
    final ch = ref.watch(currentCharacterProvider);
    final convId = ref.watch(selectedConversationIdProvider);
    final ctl = _controllerFor(convId);
    final chars = ref.watch(charactersProvider);

    final body = ch == null
        ? _NoCharacter(loading: chars.isLoading)
        : _ChatBody(
            key: ValueKey(convId),
            ctl: ctl,
            character: ch,
            cache: _cache,
            scroll: _scroll,
            atBottom: _atBottom,
            onNewConversation: () => newConversation(ch),
            ensureConversation: () => _ensureConversation(ch),
          );

    if (ff == FormFactor.watch) {
      // Watch: no app bar; a small title chip at the top opens the character/chat list.
      return Scaffold(
        body: Stack(children: [
          Positioned.fill(child: body),
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            child: Center(
              child: ActionChip(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                avatar: ch == null ? const Icon(Icons.menu, size: 14) : CharacterAvatar(character: ch, size: 18),
                label: Text(ch?.name ?? 'RofuChat', style: const TextStyle(fontSize: 11)),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => Scaffold(body: Sidebar(onNewConversation: newConversation, inDrawer: true)),
                )),
              ),
            ),
          ),
        ]),
      );
    }

    final appBar = _ChatAppBar(
      ctl: ctl,
      character: ch,
      onMenu: () {
        if (ff == FormFactor.desktop) {
          setState(() => _sidebarOpen = !_sidebarOpen);
        } else {
          _scaffold.currentState?.openDrawer();
        }
      },
      onNew: ch == null ? null : () => newConversation(ch),
    );

    if (ff == FormFactor.desktop) {
      return Scaffold(
        key: _scaffold,
        body: Row(children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            child: _sidebarOpen ? SizedBox(width: 300, child: Sidebar(onNewConversation: newConversation)) : const SizedBox.shrink(),
          ),
          if (_sidebarOpen) const VerticalDivider(width: 1),
          Expanded(child: Scaffold(appBar: appBar, body: body)),
        ]),
      );
    }
    return Scaffold(
      key: _scaffold,
      appBar: appBar,
      drawer: Drawer(width: math.min(320, MediaQuery.sizeOf(context).width * 0.85), child: Sidebar(onNewConversation: newConversation, inDrawer: true)),
      // Swipe right anywhere on the chat to pull the sidebar out (it follows the finger);
      // the default 20 px edge strip is taken by Android's back gesture.
      drawerEdgeDragWidth: MediaQuery.sizeOf(context).width,
      drawerScrimColor: Colors.black.withValues(alpha: 0.4),
      body: body,
    );
  }
}

class _NoCharacter extends ConsumerWidget {
  final bool loading;
  const _NoCharacter({required this.loading});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.theater_comedy_outlined, size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(t('还没有角色', 'No characters yet'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CharacterEditorPage())),
            icon: const Icon(Icons.add),
            label: Text(t('新建或导入角色', 'Create or import a character')),
          ),
        ]),
      ),
    );
  }
}

class _ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final ChatController? ctl;
  final Character? character;
  final VoidCallback onMenu;
  final VoidCallback? onNew;
  const _ChatAppBar({required this.ctl, required this.character, required this.onMenu, required this.onNew});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ch = character;
    final convId = ref.watch(selectedConversationIdProvider);
    final convs = ch == null ? null : ref.watch(conversationsProvider(ch.id)).value;
    final conv = convs?.where((c) => c.id == convId).firstOrNull;
    final model = ch == null ? null : ref.watch(characterModelProvider(ch.modelId));
    final providers = ref.watch(providersProvider).value ?? const <ProviderCfg>[];
    final prov = providers.where((p) => p.id == model?.providerId).firstOrNull;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final title = conv == null || conv.title.isEmpty ? t('新对话', 'New chat') : conv.title;
    final sub = ch == null ? '' : '${ch.name} / ${model?.name ?? t('未选择模型', 'No model')}${prov == null ? '' : ' (${prov.name})'}';
    return AppBar(
      toolbarHeight: 60,
      titleSpacing: 0,
      leading: IconButton(icon: const Icon(Icons.notes_rounded), onPressed: onMenu, tooltip: t('侧边栏', 'Sidebar')),
      title: InkWell(
        onTap: ch == null ? null : () => pickModelForCharacter(context, ref, ch),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleMedium),
            if (sub.isNotEmpty) Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          ]),
        ),
      ),
      actions: [
        if (onNew != null) IconButton(onPressed: onNew, icon: const Icon(Icons.add_comment_outlined), tooltip: t('新对话', 'New chat')),
        if (ch != null)
          PopupMenuButton<String>(
            onSelected: (v) => _menu(context, ref, v, ch, conv),
            itemBuilder: (c) => [
              if (conv != null) PopupMenuItem(value: 'rename', child: Text(t('重命名', 'Rename'))),
              if (conv != null && ch.contextMode == 'traditional') PopupMenuItem(value: 'compress', child: Text(t('立即压缩上下文', 'Compress context now'))),
              if (conv != null) PopupMenuItem(value: 'scan', child: Text(t('立即整理记忆', 'Update memory now'))),
              PopupMenuItem(value: 'memory', child: Text(t('角色记忆', 'Character memory'))),
              PopupMenuItem(value: 'edit', child: Text(t('角色设置', 'Character settings'))),
              if (conv != null) PopupMenuItem(value: 'delete', child: Text(t('删除对话', 'Delete chat'), style: TextStyle(color: scheme.error))),
            ],
          ),
      ],
    );
  }

  Future<void> _menu(BuildContext context, WidgetRef ref, String v, Character ch, Conversation? conv) async {
    final api = ref.read(apiProvider);
    try {
      switch (v) {
        case 'rename':
          final s = await promptText(context, t('重命名对话', 'Rename chat'), initial: conv!.title);
          if (s != null) {
            await api.patch('/api/conversations/${conv.id}', {'title': s});
            ref.invalidate(conversationsProvider(ch.id));
          }
        case 'compress':
          await ctl?.compressNow();
        case 'scan':
          final r = await api.post('/api/conversations/${conv!.id}/memory_scan');
          if (context.mounted) {
            final m = r is Map ? r : const {};
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(t('记忆已整理：新增 ${m['added'] ?? 0}，更新 ${m['updated'] ?? 0}，删除 ${m['deleted'] ?? 0}',
                  'Memory updated: +${m['added'] ?? 0} ~${m['updated'] ?? 0} -${m['deleted'] ?? 0}')),
            ));
          }
        case 'memory':
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => MemoryPage(characterId: ch.id)));
        case 'edit':
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CharacterEditorPage(character: ch)));
        case 'delete':
          if (await confirm(context, t('删除这个对话？', 'Delete this chat?'))) {
            await api.delete('/api/conversations/${conv!.id}');
            ref.read(selectedConversationIdProvider.notifier).select(null);
            ref.invalidate(conversationsProvider(ch.id));
          }
      }
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

class _ChatBody extends ConsumerStatefulWidget {
  final ChatController? ctl;
  final Character character;
  final BlockCache cache;
  final ScrollController scroll;
  final bool atBottom;
  final VoidCallback onNewConversation;
  final Future<String?> Function() ensureConversation;
  const _ChatBody({super.key, required this.ctl, required this.character, required this.cache, required this.scroll, required this.atBottom, required this.onNewConversation, required this.ensureConversation});

  @override
  ConsumerState<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends ConsumerState<_ChatBody> {
  final _input = GlobalKey<ChatInputBarState>();

  Future<void> _send(String text, List<String> images) async {
    var ctl = widget.ctl;
    if (ctl == null) {
      try {
        await widget.ensureConversation();
      } catch (e) {
        if (mounted) showError(context, e);
        return;
      }
      // The page rebuilds with a fresh controller for the new conversation.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      _pendingSend = (text, images);
      return;
    }
    await ctl.send(content: text, images: images);
    ref.invalidate(conversationsProvider(widget.character.id));
  }

  static (String, List<String>)? _pendingSend;

  @override
  void didUpdateWidget(covariant _ChatBody old) {
    super.didUpdateWidget(old);
    final p = _pendingSend;
    if (p != null && widget.ctl != null) {
      _pendingSend = null;
      final ctl = widget.ctl!;
      Future.microtask(() async {
        await ctl.send(content: p.$1, images: p.$2);
        ref.invalidate(conversationsProvider(widget.character.id));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final p = _pendingSend;
    if (p != null && widget.ctl != null) {
      _pendingSend = null;
      final ctl = widget.ctl!;
      Future.microtask(() async {
        await ctl.send(content: p.$1, images: p.$2);
        ref.invalidate(conversationsProvider(widget.character.id));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctl = widget.ctl;
    final watch = context.isWatch;
    final list = ctl == null
        ? _EmptyChat(character: widget.character, onNew: widget.onNewConversation)
        : ListenableBuilder(listenable: ctl, builder: (context, _) => _MessageList(ctl: ctl, character: widget.character, cache: widget.cache, scroll: widget.scroll, onEdit: (m) => _input.currentState?.startEdit(m)));
    final input = ctl == null
        ? ChatInputBar(key: _input, ctl: null, character: widget.character, onSend: _send)
        : ListenableBuilder(listenable: ctl, builder: (context, _) => ChatInputBar(key: _input, ctl: ctl, character: widget.character, onSend: _send));
    if (watch) {
      return Stack(children: [
        Positioned.fill(child: list),
        Positioned(left: 0, right: 0, bottom: 6, child: Center(child: input)),
      ]);
    }
    final appearance = ref.watch(appearanceProvider);
    Widget content = Column(children: [
      Expanded(
        child: Stack(children: [
          Positioned.fill(child: list),
          if (!widget.atBottom && ctl != null)
            Positioned(
              right: 12,
              bottom: 8,
              child: FloatingActionButton.small(
                heroTag: 'bottom',
                onPressed: () => widget.scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                child: const Icon(Icons.keyboard_double_arrow_down_rounded),
              ),
            ),
        ]),
      ),
      input,
    ]);
    if (!appearance.fullWidth && context.isDesktop) {
      content = Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: content));
    }
    return content;
  }
}

class _EmptyChat extends StatelessWidget {
  final Character character;
  final VoidCallback onNew;
  const _EmptyChat({required this.character, required this.onNew});
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CharacterAvatar(character: character, size: context.isWatch ? 48 : 72),
          const SizedBox(height: 12),
          Text(character.name, style: text.titleLarge),
          if (character.cardStr('creator_notes').isNotEmpty && !context.isWatch)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(character.cardStr('creator_notes'), maxLines: 4, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: text.bodySmall),
            ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(onPressed: onNew, icon: const Icon(Icons.add_comment_outlined), label: Text(t('开始新对话', 'Start a new chat'))),
        ]),
      ),
    );
  }
}

class _MessageList extends ConsumerWidget {
  final ChatController ctl;
  final Character character;
  final BlockCache cache;
  final ScrollController scroll;
  final void Function(Message) onEdit;
  const _MessageList({required this.ctl, required this.character, required this.cache, required this.scroll, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ctl.loading && ctl.messages.isEmpty) return const Center(child: CircularProgressIndicator());
    if (ctl.loadError != null && ctl.messages.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(ctl.loadError!, textAlign: TextAlign.center)));
    }
    final appearance = ref.watch(appearanceProvider);
    final settings = ref.watch(settingsProvider).value;
    final models = ref.watch(modelsProvider).value ?? const <ModelCfg>[];
    final watch = context.isWatch;
    final rows = buildRows(ctl.messages, cache, streamingId: ctl.streamingId, generating: ctl.generating);
    final hInset = watch ? watchInset(context) : (appearance.compact ? 12.0 : 18.0);
    final base = Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.55, fontSize: (watch ? 13 : 15.5) * appearance.fontScale);
    final n = rows.length;
    final list = ListView.builder(
      controller: scroll,
      reverse: true,
      padding: EdgeInsets.fromLTRB(hInset, 8, hInset, watch ? 64 : 8),
      itemCount: n + 1,
      itemBuilder: (context, i) {
        if (i == 0) return _ListTail(ctl: ctl);
        final row = rows[n - i];
        return KeyedSubtree(key: ValueKey(row.key), child: _row(context, ref, row, base, appearance, settings, models, watch));
      },
    );
    if (!watch) return SelectionArea(child: list);
    return list;
  }

  Widget _row(BuildContext context, WidgetRef ref, ChatRow row, TextStyle base, dynamic appearance, UserSettings? settings, List<ModelCfg> models, bool watch) {
    final m = row.msg;
    switch (row) {
      case UserRow():
        return UserBubble(
          msg: m,
          userName: settings?.userName ?? 'User',
          showName: appearance.showAvatars && !watch,
          compact: watch,
          maxWidthFactor: watch ? 0.95 : 0.85,
          onCopy: () => copyText(context, m.content),
          onEdit: () => onEdit(m),
          onMore: (pos) => _messageMenu(context, ref, m, pos),
        );
      case AssistantHeaderRow():
        if (watch) return const SizedBox(height: 6);
        final model = models.where((x) => x.id == m.model).firstOrNull;
        final name = model?.name ?? (m.modelName.isNotEmpty ? m.modelName : character.name);
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 4),
          child: Row(children: [
            if (appearance.showAvatars) ...[
              ModelIcon(iconKey: model?.icon ?? m.modelIcon, name: name, size: 28),
              const SizedBox(width: 10),
            ],
            Flexible(child: Text(name, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
          ]),
        );
      case StepsRow():
        return Appear(enabled: row.live, child: StepsCard(steps: row.steps, live: row.live, compact: watch));
      case BlockRow():
        return Appear(
          enabled: m.id == ctl.streamingId,
          child: Opacity(
            opacity: m.visible ? 1 : 0.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: MarkdownSingleBlockRenderer(row.block, baseTextStyle: base),
            ),
          ),
        );
      case SummaryRow():
        return SummaryCard(
          msg: m,
          onEdit: () async {
            final s = await promptText(context, t('编辑摘要', 'Edit summary'), initial: m.content, maxLines: 12);
            if (s != null) await ctl.editContent(m, s);
          },
        );
      case FooterRow():
        return Appear(
            enabled: m.id == ctl.justFinishedId,
            child: _AssistantFooter(ctl: ctl, msg: m, isLast: row.isLastAssistant, showTokens: appearance.showTokens && !watch, compact: watch, onMore: (pos) => _messageMenu(context, ref, m, pos)));
    }
  }

  Future<void> _messageMenu(BuildContext context, WidgetRef ref, Message m, Offset pos) async {
    final scheme = Theme.of(context).colorScheme;
    final items = <PopupMenuEntry<String>>[
      PopupMenuItem(value: 'copy', child: ListTile(dense: true, leading: const Icon(Icons.copy_rounded), title: Text(t('复制', 'Copy')))),
      PopupMenuItem(value: 'edit', child: ListTile(dense: true, leading: const Icon(Icons.edit_outlined), title: Text(m.isUser ? t('编辑重发', 'Edit & resend') : t('编辑内容', 'Edit')))),
      PopupMenuItem(
          value: 'visible',
          child: ListTile(dense: true, leading: Icon(m.visible ? Icons.visibility_off_outlined : Icons.visibility_outlined), title: Text(m.visible ? t('移出上下文', 'Exclude from context') : t('加入上下文', 'Include in context')))),
      if (m.isAssistant && character.contextMode == 'instant')
        PopupMenuItem(value: 'actual', child: ListTile(dense: true, leading: const Icon(Icons.compress_rounded), title: Text(t('查看/编辑压缩内容', 'View/edit compressed')))),
      if (m.isAssistant && m.usage != null && context.isWatch)
        PopupMenuItem(value: 'usage', child: ListTile(dense: true, leading: const Icon(Icons.data_usage), title: Text(t('Token 用量', 'Token usage')))),
      PopupMenuItem(value: 'branch', child: ListTile(dense: true, leading: const Icon(Icons.call_split_rounded), title: Text(t('从这里分支', 'Branch from here')))),
      PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete_outline, color: scheme.error), title: Text(t('删除', 'Delete'), style: TextStyle(color: scheme.error)))),
    ];
    final v = await showMenu<String>(context: context, position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx, pos.dy), items: items);
    if (v == null || !context.mounted) return;
    try {
      switch (v) {
        case 'copy':
          copyText(context, m.content);
        case 'edit':
          if (m.isUser) {
            onEdit(m);
          } else {
            final s = await promptText(context, t('编辑内容', 'Edit'), initial: m.content, maxLines: 16);
            if (s != null) await ctl.editContent(m, s);
          }
        case 'visible':
          await ctl.setVisible(m, !m.visible);
        case 'actual':
          await showActualDialog(context, ctl, m);
        case 'usage':
          final u = m.usage!;
          await showDialog(context: context, builder: (c) => AlertDialog(content: TokenIndicator(usage: u)));
        case 'branch':
          final id = await ctl.branch(m);
          if (id != null) {
            ref.invalidate(conversationsProvider(character.id));
            ref.read(selectedConversationIdProvider.notifier).select(id);
          }
        case 'delete':
          if (await confirm(context, t('删除这条消息？', 'Delete this message?'))) await ctl.deleteMessage(m);
      }
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

Future<void> showActualDialog(BuildContext context, ChatController ctl, Message m) async {
  final ctlText = TextEditingController(text: m.actual ?? '');
  final scheme = Theme.of(context).colorScheme;
  await showDialog(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(t('压缩内容（发送给模型）', 'Compressed content (sent to the model)')),
      content: SizedBox(
        width: 560,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (m.actualStatus == 'failed')
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(8)),
              child: Text('${t('摘要生成失败，已回退发送完整内容。', 'Summary failed; the full message is sent instead.')}\n${m.actualError ?? ''}', style: TextStyle(color: scheme.onErrorContainer)),
            ),
          TextField(controller: ctlText, maxLines: 10, minLines: 3, decoration: InputDecoration(hintText: t('（空）', '(empty)'))),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(c);
            await ctl.retryActual(m);
          },
          child: Text(t('重新生成', 'Regenerate')),
        ),
        TextButton(onPressed: () => Navigator.pop(c), child: Text(t('取消', 'Cancel'))),
        FilledButton(
          onPressed: () async {
            Navigator.pop(c);
            await ctl.editActual(m, ctlText.text);
          },
          child: Text(t('保存', 'Save')),
        ),
      ],
    ),
  );
}

/// Bottom of the list: while a reply is being generated, a morphing loading shape with what
/// is happening right now (rikkahub style). Fades in and out.
class _ListTail extends StatelessWidget {
  final ChatController ctl;
  const _ListTail({required this.ctl});

  String? _status() {
    if (ctl.compressing) return t('正在压缩上下文…', 'Compressing context…');
    final m = ctl.streamingId == null ? null : ctl.byId(ctl.streamingId!);
    final segs = m?.segments ?? const <Segment>[];
    if (segs.isEmpty) return null;
    final last = segs.last;
    if (last.type == 'tool' && last.result == null) return t('正在调用 ${last.name}…', 'Calling ${last.name}…');
    if (last.type == 'reasoning') return t('思考中…', 'Thinking…');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final busy = ctl.generating || ctl.compressing;
    final status = busy ? _status() : null;
    final watch = context.isWatch;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, a) => FadeTransition(opacity: a, child: SizeTransition(sizeFactor: a, axisAlignment: -1, child: child)),
      child: !busy
          ? const SizedBox(key: ValueKey('idle'), height: 4, width: double.infinity)
          : Padding(
              key: const ValueKey('busy'),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
              child: Row(mainAxisAlignment: watch ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                LoadingBlob(size: watch ? 22 : 30),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: status == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(status, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ),
                ),
              ]),
            ),
    );
  }
}

class _AssistantFooter extends StatelessWidget {
  final ChatController ctl;
  final Message msg;
  final bool isLast;
  final bool showTokens;
  final bool compact;
  final void Function(Offset) onMore;
  const _AssistantFooter({required this.ctl, required this.msg, required this.isLast, required this.showTokens, required this.compact, required this.onMore});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notices = ctl.notices[msg.id] ?? const <String>[];
    final usage = msg.usage;
    return Opacity(
      opacity: msg.visible ? 1 : 0.6,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (msg.error != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: scheme.error), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(Icons.error_outline, color: scheme.error, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(msg.error!, style: TextStyle(color: scheme.error, fontSize: 12.5))),
              if (isLast) TextButton(onPressed: ctl.generating ? null : () => ctl.send(regenerate: true), child: Text(t('重试', 'Retry'))),
            ]),
          ),
        for (final n in notices)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(n, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.outline)),
          ),
        if (compact)
          Row(children: [
            ActualStatusIcon(msg: msg, pending: ctl.actualPending.contains(msg.id), onTapFailed: () => showActualDialog(context, ctl, msg)),
            const Spacer(),
            Builder(builder: (c) => MiniIconButton(Icons.more_horiz, t('更多', 'More'), () => onMore(_centerOf(c)))),
          ])
        else
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (!msg.visible)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(t('不在上下文中', 'Not in context'), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.outline)),
                ),
              if (showTokens && usage != null) Padding(padding: const EdgeInsets.only(right: 4), child: TokenIndicator(usage: usage)),
              ActualStatusIcon(msg: msg, pending: ctl.actualPending.contains(msg.id), onTapFailed: () => showActualDialog(context, ctl, msg)),
              MiniIconButton(Icons.copy_rounded, t('复制', 'Copy'), () => copyText(context, msg.content)),
              if (isLast) MiniIconButton(Icons.refresh_rounded, t('重新生成', 'Regenerate'), ctl.generating ? () {} : () => ctl.send(regenerate: true)),
              Builder(builder: (c) => MiniIconButton(Icons.more_vert, t('更多', 'More'), () => onMore(_centerOf(c)))),
            ]),
          ),
      ]),
    );
  }

  Offset _centerOf(BuildContext c) {
    final box = c.findRenderObject() as RenderBox?;
    return box == null ? Offset.zero : box.localToGlobal(box.size.center(Offset.zero));
  }
}

// ---------------------------------------------------------------------------- input bar

class ChatInputBar extends ConsumerStatefulWidget {
  final ChatController? ctl;
  final Character character;
  final Future<void> Function(String text, List<String> images) onSend;
  const ChatInputBar({super.key, required this.ctl, required this.character, required this.onSend});
  @override
  ConsumerState<ChatInputBar> createState() => ChatInputBarState();
}

class ChatInputBarState extends ConsumerState<ChatInputBar> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final List<String> _images = [];
  Message? _editing;

  void startEdit(Message m) {
    setState(() {
      _editing = m;
      _text.text = m.content;
    });
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _busy => widget.ctl?.generating ?? false;

  Future<void> _submit() async {
    final s = _text.text.trim();
    if (_busy) return;
    if (s.isEmpty && _images.isEmpty) return;
    final images = List<String>.from(_images);
    final editing = _editing;
    setState(() {
      _text.clear();
      _images.clear();
      _editing = null;
    });
    if (editing != null && widget.ctl != null) {
      await widget.ctl!.send(content: s, editMessageId: editing.id);
      return;
    }
    await widget.onSend(s, images);
  }

  Future<void> _pickImage(bool vision) async {
    if (!vision) {
      showError(context, t('当前模型不支持图片输入', 'The current model does not accept images'));
      return;
    }
    final f = await FilePicker.pickFile(type: FileType.image);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    final ext = (f.extension ?? 'png').toLowerCase();
    final mime = ext == 'jpg' ? 'jpeg' : ext;
    setState(() => _images.add('data:image/$mime;base64,${base64Encode(bytes)}'));
  }

  Future<void> _setContextMode(ChatController ctl, String mode) async {
    final ch = Character(jsonDecode(jsonEncode(widget.character.json)) as Map<String, dynamic>);
    ch.context['mode'] = mode;
    try {
      await ref.read(charactersProvider.notifier).save(ch);
      await ctl.refreshContext();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  void _contextCard(ChatController ctl) {
    final c = ctl.context;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              ContextRing(info: c, size: 36, stroke: 4),
              const SizedBox(width: 12),
              Text('${c.estimated ? '~' : ''}${fmtTokens(c.tokens)} / ${fmtTokens(c.max)}  (${(c.ratio * 100).toStringAsFixed(0)}%)', style: Theme.of(ctx).textTheme.titleMedium),
            ]),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'traditional', label: Text(t('传统压缩', 'Traditional')), icon: const Icon(Icons.compress_rounded)),
                ButtonSegment(value: 'instant', label: Text(t('即时压缩', 'Instant')), icon: const Icon(Icons.bolt_rounded)),
              ],
              selected: {c.mode == 'instant' ? 'instant' : 'traditional'},
              onSelectionChanged: (v) async {
                Navigator.pop(ctx);
                await _setContextMode(ctl, v.first);
              },
            ),
            const SizedBox(height: 8),
            if (c.mode == 'traditional' && c.threshold > 0) Text('${t('压缩阈值', 'Threshold')}: ${fmtTokens(c.threshold)}'),
            const SizedBox(height: 12),
            if (c.mode == 'traditional')
              FilledButton.tonalIcon(
                onPressed: ctl.generating
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        ctl.compressNow().catchError((e) {
                          if (mounted) showError(context, e);
                        });
                      },
                icon: const Icon(Icons.compress_rounded),
                label: Text(t('立即压缩', 'Compress now')),
              ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ch = widget.character;
    final model = ref.watch(characterModelProvider(ch.modelId));
    final appearance = ref.watch(appearanceProvider);
    final ctl = widget.ctl;
    final info = ctl?.context ?? const ContextInfo();
    final vision = model?.vision ?? false;

    if (context.isWatch) {
      return _WatchInput(info: info, busy: _busy, onStop: () => ctl?.stop(), onText: (s) => widget.onSend(s, const []));
    }

    final sendBtn = _busy
        ? IconButton.filled(onPressed: () => ctl?.stop(), icon: const Icon(Icons.stop_rounded), tooltip: t('停止', 'Stop'))
        : IconButton.filled(onPressed: _submit, icon: const Icon(Icons.arrow_upward_rounded), tooltip: t('发送', 'Send'));

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_editing != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 0, 0),
              child: Row(children: [
                Icon(Icons.edit_outlined, size: 14, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(child: Text(t('编辑消息后将从这里重新生成', 'Editing: replies after this message will be regenerated'), style: Theme.of(context).textTheme.labelSmall)),
                IconButton(iconSize: 16, onPressed: () => setState(() {
                  _editing = null;
                  _text.clear();
                }), icon: const Icon(Icons.close)),
              ]),
            ),
          if (_images.isNotEmpty)
            SizedBox(
              height: 64,
              child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(4), children: [
                for (var i = 0; i < _images.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Stack(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(base64Decode(_images[i].substring(_images[i].indexOf(',') + 1)), width: 56, height: 56, fit: BoxFit.cover)),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: InkWell(onTap: () => setState(() => _images.removeAt(i)), child: const CircleAvatar(radius: 9, child: Icon(Icons.close, size: 12))),
                      ),
                    ]),
                  ),
              ]),
            ),
          CallbackShortcuts(
            bindings: {
              if (appearance.enterToSend) const SingleActivator(LogicalKeyboardKey.enter): _submit,
            },
            child: TextField(
              controller: _text,
              focusNode: _focus,
              minLines: 1,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: t('和 ${ch.name} 聊天', 'Chat with ${ch.name}'),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          Row(children: [
            IconButton(
              tooltip: t('切换模型', 'Switch model'),
              onPressed: () => pickModelForCharacter(context, ref, ch),
              icon: ModelIcon(iconKey: model?.icon ?? '', name: model?.name ?? '?', size: 26),
            ),
            if (model?.reasoning ?? false) _ReasoningButton(character: ch),
            const Spacer(),
            IconButton(onPressed: () => _pickImage(vision), icon: Icon(Icons.add_rounded, color: vision ? null : scheme.outline), tooltip: t('添加图片', 'Add image')),
            ContextRing(info: info, onTap: ctl == null ? null : () => _contextCard(ctl)),
            const SizedBox(width: 4),
            sendBtn,
          ]),
        ]),
      ),
    );
  }
}

class _ReasoningButton extends ConsumerWidget {
  final Character character;
  const _ReasoningButton({required this.character});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = character.reasoningEffort;
    final scheme = Theme.of(context).colorScheme;
    const levels = ['', 'low', 'medium', 'high'];
    final labels = [t('关闭', 'Off'), t('低', 'Low'), t('中', 'Medium'), t('高', 'High')];
    return PopupMenuButton<String>(
      tooltip: t('推理强度', 'Reasoning effort'),
      initialValue: e,
      onSelected: (v) async {
        final c = Character(character.json);
        c.params['reasoning_effort'] = v;
        try {
          await ref.read(charactersProvider.notifier).save(c);
        } catch (err) {
          if (context.mounted) showError(context, err);
        }
      },
      itemBuilder: (c) => [for (var i = 0; i < levels.length; i++) CheckedPopupMenuItem(value: levels[i], checked: levels[i] == e, child: Text(labels[i]))],
      icon: Icon(e.isEmpty ? Icons.lightbulb_outline : Icons.lightbulb, color: e.isEmpty ? scheme.onSurfaceVariant : scheme.primary),
    );
  }
}

/// Watch: one round button opening a full-screen text input; context ring around it.
class _WatchInput extends StatelessWidget {
  final ContextInfo info;
  final bool busy;
  final VoidCallback onStop;
  final void Function(String) onText;
  const _WatchInput({required this.info, required this.busy, required this.onStop, required this.onText});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(alignment: Alignment.center, children: [
        ContextRing(info: info, size: 48, stroke: 3),
        Material(
          color: busy ? scheme.errorContainer : scheme.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: busy
                ? onStop
                : () async {
                    final s = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _WatchComposer()));
                    if (s != null && s.trim().isNotEmpty) onText(s.trim());
                  },
            child: SizedBox(width: 40, height: 40, child: Icon(busy ? Icons.stop_rounded : Icons.mic_none_rounded, color: busy ? scheme.onErrorContainer : scheme.onPrimary, size: 22)),
          ),
        ),
      ]),
    );
  }
}

class _WatchComposer extends StatefulWidget {
  const _WatchComposer();
  @override
  State<_WatchComposer> createState() => _WatchComposerState();
}

class _WatchComposerState extends State<_WatchComposer> {
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final inset = watchInset(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(inset, inset * 0.6, inset, 8),
        child: Column(children: [
          Expanded(
            child: TextField(
              controller: _c,
              autofocus: true,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(hintText: t('说点什么…', 'Say something…'), border: InputBorder.none),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            IconButton.filled(onPressed: () => Navigator.pop(context, _c.text), icon: const Icon(Icons.send_rounded, size: 18)),
          ]),
        ]),
      ),
    );
  }
}

// Mouse-wheel / rotary scrolling on watches is handled by the default scroll physics; this
// behavior enables drag scrolling with mouse on desktop for touch-like lists.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.trackpad};
}
