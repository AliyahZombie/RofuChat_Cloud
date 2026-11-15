import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/form_factor.dart';
import '../../core/i18n.dart';
import '../../core/tokens.dart';
import '../../models/models.dart';
import 'chat_controller.dart';

/// One line of the conversation map (GET /api/conversations/{id}/map, docs/api.md).
class MapItem {
  final String id;
  final int seq;
  final String role;
  final bool visible;
  final String preview;
  final bool hasImages;
  final int? matchStart;
  final int? matchLen;
  const MapItem({
    required this.id,
    required this.seq,
    required this.role,
    required this.visible,
    required this.preview,
    this.hasImages = false,
    this.matchStart,
    this.matchLen,
  });

  factory MapItem.fromJson(Map<String, dynamic> j) => MapItem(
        id: j['id'] as String? ?? '',
        seq: (j['seq'] as num?)?.toInt() ?? 0,
        role: j['kind'] == 'summary' ? 'summary' : j['role'] as String? ?? '',
        visible: j['visible'] as bool? ?? true,
        preview: j['preview'] as String? ?? '',
        hasImages: j['has_images'] as bool? ?? false,
        matchStart: (j['match_start'] as num?)?.toInt(),
        matchLen: (j['match_len'] as num?)?.toInt(),
      );

  /// Fallback for servers without the map route: built from the messages loaded locally.
  factory MapItem.fromMessage(Message m, {String q = ''}) {
    final flat = m.content.replaceAll(RegExp(r'\s+'), ' ').trim();
    var start = 0;
    int? ms;
    if (q.isNotEmpty) {
      final i = flat.toLowerCase().indexOf(q.toLowerCase());
      start = (i - 16).clamp(0, flat.length);
      ms = i - start + (start > 0 ? 1 : 0);
    }
    final body = flat.substring(start, (start + 60).clamp(0, flat.length));
    return MapItem(
      id: m.id,
      seq: m.seq,
      role: m.isSummary ? 'summary' : m.role,
      visible: m.visible,
      preview: '${start > 0 ? '…' : ''}$body',
      matchStart: ms,
      matchLen: q.isEmpty ? null : q.length,
    );
  }
}

/// Opens the conversation map: a compact, searchable list of every message (only the start of
/// each is fetched). Resolves to the seq of the message tapped, or null.
Future<int?> showConversationMap(BuildContext context, ChatController ctl) {
  final body = _ConversationMap(ctl: ctl);
  if (context.isDesktop || MediaQuery.sizeOf(context).width >= 600) {
    // M3 modal side sheet from the end edge.
    return showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: t('关闭对话地图', 'Close conversation map'),
      transitionDuration: Motion.of(context, Motion.medium2),
      pageBuilder: (c, _, _) => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Material(
          color: Theme.of(c).colorScheme.surfaceContainerLow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.horizontal(start: Radius.circular(Corners.lg)),
          ),
          child: SizedBox(width: 400, height: double.infinity, child: SafeArea(child: body)),
        ),
      ),
      transitionBuilder: (c, a, _, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: a, curve: Motion.emphasizedDecelerate, reverseCurve: Motion.emphasizedAccelerate),
        ),
        child: child,
      ),
    );
  }
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (c) => SizedBox(height: MediaQuery.sizeOf(c).height * 0.85, child: body),
  );
}

class _ConversationMap extends StatefulWidget {
  final ChatController ctl;
  const _ConversationMap({required this.ctl});
  @override
  State<_ConversationMap> createState() => _ConversationMapState();
}

class _ConversationMapState extends State<_ConversationMap> {
  final _q = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  List<MapItem> _items = const [];
  int _total = 0;
  bool _loading = true;
  String? _error;
  int _req = 0;
  bool _scrolledToEnd = false;

  Api get _api => widget.ctl.api;

