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
import '../../core/tokens.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/back_guard.dart';
import '../../widgets/common.dart';
import '../../widgets/fit_action_row.dart';
import '../../widgets/async_image.dart';
import '../../widgets/slide_drawer.dart';
import '../../core/theme.dart';
import '../../widgets/motion.dart';
import '../characters/character_editor.dart';
import '../memory/memory_page.dart';
import '../sidebar/sidebar.dart';
import 'chat_controller.dart';
import 'conversation_map.dart';
import 'message_rows.dart';
import 'model_picker.dart';
import 'plugin_ui.dart';

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
  final _drawer = GlobalKey<SlideDrawerState>();
  bool _sidebarOpen = true;
  bool _atBottom = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final at = _scroll.hasClients && _scroll.offset < 80;
      if (at != _atBottom) {
        setState(() => _atBottom = at);
        // Back at the newest messages: older ones scrolled through go back to the compact cache.
        if (at) _ctl?.trimToWindow();
      }
    });
  }

  @override
  void dispose() {
    _ctl?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _openMap(ChatController ctl) async {
    final seq = await showConversationMap(context, ctl);
    if (seq == null || !mounted) return;
    await jumpToSeq(ctl, seq);
  }

  /// Scrolls the chat to the message with [seq]: makes it live (thawing the cache or fetching
  /// older pages), then steps the reversed list toward its estimated position until the row
  /// is built, and finally brings it into view and flashes it.
  Future<void> jumpToSeq(ChatController ctl, int seq) async {
    final id = await ctl.reveal(seq);
    if (id == null || !mounted || ctl != _ctl) return;
    ctl.focus(id);
    for (var attempt = 0; attempt < 12; attempt++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !_scroll.hasClients) return;
      final target = chatFocusKey.currentContext;
      if (target != null) {
        await Scrollable.ensureVisible(
          target,
          alignment: 0.2,
          duration: Motion.of(context, Motion.medium2),
          curve: Motion.emphasized,
        );
        return;
      }
      // Rows run oldest to newest; the reversed list puts the newest at offset 0.
      final i = ctl.messages.indexWhere((m) => m.id == id);
      if (i < 0) return;
      final frac = 1 - (i + 0.5) / ctl.messages.length;
      final pos = _scroll.position;
      _scroll.jumpTo((pos.maxScrollExtent * frac).clamp(0, pos.maxScrollExtent));
    }
  }

  /// The controller for the selected conversation, or a draft for [ch] when none is selected:
  /// a new chat is not created until its first message is sent.
  ChatController? _controllerFor(String? convId, Character? ch) {
    final key = convId ?? (ch == null ? null : 'draft:${ch.id}');
    if (key == _ctlConv) return _ctl;
    _ctl?.dispose();
    _cache.clear();
    _ctlConv = key;
    if (key == null) {
      _ctl = null;
    } else if (convId == null) {
      _ctl = ChatController.draft(ref.read(apiProvider), ch!);
    } else {
      _ctl = ChatController(
        ref.read(apiProvider),
        convId,
        maxChars: ref.read(appearanceProvider).loadChars,
        windowMessages: ref.read(appearanceProvider).windowMessages,
        autoLoad: ref.read(appearanceProvider).autoLoadHistory,
      )
        ..onEvict = _cache.forget
        ..load();
      _ctl!.onPluginEvent = _pluginEvent(_ctl!);
    }
    return _ctl;
  }

  /// First send from a draft: create the conversation with the greeting shown, load it, then
  /// send on the new controller before anything else can touch it (no lost first message).
  Future<void> _startConversation(
    Character ch,
    String text,
    List<String> images,
  ) async {
    final draft = _ctl;
    if (draft == null || !draft.isDraft || draft.generating) return;
    draft.addPendingUser(text, images);
    final api = ref.read(apiProvider);
    final ChatController ctl;
    try {
      final j = await api.post(
        '/api/conversations',
        ch.newConversationBody(draft.draftGreeting),
      );
      final id = (j as Map)['id'] as String;
      ctl = ChatController(
        api,
        id,
        maxChars: ref.read(appearanceProvider).loadChars,
        windowMessages: ref.read(appearanceProvider).windowMessages,
        autoLoad: ref.read(appearanceProvider).autoLoadHistory,
      );
      await ctl.load();
      if (!mounted || _ctl != draft) {
        ctl.dispose();
        return;
      }
      draft.dispose();
      _cache.clear();
      ctl.onPluginEvent = _pluginEvent(ctl);
      _ctl = ctl;
      _ctlConv = id;
      ref.read(selectedConversationIdProvider.notifier).select(id);
      ref.invalidate(conversationsProvider(ch.id));
    } catch (e) {
      draft.clearPending();
      if (mounted) showError(context, e);
      return;
    }
    await ctl.send(content: text, images: images);
    if (mounted) ref.invalidate(conversationsProvider(ch.id));
  }

  void Function(Json) _pluginEvent(ChatController ctl) => (ev) {
        if (mounted) handlePluginEvent(context, ctl, ev);
      };

  /// "New chat" just opens a fresh draft; the greeting is picked with its swipe arrows.
  void newConversation(Character ch) {
    ref.read(selectedConversationIdProvider.notifier).select(null);
    if (_ctl?.isDraft ?? false) {
      // Already on a draft: reset it (greeting back to the first, pending text cleared).
      _ctlConv = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => BackGuard(
    isBusy: () => _drawer.currentState?.isOpen ?? false,
    onBusyBack: () => _drawer.currentState?.close(),
    child: _page(context),
  );

  Widget _page(BuildContext context) {
    final ff = context.formFactor;
    final ch = ref.watch(currentCharacterProvider);
    final convId = ref.watch(selectedConversationIdProvider);
    final ctl = _controllerFor(convId, ch);
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
            startConversation: (text, images) =>
                _startConversation(ch, text, images),
          );

    if (ff == FormFactor.watch) {
      // Watch: no app bar; a small title chip at the top opens the character/chat list.
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: body),
            // Watch navigation: a compact tonal button (48dp target) naming the character;
            // it opens the character/chat list.
            Positioned(
              top: 0,
              left: watchInset(context),
              right: watchInset(context),
              child: Center(
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: Insets.x3),
                    minimumSize: const Size(48, 40),
                    tapTargetSize: MaterialTapTargetSize.padded,
                    textStyle: Theme.of(context).textTheme.labelMedium,
                  ),
                  icon: ch == null
                      ? const Icon(Icons.menu_rounded, size: 18)
                      : CharacterAvatar(character: ch, size: 20),
                  label: Text(
                    ch?.name ?? 'RofuChat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    semanticsLabel: t('${ch?.name ?? 'RofuChat'}，打开对话列表', '${ch?.name ?? 'RofuChat'}, open chat list'),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        body: Sidebar(
                          onNewConversation: newConversation,
                          inDrawer: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final appBar = _ChatAppBar(
      textScaler: MediaQuery.textScalerOf(context),
      ctl: ctl,
      character: ch,
      onMenu: () {
        if (ff == FormFactor.desktop) {
          setState(() => _sidebarOpen = !_sidebarOpen);
        } else {
          _drawer.currentState?.open();
        }
      },
      onNew: ch == null ? null : () => newConversation(ch),
      onMap: ctl == null || ctl.isDraft ? null : () => _openMap(ctl),
    );

    if (ff == FormFactor.desktop) {
      return Scaffold(
        key: _scaffold,
        body: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: _sidebarOpen ? 1 : 0),
              duration: Motion.of(context, Motion.medium4),
              curve: Motion.emphasized,
              child: SizedBox(
                width: 301,
                child: Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Sidebar(onNewConversation: newConversation),
                    ),
                    const VerticalDivider(width: 1),
                  ],
                ),
              ),
              builder: (_, v, child) => SizedBox(
                width: 301 * v,
                child: v == 0
                    ? Offstage(child: child)
                    : ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.centerRight,
                          minWidth: 301,
                          maxWidth: 301,
                          child: child,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Scaffold(appBar: appBar, body: body),
            ),
          ],
        ),
      );
    }
    // Swipe right anywhere on the chat to pull the sidebar out (it follows the finger and
    // settles with an eased curve); the screen-edge strip is taken by Android's back gesture.
    return SlideDrawer(
      key: _drawer,
      width: math.min(320, MediaQuery.sizeOf(context).width * 0.85),
      openZone: ref.watch(appearanceProvider.select((a) => a.swipeZone)) / 10,
      handleBack: false, // BackGuard coordinates Back: keyboard, then drawer, then exit

      drawer: Sidebar(onNewConversation: newConversation, inDrawer: true),
      // With the keyboard up on a short window the app bar yields its height to the composer.
      child: Scaffold(key: _scaffold, appBar: tightWithKeyboard(context) ? null : appBar, body: body),
    );
  }
}

/// True when the keyboard is up and the remaining window is too short for the full chrome.
bool tightWithKeyboard(BuildContext context) {
  final mq = MediaQuery.of(context);
  return mq.viewInsets.bottom > 0 && mq.size.height - mq.viewInsets.bottom < kTightComposerHeight;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.theater_comedy_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              t('还没有角色', 'No characters yet'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CharacterEditorPage()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(t('新建或导入角色', 'Create or import a character')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small M3 top app bar (64dp) with the product's two-line title: conversation title
/// (titleLarge) over "character / model (provider)" (labelMedium). The bar grows with the
/// platform text scale instead of clipping.
class _ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final TextScaler textScaler;
  final ChatController? ctl;
  final Character? character;
  final VoidCallback onMenu;
  final VoidCallback? onNew;
  final VoidCallback? onMap;
  const _ChatAppBar({
    required this.textScaler,
    required this.ctl,
    required this.character,
    required this.onMenu,
    required this.onNew,
    this.onMap,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    math.max(64, Insets.x4 + textScaler.scale(28) + textScaler.scale(16)),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ch = character;
    final convId = ref.watch(selectedConversationIdProvider);
    final convs = ch == null
        ? null
        : ref.watch(conversationsProvider(ch.id)).value;
    final conv = convs?.where((c) => c.id == convId).firstOrNull;
    final model = ch == null
        ? null
        : ref.watch(characterModelProvider(ch.modelId));
    final providers =
        ref.watch(providersProvider).value ?? const <ProviderCfg>[];
    final prov = providers.where((p) => p.id == model?.providerId).firstOrNull;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final title = conv == null || conv.title.isEmpty
        ? t('新对话', 'New chat')
        : conv.title;
    final sub = ch == null
        ? ''
        : '${ch.name} / ${model?.name ?? t('未选择模型', 'No model')}${prov == null ? '' : ' (${prov.name})'}';
    return AppBar(
      toolbarHeight: preferredSize.height,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: onMenu,
        tooltip: t('侧边栏', 'Sidebar'),
      ),
      title: InkWell(
        onTap: ch == null
            ? null
            : () => pickModelForCharacter(context, ref, ch),
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleLarge,
              ),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          ),
        ),
      ),
      actions: [
        if (onMap != null)
          IconButton(
            onPressed: onMap,
            icon: const Icon(Icons.toc_rounded),
            tooltip: t('对话地图', 'Conversation map'),
          ),
        if (onNew != null)
          IconButton(
            onPressed: onNew,
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: t('新对话', 'New chat'),
          ),
        if (ch != null)
          OverflowMenu(
            entries: [
              if (conv != null)
                MenuEntry(t('重命名', 'Rename'), icon: Icons.drive_file_rename_outline_rounded, onPressed: () => _menu(context, ref, 'rename', ch, conv)),
              if (conv != null && ch.summarize)
                MenuEntry(t('立即压缩上下文', 'Compress context now'), icon: Icons.compress_rounded, onPressed: () => _menu(context, ref, 'compress', ch, conv)),
              if (conv != null)
                MenuEntry(t('立即整理记忆', 'Update memory now'), icon: Icons.auto_awesome_rounded, onPressed: () => _menu(context, ref, 'scan', ch, conv)),
              MenuEntry(t('角色记忆', 'Character memory'), icon: Icons.psychology_alt_rounded, onPressed: () => _menu(context, ref, 'memory', ch, conv)),
              MenuEntry(t('角色设置', 'Character settings'), icon: Icons.tune_rounded, onPressed: () => _menu(context, ref, 'edit', ch, conv)),
              if (conv != null)
                MenuEntry(t('删除对话', 'Delete chat'), icon: Icons.delete_outline_rounded, danger: true, onPressed: () => _menu(context, ref, 'delete', ch, conv)),
            ],
          ),
      ],
    );
  }

  Future<void> _menu(
    BuildContext context,
    WidgetRef ref,
    String v,
    Character ch,
    Conversation? conv,
  ) async {
    final api = ref.read(apiProvider);
    try {
      switch (v) {
        case 'rename':
          final s = await promptText(
            context,
            t('重命名对话', 'Rename chat'),
            initial: conv!.title,
            ok: t('重命名', 'Rename'),
          );
          if (s != null) {
            await api.patch('/api/conversations/${conv.id}', {'title': s});
            ref.invalidate(conversationsProvider(ch.id));
          }
        case 'compress':
          await ctl?.compressNow();
        case 'scan':
          final r = await api.post(
            '/api/conversations/${conv!.id}/memory_scan',
          );
          if (context.mounted) {
            final m = r is Map ? r : const {};
            showInfo(
              context,
              t(
                '记忆已整理：新增 ${m['added'] ?? 0}，更新 ${m['updated'] ?? 0}，删除 ${m['deleted'] ?? 0}',
                'Memory updated: ${m['added'] ?? 0} added, ${m['updated'] ?? 0} updated, ${m['deleted'] ?? 0} deleted',
              ),
            );
          }
        case 'memory':
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MemoryPage(characterId: ch.id)),
          );
        case 'edit':
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CharacterEditorPage(character: ch),
            ),
          );
        case 'delete':
          if (await confirm(context, t('删除这个对话？', 'Delete this chat?'), ok: t('删除', 'Delete'))) {
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
  final Future<void> Function(String text, List<String> images)
  startConversation;
  const _ChatBody({
    super.key,
    required this.ctl,
    required this.character,
    required this.cache,
    required this.scroll,
    required this.atBottom,
    required this.onNewConversation,
    required this.startConversation,
  });

  @override
  ConsumerState<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends ConsumerState<_ChatBody> {
  final _input = GlobalKey<ChatInputBarState>();

  void _toBottom() {
    final s = widget.scroll;
    if (s.hasClients && s.offset > 0 && Motion.reduced(context)) {
      s.jumpTo(0);
    } else if (s.hasClients && s.offset > 0) {
      s.animateTo(
        0,
        duration: Motion.of(context, Motion.medium2),
        curve: Motion.emphasizedDecelerate,
      );
    }
  }

  Future<void> _send(String text, List<String> images) async {
    final ctl = widget.ctl;
    if (ctl == null) return;
    _toBottom();
    if (ctl.isDraft) return widget.startConversation(text, images);
    await ctl.send(content: text, images: images);
    ref.invalidate(conversationsProvider(widget.character.id));
  }

  @override
  Widget build(BuildContext context) {
    final ctl = widget.ctl;
    final watch = context.isWatch;
    final list = ctl == null || (ctl.isDraft && ctl.messages.isEmpty)
        ? _EmptyChat(character: widget.character)
        : ListenableBuilder(
            listenable: ctl,
            builder: (context, _) => _MessageList(
              ctl: ctl,
              character: widget.character,
              cache: widget.cache,
              scroll: widget.scroll,
              onEdit: (m) {
                if (!ctl.isDraft) _input.currentState?.startEdit(m);
              },
            ),
          );
    final input = ctl == null
        ? ChatInputBar(
            key: _input,
            ctl: null,
            character: widget.character,
            onSend: _send,
          )
        : ListenableBuilder(
            listenable: ctl,
            builder: (context, _) => ChatInputBar(
              key: _input,
              ctl: ctl.isDraft ? null : ctl,
              character: widget.character,
              onSend: _send,
            ),
          );
    if (watch) {
      return Stack(
        children: [
          Positioned.fill(child: list),
          Positioned(left: 0, right: 0, bottom: 6, child: Center(child: input)),
        ],
      );
    }
    final appearance = ref.watch(appearanceProvider);
    Widget content = Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: list),
              // Jump to latest: a secondary utility, so a tonal icon button rather than a
              // FAB. It fades/scales in and out and takes no focus or taps while hidden.
              Positioned(
                right: 12,
                bottom: 8,
                child: _JumpToLatest(
                  visible: !widget.atBottom && ctl != null && !ctl.isDraft,
                  onPressed: _toBottom,
                ),
              ),
            ],
          ),
        ),
        input,
      ],
    );
    if (!appearance.fullWidth && context.isDesktop) {
      content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: content,
        ),
      );
    }
    return content;
  }
}