  @override
  void initState() {
    super.initState();
    _fetch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _fetch(String q) async {
    final req = ++_req;
    setState(() {
      _loading = true;
      _error = null;
    });
    List<MapItem> items;
    int total;
    try {
      final j = await _api.get('/api/conversations/${widget.ctl.conversationId}/map', query: {
        'chars': '48',
        if (q.isNotEmpty) 'q': q,
      });
      final m = Map<String, dynamic>.from(j as Map);
      items = ((m['items'] as List?) ?? const [])
          .map((e) => MapItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      total = (m['total'] as num?)?.toInt() ?? items.length;
    } catch (e) {
      // Older servers: map what is loaded locally.
      final local = widget.ctl.messages
          .where((m) => q.isEmpty || m.content.toLowerCase().contains(q.toLowerCase()))
          .map((m) => MapItem.fromMessage(m, q: q))
          .toList();
      items = local;
      total = local.length;
      if (e is! ApiException || e.status != 404) _error = '$e';
    }
    if (!mounted || req != _req) return;
    setState(() {
      _items = items;
      _total = total;
      _loading = false;
    });
    // Without a query, open at the newest messages.
    if (q.isEmpty && !_scrolledToEnd) {
      _scrolledToEnd = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });
    }
  }

  void _onQuery(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _fetch(v.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final searching = _q.text.trim().isNotEmpty;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Insets.x4, Insets.x2, Insets.x4, Insets.x2),
          child: Row(
            children: [
              Expanded(child: Text(t('对话地图', 'Conversation map'), style: text.titleLarge)),
              Text(
                searching ? t('$_total 条匹配', '$_total matches') : t('$_total 条', '$_total messages'),
                style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.x4),
          child: SearchBar(
            controller: _q,
            hintText: t('搜索消息', 'Search messages'),
            leading: const Icon(Icons.search_rounded),
            elevation: const WidgetStatePropertyAll(0),
            trailing: [
              if (searching)
                IconButton(
                  tooltip: t('清除', 'Clear'),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _q.clear();
                    _scrolledToEnd = false;
                    _fetch('');
                  },
                ),
            ],
            onChanged: (v) {
              setState(() {});
              _onQuery(v);
            },
          ),
        ),
        if (_loading) const LinearProgressIndicator() else const SizedBox(height: 4),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(Insets.x2),
            child: Text(_error!, style: text.bodySmall?.copyWith(color: scheme.error)),
          ),
        Expanded(
          child: !_loading && _items.isEmpty
              ? Center(child: Text(searching ? t('没有匹配的消息', 'No matching messages') : t('还没有消息', 'No messages yet')))
              : Scrollbar(
                  controller: _scroll,
                  interactive: true,
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(vertical: Insets.x2),
                    itemExtent: 48,
                    itemCount: _items.length,
                    itemBuilder: (c, i) => _MapRow(item: _items[i], onTap: () => Navigator.pop(context, _items[i].seq)),
                  ),
                ),
        ),
      ],
    );
  }
}

class _MapRow extends StatelessWidget {
  final MapItem item;
  final VoidCallback onTap;
  const _MapRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (icon, color, label) = switch (item.role) {
      'user' => (Icons.person_rounded, scheme.primary, t('用户', 'User')),
      'summary' => (Icons.compress_rounded, scheme.tertiary, t('摘要', 'Summary')),
      _ => (Icons.smart_toy_outlined, scheme.secondary, t('角色', 'Character')),
    };
    final style = text.bodyMedium?.copyWith(color: item.visible ? scheme.onSurface : scheme.onSurfaceVariant);
    final p = item.preview.isEmpty ? t('（无文字）', '(no text)') : item.preview;
    final spans = <TextSpan>[];
    final ms = item.matchStart, ml = item.matchLen;
    final chars = p.runes.toList();
    if (ms != null && ml != null && ml > 0 && ms >= 0 && ms + ml <= chars.length) {
      spans.add(TextSpan(text: String.fromCharCodes(chars.sublist(0, ms))));
      spans.add(TextSpan(
        text: String.fromCharCodes(chars.sublist(ms, ms + ml)),
        style: TextStyle(backgroundColor: scheme.tertiaryContainer, color: scheme.onTertiaryContainer),
      ));
      spans.add(TextSpan(text: String.fromCharCodes(chars.sublist(ms + ml))));
    } else {
      spans.add(TextSpan(text: p));
    }
    return InkWell(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: '$label #${item.seq}: $p',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.x4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: Insets.x3),
              Expanded(
                child: Text.rich(TextSpan(style: style, children: spans), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (item.hasImages) ...[
                const SizedBox(width: Insets.x2),
                Icon(Icons.image_outlined, size: 16, color: scheme.onSurfaceVariant),
              ],
              if (!item.visible) ...[
                const SizedBox(width: Insets.x2),
                Icon(Icons.visibility_off_outlined, size: 16, color: scheme.onSurfaceVariant),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