/// The row the list is asked to scroll to (one chat page is shown at a time).
final chatFocusKey = GlobalKey(debugLabel: 'chat-focus');

/// A brief highlight behind a row reached from the conversation map.
class _Flash extends StatelessWidget {
  final Widget child;
  const _Flash({required this.child});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.secondaryContainer;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: Motion.of(context, const Duration(milliseconds: 1600)),
      curve: Motion.emphasizedAccelerate,
      builder: (_, v, child) => DecoratedBox(
        decoration: BoxDecoration(color: c.withValues(alpha: 0.7 * v), borderRadius: Corners.rMd),
        child: child,
      ),
      child: child,
    );
  }
}

class _JumpToLatest extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;
  const _JumpToLatest({required this.visible, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final d = Motion.of(context, Motion.short4);
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeFocus(
        excluding: !visible,
        child: ExcludeSemantics(
          excluding: !visible,
          child: AnimatedScale(
            scale: visible ? 1 : 0.6,
            duration: d,
            curve: visible ? Motion.emphasizedDecelerate : Motion.emphasizedAccelerate,
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: d,
              curve: Motion.standard,
              child: IconButton.filledTonal(
                tooltip: t('回到最新', 'Jump to latest'),
                onPressed: onPressed,
                icon: const Icon(Icons.keyboard_double_arrow_down_rounded),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final Character character;
  const _EmptyChat({required this.character});
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CharacterAvatar(
              character: character,
              size: context.isWatch ? 48 : 72,
            ),
            const SizedBox(height: 12),
            Text(character.name, style: text.titleLarge),
            if (character.cardStr('creator_notes').isNotEmpty &&
                !context.isWatch)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  character.cardStr('creator_notes'),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: text.bodySmall,
                ),
              ),
          ],
        ),
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
  const _MessageList({
    required this.ctl,
    required this.character,
    required this.cache,
    required this.scroll,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ctl.loading && ctl.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctl.loadError != null && ctl.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(ctl.loadError!, textAlign: TextAlign.center),
        ),
      );
    }
    final appearance = ref.watch(appearanceProvider);
    final settings = ref.watch(settingsProvider).value;
    final models = ref.watch(modelsProvider).value ?? const <ModelCfg>[];
    final watch = context.isWatch;
    final rows = buildRows(
      ctl.messages,
      cache,
      streamingId: ctl.streamingId,
      generating: ctl.generating,
    );
    // Content margins: circular-watch inset; 12/16dp (compact / standard density) on
    // compact windows; 24dp from the medium window class up.
    final hInset = watch
        ? watchInset(context)
        : context.windowSizeClass != WindowSizeClass.compact
        ? Insets.x6
        : (appearance.compact ? Insets.x3 : Insets.x4);
    final base = chatBody(context);
    // The newest turn (from the last user message on) is laid out in its own sliver at the
    // bottom of the reversed list. At the very bottom the view follows the stream; once
    // scrolled up, _KeepStill offsets its growth so what the user is reading stays put.
    final lastUser = ctl.messages.lastWhere(
      (m) => m.isUser,
      orElse: () =>
          ctl.messages.isEmpty ? Message({'id': ''}) : ctl.messages.last,
    );
    var split = rows.indexWhere((r) => r.msg.id == lastUser.id);
    if (split < 0) split = rows.length;
    final older = rows.sublist(0, split);
    final newest = rows.sublist(split);
    final m = older.length;
    Widget build(ChatRow row) {
      Widget child = _row(context, ref, row, base, appearance, settings, models, watch);
      // The first row of a message the conversation map jumped to: findable, and flashed.
      if (row.msg.id == ctl.focusId && (row is UserRow || row is AssistantHeaderRow || row is SummaryRow)) {
        child = KeyedSubtree(key: chatFocusKey, child: _Flash(child: child));
      }
      return KeyedSubtree(key: ValueKey(row.key), child: child);
    }
    final list = CustomScrollView(
      controller: scroll,
      reverse: true,
      slivers: [
        KeepStillSliver(
          sliver: SliverPadding(
            padding: EdgeInsets.fromLTRB(hInset, 0, hInset, watch ? 64 : Insets.x2),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final row in newest) build(row),
                  _ListTail(ctl: ctl),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hInset, Insets.x2, hInset, 0),
          sliver: SliverList.builder(
            itemCount: m + 1,
            itemBuilder: (context, i) {
              if (i == m) {
                // Top of the (reversed) list: fetch the previous page once it scrolls into view.
                if (ctl.canLoadOlder && !ctl.loadingOlder) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => ctl.loadOlder(),
                  );
                }
                final loaded = ctl.loadedChars > 0
                    ? Text(
                        t(
                          '已加载 ${ctl.loadedCount} 条 · ${fmtCount(ctl.loadedChars)} 字 · ${fmtBytes(ctl.loadedBytes)}${ctl.hasMore ? ' · 后台加载中' : ''}',
                          'Loaded ${ctl.loadedCount} messages · ${fmtCount(ctl.loadedChars)} chars · ${fmtBytes(ctl.loadedBytes)}${ctl.hasMore ? ' · loading' : ''}',
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null;
                return Padding(
                  padding: const EdgeInsets.all(Insets.x3),
                  child: Column(
                    children: [
                      if (ctl.canLoadOlder)
                        SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(
                            semanticsLabel: t('正在加载更早的消息', 'Loading earlier messages'),
                          ),
                        ),
                      if (ctl.canLoadOlder && loaded != null)
                        const SizedBox(height: Insets.x2),
                      ?loaded,
                    ],
                  ),
                );
              }
              return build(older[m - 1 - i]);
            },
          ),
        ),
      ],
    );
    if (!watch) return SelectionArea(child: list);
    return list;
  }

  Widget _swipeNav(BuildContext context, Message m) => SwipeNav(
    index: m.swipeIndex,
    count: m.swipeCount,
    enabled: !ctl.generating,
    onSwipe: (i) async {
      try {
        await ctl.swipe(m, i);
      } catch (e) {
        if (context.mounted) showError(context, e);
      }
    },
  );

  Widget _row(
    BuildContext context,
    WidgetRef ref,
    ChatRow row,
    TextStyle base,
    dynamic appearance,
    UserSettings? settings,
    List<ModelCfg> models,
    bool watch,
  ) {
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
          swipeNav: _swipeNav(context, m),
        );
      case AssistantHeaderRow():
        if (watch) return const SizedBox(height: Insets.x2);
        final model = models.where((x) => x.id == m.model).firstOrNull;
        final name =
            model?.name ??
            (m.modelName.isNotEmpty ? m.modelName : character.name);
        return Padding(
          padding: EdgeInsets.only(
            top: appearance.compact ? Insets.x3 : Insets.x4,
            bottom: Insets.x1,
          ),
          child: Row(
            children: [
              if (appearance.showAvatars) ...[
                ModelIcon(
                  iconKey: model?.icon ?? m.modelIcon,
                  name: name,
                  size: 24, // frontend-spec §3.1: round 24dp model icon
                ),
                const SizedBox(width: Insets.x2),
              ],
              Flexible(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (ctl.floorOf(m) case final f?) ...[
                const SizedBox(width: Insets.x2),
                Text(
                  '#$f',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        );
      case StepsRow():
        return Appear(
          enabled: row.live,
          child: StepsCard(steps: row.steps, live: row.live, compact: watch),
        );
      case BlockRow():
        return Appear(
          enabled: m.id == ctl.streamingId,
          child: Opacity(
            opacity: m.visible ? 1 : kExcludedOpacity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: appearance.compact ? 0 : Insets.hairline,
              ),
              child: MarkdownSingleBlockRenderer(
                row.block,
                baseTextStyle: base,
              ),
            ),
          ),
        );
      case SummaryRow():
        return SummaryCard(
          msg: m,
          onEdit: () async {
            final s = await promptText(
              context,
              t('编辑摘要', 'Edit summary'),
              initial: m.content,
              maxLines: 12,
            );
            if (s != null) await ctl.editContent(m, s);
          },
        );
      case FooterRow():
        return Appear(
          enabled: m.id == ctl.justFinishedId,
          child: _AssistantFooter(
            ctl: ctl,
            msg: m,
            isLast: row.isLastAssistant,
            showTokens: appearance.showTokens && !watch,
            compact: watch,
            onEdit: () => onEdit(m),
            swipeNav: _swipeNav(context, m),
            onMore: (pos) => _messageMenu(context, ref, m, pos),
          ),
        );
    }
  }

  /// Message actions. [pos] is the pointer position for a secondary click or the anchor of
  /// the "More" button (popup menu); null for a touch long press (bottom sheet).
  Future<void> _messageMenu(
    BuildContext context,
    WidgetRef ref,
    Message m,
    Offset? pos,
  ) async {
    if (ctl.isDraft) return;
    final v = await showActions(context, [
      MenuAction('copy', Icons.copy_rounded, t('复制', 'Copy')),
      MenuAction('edit', Icons.edit_rounded, t('编辑', 'Edit')),
      MenuAction(
        'visible',
        m.visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        m.visible ? t('移出上下文', 'Exclude from context') : t('加入上下文', 'Include in context'),
      ),
      if (m.isAssistant && character.instant)
        MenuAction('actual', Icons.compress_rounded, t('查看/编辑压缩内容', 'View/edit compressed')),
      if (m.isAssistant && m.usage != null && context.isWatch)
        MenuAction('usage', Icons.data_usage_rounded, t('Token 用量', 'Token usage')),
      if (m.swipeCount > 1 && !ctl.generating)
        MenuAction('del_swipe', Icons.layers_clear_rounded, t('删除当前版本', 'Delete this version')),
      MenuAction('branch', Icons.call_split_rounded, t('从这里分支', 'Branch from here')),
      MenuAction('delete', Icons.delete_outline_rounded, t('删除', 'Delete'), danger: true),
    ], at: pos);
    if (v == null || !context.mounted) return;
    try {
      switch (v) {
        case 'copy':
          copyText(context, m.content);
        case 'edit':
          onEdit(m);
        case 'visible':
          await ctl.setVisible(m, !m.visible);
        case 'actual':
          await showActualDialog(context, ctl, m);
        case 'usage':
          final u = m.usage!;
          await showDialog(
            context: context,
            builder: (c) => AlertDialog(
              scrollable: true,
              title: Text(t('Token 用量', 'Token usage')),
              content: TokenIndicator(usage: u),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: Text(t('关闭', 'Close')),
                ),
              ],
            ),
          );
        case 'del_swipe':
          await ctl.deleteSwipe(m);
        case 'branch':
          final id = await ctl.branch(m);
          if (id != null) {
            ref.invalidate(conversationsProvider(character.id));
            ref.read(selectedConversationIdProvider.notifier).select(id);
          }
        case 'delete':
          if (await confirm(
            context,
            t('删除这条消息？', 'Delete this message?'),
            ok: t('删除', 'Delete'),
          )) {
            await ctl.deleteMessage(m);
          }
      }
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

Future<void> showActualDialog(
  BuildContext context,
  ChatController ctl,
  Message m,
) async {
  final ctlText = TextEditingController(text: m.actual ?? '');
  final scheme = Theme.of(context).colorScheme;
  final compact = MediaQuery.sizeOf(context).width < 600;
  Widget content(BuildContext c) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (m.actualStatus == 'failed')
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${t('摘要生成失败，已回退发送完整内容。', 'Summary failed; the full message is sent instead.')}\n${m.actualError ?? ''}',
            style: Theme.of(c).textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer),
          ),
        ),
      TextField(
        controller: ctlText,
        maxLines: compact ? null : 10,
        minLines: compact ? 8 : 3,
        decoration: InputDecoration(
          labelText: t('压缩内容', 'Compressed content'),
          hintText: t('（空）', '(empty)'),
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 8),
      // A contextual action inside the content, so the dialog keeps two actions.
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () async {
            Navigator.pop(c);
            await ctl.retryActual(m);
          },
          icon: const Icon(Icons.refresh_rounded),
          label: Text(t('重新生成压缩内容', 'Regenerate compressed content')),
        ),
      ),
    ],
  );
  Future<void> save(BuildContext c) async {
    Navigator.pop(c);
    await ctl.editActual(m, ctlText.text);
  }

  final title = t('压缩内容（发送给模型）', 'Compressed content (sent to the model)');
  await showDialog(
    context: context,
    builder: (c) => compact
        ? Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: t('取消', 'Cancel'),
                  onPressed: () => Navigator.pop(c),
                ),
                title: Text(title, maxLines: 2),
                actions: [
                  TextButton(onPressed: () => save(c), child: Text(t('保存', 'Save'))),
                  const SizedBox(width: 8),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: content(c),
              ),
            ),
          )
        : AlertDialog(
            scrollable: true,
            title: Text(title),
            content: content(c),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: Text(t('取消', 'Cancel')),
              ),
              TextButton(onPressed: () => save(c), child: Text(t('保存', 'Save'))),
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
    if (last.type == 'tool' && last.result == null) {
      return t('正在调用 ${last.name}…', 'Calling ${last.name}…');
    }
    if (last.type == 'reasoning') return t('思考中…', 'Thinking…');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final busy = ctl.generating || ctl.compressing;
    final status = busy ? _status() : null;
    final watch = context.isWatch;
    return AnimatedSwitcher(
      duration: Motion.of(context, Motion.medium1),
      switchInCurve: Motion.emphasizedDecelerate,
      switchOutCurve: Motion.emphasizedAccelerate,
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: SizeTransition(sizeFactor: a, axisAlignment: -1, child: child),
      ),
      child: !busy
          ? const SizedBox(
              key: ValueKey('idle'),
              height: 4,
              width: double.infinity,
            )
          : Padding(
              key: const ValueKey('busy'),
              padding: const EdgeInsets.fromLTRB(0, Insets.x3, 0, Insets.x2),
              child: Row(
                mainAxisAlignment: watch
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  LoadingBlob(size: watch ? 22 : 30),
                  AnimatedSize(
                    duration: Motion.of(context, Motion.short4),
                    curve: Motion.standard,
                    child: status == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(left: Insets.x3),
                            // Announced once per stage change, never per token.
                            child: Text(
                              status,
                              semanticsLabel: status,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                  ),
                ],
              ),
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
  final VoidCallback onEdit;
  final Widget swipeNav;
  final void Function(Offset?) onMore;
  const _AssistantFooter({
    required this.ctl,
    required this.msg,
    required this.isLast,
    required this.showTokens,
    required this.compact,
    required this.onEdit,
    required this.swipeNav,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notices = ctl.notices[msg.id] ?? const <String>[];
    final usage = msg.usage;
    return Opacity(
      opacity: msg.visible ? 1 : kExcludedOpacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (msg.error != null)
            Container(
              width: double.infinity,
              // Outlined error card (frontend-spec §3.1: red outline + retry).
              margin: const EdgeInsets.only(top: Insets.x2),
              padding: const EdgeInsets.fromLTRB(Insets.x3, Insets.x1, Insets.x1, Insets.x1),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.error),
                borderRadius: Corners.rMd,
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: scheme.error, size: 20),
                  const SizedBox(width: Insets.x2),
                  Expanded(
                    child: Text(
                      msg.error!,
                      style: AppTypography.chat(
                        context,
                        Theme.of(context).textTheme.bodyMedium,
                      ).copyWith(color: scheme.error),
                    ),
                  ),
                  if (isLast)
                    TextButton(
                      onPressed: ctl.generating
                          ? null
                          : () => ctl.send(regenerate: true),
                      child: Text(t('重试', 'Retry')),
                    ),
                ],
              ),
            ),
          for (final n in notices)
            Padding(
              padding: const EdgeInsets.only(top: Insets.x1),
              child: Text(
                n,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          if (compact)
            Row(
              children: [
                ActualStatusIcon(
                  msg: msg,
                  pending: ctl.actualPending.contains(msg.id),
                  onTapFailed: () => showActualDialog(context, ctl, msg),
                ),
                const Spacer(),
                if (ctl.isDraft)
                  swipeNav
                else
                  Builder(
                    builder: (c) => MiniIconButton(
                      Icons.more_horiz_rounded,
                      t('更多', 'More'),
                      () => onMore(_centerOf(c)),
                    ),
                  ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.x1),
              // One line that never wraps: scales down, then folds edit/copy (both in More).
              child: FitActionRow(
                children: [
                  if (!msg.visible) const ActionSlot(drop: 1, child: ContextTag()),
                  ActualStatusIcon(
                    msg: msg,
                    pending: ctl.actualPending.contains(msg.id),
                    onTapFailed: () => showActualDialog(context, ctl, msg),
                  ),
                  ActionSlot(
                    drop: ctl.isDraft ? 0 : 3,
                    child: MiniIconButton(
                      Icons.copy_rounded,
                      t('复制', 'Copy'),
                      () => copyText(context, msg.content),
                    ),
                  ),
                  swipeNav,
                  if (!ctl.isDraft) ...[
                    if (!compact)
                      ActionSlot(
                        drop: 2,
                        child: MiniIconButton(
                          Icons.edit_rounded,
                          t('编辑', 'Edit'),
                          onEdit,
                        ),
                      ),
                    if (isLast)
                      MiniIconButton(
                        Icons.refresh_rounded,
                        t('重新生成', 'Regenerate'),
                        ctl.generating
                            ? null
                            : () => ctl.send(regenerate: true),
                      ),
                    Builder(
                      builder: (c) => MiniIconButton(
                        Icons.more_vert_rounded,
                        t('更多', 'More'),
                        () => onMore(_centerOf(c)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Token counts get their own row under the action buttons.
          if (!compact && showTokens && usage != null)
            Padding(
              padding: const EdgeInsets.only(left: Insets.x1, bottom: Insets.x2),
              child: TokenIndicator(usage: usage),
            ),
        ],
      ),
    );
  }

  Offset _centerOf(BuildContext c) {
    final box = c.findRenderObject() as RenderBox?;
    return box == null
        ? Offset.zero
        : box.localToGlobal(box.size.center(Offset.zero));
  }
}

// ---------------------------------------------------------------------------- input bar

class ChatInputBar extends ConsumerStatefulWidget {
  final ChatController? ctl;
  final Character character;
  final Future<void> Function(String text, List<String> images) onSend;
  const ChatInputBar({
    super.key,
    required this.ctl,
    required this.character,
    required this.onSend,
  });
  @override
  ConsumerState<ChatInputBar> createState() => ChatInputBarState();
}

class ChatInputBarState extends ConsumerState<ChatInputBar> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final List<String> _images = [];
  Message? _editing;
  bool _hover = false;
  // The + button's secondary menu (attachments), revealed inside the composer.
  bool _more = false;

  @override
  void initState() {
    super.initState();
    // The composer shell shows the focused state of its field.
    _focus.addListener(() => setState(() {}));
  }

  /// What the user had typed (and attached) before starting an edit; restored afterwards so
  /// editing a message never eats an unfinished draft.
  (String, List<String>)? _draft;

  void startEdit(Message m) {
    setState(() {
      if (_editing == null) _draft = (_text.text, List<String>.from(_images));
      _editing = m;
      _images.clear();
      _text.text = m.content;
      _text.selection = TextSelection.collapsed(offset: _text.text.length);
    });
    _focus.requestFocus();
  }

  void _endEdit() {
    final d = _draft;
    _editing = null;
    _draft = null;
    _text.text = d?.$1 ?? '';
    _text.selection = TextSelection.collapsed(offset: _text.text.length);
    _images
      ..clear()
      ..addAll(d?.$2 ?? const []);
  }

  /// Saves the edited text in place; nothing is regenerated.
  Future<void> _saveEditOnly() async {
    final editing = _editing;
    final ctl = widget.ctl;
    if (editing == null || ctl == null) return;
    final s = _text.text.trim();
    if (s.isEmpty) return;
    try {
      await ctl.editContent(editing, s);
      if (mounted) setState(_endEdit);
    } catch (e) {
      if (mounted) showError(context, e);
    }
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
    final editing = _editing;
    if (editing != null && !editing.isUser) {
      return _saveEditOnly(); // assistant edits only save
    }
    if (_busy) return;
    if (s.isEmpty && _images.isEmpty) return;
    final images = List<String>.from(_images);
    setState(() {
      if (editing != null) {
        _endEdit();
      } else {
        _text.clear();
        _images.clear();
      }
    });
    if (editing != null && widget.ctl != null) {
      await widget.ctl!.send(content: s, editMessageId: editing.id);
      return;
    }
    await widget.onSend(s, images);
  }

  Future<void> _pickImage() async {
    final f = await FilePicker.pickFile(type: FileType.image);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    final ext = (f.extension ?? 'png').toLowerCase();
    final mime = ext == 'jpg' ? 'jpeg' : ext;
    setState(
      () => _images.add('data:image/$mime;base64,${base64Encode(bytes)}'),
    );
  }

  Future<void> _setCompression(
    ChatController ctl, {
    bool? instant,
    bool? summarize,
  }) async {
    final ch = Character(
      jsonDecode(jsonEncode(widget.character.json)) as Map<String, dynamic>,
    );
    ch.setCompression(instant: instant, summarize: summarize);
    try {
      await ref.read(charactersProvider.notifier).save(ch);
      await ctl.refreshContext();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  /// Context sheet. Switches apply in place and the sheet stays open (it only closes on a
  /// barrier tap, a drag or "Compress now"); values follow the controller live.
  void _contextCard(ChatController ctl) {
    bool? summarize, instant; // optimistic values while a save is in flight
    showActionSheet<void>(
      context,
      padding: const EdgeInsets.fromLTRB(Insets.x6, 0, Insets.x6, Insets.x4),
      (ctx) => [
        StatefulBuilder(
          builder: (ctx, setSheet) => ListenableBuilder(
            listenable: ctl,
            builder: (ctx, _) {
              final c = ctl.context;
              final sum = summarize ?? c.summarize;
              final inst = instant ?? c.instant;
              Future<void> apply({bool? s, bool? i}) async {
                setSheet(() {
                  summarize = s ?? summarize;
                  instant = i ?? instant;
                });
                await _setCompression(ctl, summarize: s, instant: i);
                if (ctx.mounted) {
                  setSheet(() {
                    summarize = null;
                    instant = null;
                  });
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ContextRing(info: c, size: 36, stroke: 4),
                      const SizedBox(width: Insets.x3),
                      Expanded(
                        child: Text(
                          '${c.estimated ? '~' : ''}${fmtTokens(c.tokens)} / ${fmtTokens(c.max)}  (${(c.ratio * 100).toStringAsFixed(0)}%)',
                          style: Theme.of(ctx).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Insets.x3),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.compress_rounded),
                    title: Text(t('摘要压缩', 'Summary compression')),
                    subtitle: sum && c.threshold > 0
                        ? Text('${t('压缩阈值', 'Threshold')}: ${fmtTokens(c.threshold)}')
                        : null,
                    value: sum,
                    onChanged: (v) => apply(s: v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.bolt_rounded),
                    title: Text(t('即时压缩', 'Instant compression')),
                    value: inst,
                    onChanged: (v) => apply(i: v),
                  ),
                  const SizedBox(height: Insets.x2),
                  if (sum)
                    FilledButton.tonalIcon(
                      onPressed: ctl.generating || ctl.compressing
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              ctl.compressNow().catchError((e) {
                                if (mounted) showError(context, e);
                              });
                            },
                      icon: const Icon(Icons.compress_rounded),
                      label: Text(ctl.compressing ? t('正在压缩…', 'Compressing…') : t('立即压缩', 'Compress now')),
                    ),
                ],
              );
            },
          ),
        ),
      ],
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
      return _WatchInput(
        info: info,
        busy: _busy,
        onStop: () => ctl?.stop(),
        onText: (s) => widget.onSend(s, const []),
      );
    }

    final editingAssistant = _editing != null && !_editing!.isUser;
    final sendBtn = editingAssistant
        ? IconButton.filled(
            onPressed: _saveEditOnly,
            icon: const Icon(Icons.check_rounded),
            tooltip: t('保存', 'Save'),
          )
        : _busy
        ? IconButton.filled(
            onPressed: () => ctl?.stop(),
            icon: const Icon(Icons.stop_rounded),
            tooltip: t('停止', 'Stop'),
          )
        : IconButton.filled(
            onPressed: _submit,
            icon: const Icon(Icons.arrow_upward_rounded),
            tooltip: t('发送', 'Send'),
          );

    // Custom composer component (frontend-spec §3.1 large rounded card) with M3 text-field
    // states: outlineVariant at rest, onSurfaceVariant on hover, a 2dp primary outline when
    // focused.
    final focused = _focus.hasFocus;
    final border = focused
        ? scheme.primary
        : _hover
        ? scheme.onSurfaceVariant
        : scheme.outlineVariant;
    // Short window with the keyboard up (square watches, landscape): keep the text field
    // and send button only, so the composer always fits above the IME.
    final tight = tightWithKeyboard(context);
    final menus = ctl == null ? const <PluginMenu>[] : (ref.watch(pluginMenusProvider(ctl.conversationId)).value ?? const <PluginMenu>[]);
    final moreMenu = Collapsible(
      open: _more && !tight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Insets.x2, 0, Insets.x2, Insets.x2),
        child: Wrap(
          spacing: Insets.x2,
          runSpacing: Insets.x2,
          children: [
            for (final menu in menus)
              _ComposerAction(
                icon: pluginMenuIcon(menu.icon),
                label: menu.label,
                tooltip: menu.pluginName,
                onPressed: _busy || ctl == null
                    ? null
                    : () {
                        setState(() => _more = false);
                        ctl.invokeMenu(menu);
                      },
              ),
            _ComposerAction(
              icon: Icons.image_outlined,
              label: t('图片', 'Image'),
              tooltip: vision ? null : t('当前模型不支持图片输入', 'The current model does not accept images'),
              onPressed: vision
                  ? () {
                      setState(() => _more = false);
                      _pickImage();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
    return SafeArea(
      top: false,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
        duration: Motion.of(context, Motion.short3),
        curve: Motion.standard,
        margin: const EdgeInsets.fromLTRB(Insets.x2, Insets.x1, Insets.x2, Insets.x2),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: Corners.rXl,
          border: Border.all(color: border, width: focused ? 2 : 1),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: focused ? Insets.x1 : Insets.x1 + 1,
          vertical: focused ? Insets.x1 - 1 : Insets.x1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_editing != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(Insets.x3, Insets.x1, 0, 0),
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 16, color: scheme.primary),
                    const SizedBox(width: Insets.x2),
                    Expanded(
                      child: Text(
                        _editing!.isUser
                            ? t(
                                '编辑消息 · 发送 = 保存并重新生成',
                                'Editing · Send = save & regenerate',
                              )
                            : t('编辑回复', 'Editing reply'),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    if (_editing!.isUser)
                      TextButton(
                        onPressed: _saveEditOnly,
                        child: Text(t('仅保存', 'Save only')),
                      ),
                    IconButton(
                      iconSize: 20,
                      tooltip: t('取消编辑', 'Cancel edit'),
                      onPressed: () => setState(_endEdit),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
            if (_images.isNotEmpty)
              SizedBox(
                height: 64,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(Insets.x1),
                  children: [
                    for (var i = 0; i < _images.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: Insets.x2),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: Corners.rSm,
                              child: AsyncImage(source: _images[i], width: 56, height: 56),
                            ),
                            // A 48dp target around the small remove glyph.
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  minimumSize: const Size.square(48),
                                  alignment: Alignment.topRight,
                                  padding: const EdgeInsets.all(4),
                                ),
                                tooltip: t('移除图片 ${i + 1}', 'Remove image ${i + 1}'),
                                onPressed: () =>
                                    setState(() => _images.removeAt(i)),
                                icon: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: scheme.inverseSurface,
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: scheme.onInverseSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CallbackShortcuts(
              bindings: {
                if (appearance.enterToSend)
                  const SingleActivator(LogicalKeyboardKey.enter): _submit,
              },
              child: TextField(
                controller: _text,
                focusNode: _focus,
                minLines: 1,
                maxLines: tight ? 3 : 8,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: chatBody(context),
                decoration: InputDecoration(
                  hintText: t('和 ${ch.name} 聊天', 'Chat with ${ch.name}'),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Insets.x3,
                    vertical: Insets.x3,
                  ),
                ),
              ),
            ),
                ),
                if (tight) sendBtn,
              ],
            ),
            if (!tight) Row(
              children: [
                IconButton(
                  tooltip: t('切换模型', 'Switch model'),
                  onPressed: () => pickModelForCharacter(context, ref, ch),
                  icon: ModelIcon(
                    iconKey: model?.icon ?? '',
                    name: model?.name ?? '?',
                    size: 26,
                  ),
                ),
                if (model?.reasoning ?? false) _ReasoningButton(character: ch),
                const Spacer(),
                IconButton(
                  isSelected: _more,
                  onPressed: () => setState(() => _more = !_more),
                  tooltip: _more ? t('收起', 'Close') : t('更多输入', 'More inputs'),
                  icon: AnimatedRotation(
                    turns: _more ? 0.125 : 0,
                    duration: Motion.of(context, Motion.short4),
                    curve: Motion.emphasized,
                    child: const Icon(Icons.add_rounded),
                  ),
                ),
                ContextRing(
                  info: info,
                  onTap: ctl == null ? null : () => _contextCard(ctl),
                ),
                sendBtn,
              ],
            ),
            moreMenu,
          ],
        ),
      ),
      ),
    );
  }
}

/// Height (window minus keyboard) below which the composer drops its action row.
const double kTightComposerHeight = 260;

/// One entry of the composer's + menu: a tonal square button with a label under it.
class _ComposerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? tooltip;
  final VoidCallback? onPressed;
  const _ComposerAction({required this.icon, required this.label, this.tooltip, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final button = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            minimumSize: const Size.square(56),
            shape: const RoundedRectangleBorder(borderRadius: Corners.rLg),
          ),
        ),
        const SizedBox(height: Insets.x1),
        Text(label, style: text.labelMedium?.copyWith(color: onPressed == null ? scheme.onSurface.withValues(alpha: 0.38) : scheme.onSurfaceVariant)),
      ],
    );
    return Semantics(
      button: true,
      label: label,
      child: tooltip == null ? button : Tooltip(message: tooltip!, child: button),
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
    final labels = [
      t('关闭', 'Off'),
      t('低', 'Low'),
      t('中', 'Medium'),
      t('高', 'High'),
    ];
    Future<void> set(String v) async {
      final c = Character(character.json);
      c.params['reasoning_effort'] = v;
      try {
        await ref.read(charactersProvider.notifier).save(c);
      } catch (err) {
        if (context.mounted) showError(context, err);
      }
    }

    // Anchored single-choice menu (MenuAnchor + radio items); the button is a toggle whose
    // selected state is "reasoning on".
    return MenuAnchor(
      menuChildren: [
        for (var i = 0; i < levels.length; i++)
          RadioMenuButton<String>(
            value: levels[i],
            groupValue: e,
            onChanged: (v) => set(v ?? ''),
            child: Text(labels[i]),
          ),
      ],
      builder: (context, menu, _) => IconButton(
        tooltip: '${t('推理强度', 'Reasoning effort')}: ${labels[levels.indexOf(e).clamp(0, 3)]}',
        isSelected: e.isNotEmpty,
        icon: Icon(Icons.lightbulb_outline_rounded, color: scheme.onSurfaceVariant),
        selectedIcon: Icon(Icons.lightbulb_rounded, color: scheme.primary),
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      ),
    );
  }
}

/// Watch: one round button opening a full-screen text input; context ring around it.
/// The whole 52dp disc (ring included) is the target; the 40dp fill is its visual.
class _WatchInput extends StatelessWidget {
  final ContextInfo info;
  final bool busy;
  final VoidCallback onStop;
  final void Function(String) onText;
  const _WatchInput({
    required this.info,
    required this.busy,
    required this.onStop,
    required this.onText,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = busy ? t('停止生成', 'Stop generating') : t('输入消息', 'Write a message');
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        value: ContextRing.describe(info),
        excludeSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: busy
                ? onStop
                : () async {
                    final s = await Navigator.of(context).push<String>(
                      MaterialPageRoute(builder: (_) => const _WatchComposer()),
                    );
                    if (s != null && s.trim().isNotEmpty) onText(s.trim());
                  },
            child: SizedBox.square(
              dimension: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ContextRing(info: info, size: 48, stroke: 3),
                  Ink(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: busy ? scheme.errorContainer : scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      busy ? Icons.stop_rounded : Icons.mic_none_rounded,
                      color: busy ? scheme.onErrorContainer : scheme.onPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _c,
                autofocus: true,
                maxLines: null,
                expands: true,
                style: chatBody(context),
                decoration: InputDecoration(
                  hintText: t('说点什么…', 'Say something…'),
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: t('取消', 'Cancel'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
                IconButton.filled(
                  tooltip: t('发送', 'Send'),
                  onPressed: () => Navigator.pop(context, _c.text),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Mouse-wheel / rotary scrolling on watches is handled by the default scroll physics; this
// behavior enables drag scrolling with mouse on desktop for touch-like lists.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
