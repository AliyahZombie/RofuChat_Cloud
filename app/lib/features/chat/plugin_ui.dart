import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/i18n.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';
import 'chat_controller.dart';

/// Renders the plugin events of a chat or menu stream (docs/api.md, Plugins): toasts and
/// notifications as snackbars, dialogs as M3 dialogs whose answer goes back to the server.
void handlePluginEvent(BuildContext context, ChatController ctl, Json ev) {
  if (!context.mounted) return;
  final payload = (ev['payload'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
  switch (ev['type']) {
    case 'plugin_ui':
      switch (ev['kind']) {
        case 'toast':
          final ms = (payload['duration_ms'] as num?)?.toInt() ?? 4000;
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text('${payload['message'] ?? ''}'), duration: Duration(milliseconds: ms.clamp(1000, 10000))));
        case 'notify':
          // In-app notification: system notifications need a platform plugin per OS.
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
            content: _NotifyContent(title: '${payload['title'] ?? ''}', body: '${payload['body'] ?? ''}'),
            showCloseIcon: true,
            duration: const Duration(seconds: 6),
          ));
        case 'dialog':
          final callId = ev['call_id'] as String?;
          if (callId == null) return;
          unawaited(_showPluginDialog(context, ctl, callId, payload));
      }
    case 'plugin_error':
      showError(context, t('插件出错：${ev['error'] ?? ev['code'] ?? ''}', 'Plugin error: ${ev['error'] ?? ev['code'] ?? ''}'));
    case 'plugin_cancelled':
      showInfo(context, t('插件取消了发送：${ev['reason'] ?? ''}', 'A plugin cancelled the send: ${ev['reason'] ?? ''}'));
    case 'plugin_result':
      final r = ev['result'];
      if (r is String && r.isNotEmpty) showInfo(context, r);
  }
}

class _NotifyContent extends StatelessWidget {
  final String title, body;
  const _NotifyContent({required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme.onInverseSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) Text(title, style: text.titleSmall?.copyWith(color: color)),
        if (body.isNotEmpty) Text(body, style: text.bodyMedium?.copyWith(color: color)),
      ],
    );
  }
}

Future<void> _showPluginDialog(BuildContext context, ChatController ctl, String callId, Map<String, dynamic> p) async {
  final actions = [for (final a in (p['actions'] as List?) ?? const []) (a as Map).cast<String, dynamic>()];
  final input = (p['input'] as Map?)?.cast<String, dynamic>();
  final timeout = (p['timeout_ms'] as num?)?.toInt() ?? 5000;
  final ctrl = input == null ? null : TextEditingController(text: '${input['initial'] ?? ''}');
  final result = await showDialog<(String, String?)?>(
    context: context,
    builder: (ctx) => _PluginDialog(payload: p, actions: actions, input: input, controller: ctrl, timeoutMs: timeout),
  );
  ctrl?.dispose();
  // Closed by timeout or dismissed: null action lets the server use the dialog's default.
  await ctl.replyDialog(callId, result?.$1, result?.$2);
}

class _PluginDialog extends StatefulWidget {
  final Map<String, dynamic> payload;
  final List<Map<String, dynamic>> actions;
  final Map<String, dynamic>? input;
  final TextEditingController? controller;
  final int timeoutMs;
  const _PluginDialog({required this.payload, required this.actions, required this.input, required this.controller, required this.timeoutMs});
  @override
  State<_PluginDialog> createState() => _PluginDialogState();
}

class _PluginDialogState extends State<_PluginDialog> {
  late final DateTime _deadline = DateTime.now().add(Duration(milliseconds: widget.timeoutMs));
  Timer? _timer;
  int _left = 0;

  @override
  void initState() {
    super.initState();
    _left = (widget.timeoutMs / 1000).ceil();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final ms = _deadline.difference(DateTime.now()).inMilliseconds;
      if (ms <= 0) {
        _timer?.cancel();
        if (mounted) Navigator.of(context).pop();
        return;
      }
      final s = (ms / 1000).ceil();
      if (s != _left && mounted) setState(() => _left = s);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payload;
    final body = '${p['body'] ?? ''}';
    final def = '${p['default_action'] ?? ''}';
    final maxLen = (widget.input?['max_length'] as num?)?.toInt();
    final defLabel = widget.actions.where((a) => a['id'] == def).firstOrNull?['label'] ?? def;
    return AlertDialog(
      title: Text('${p['title'] ?? ''}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (body.isNotEmpty) Text(body),
            if (widget.controller != null) ...[
              if (body.isNotEmpty) const SizedBox(height: 12),
              TextField(
                controller: widget.controller,
                autofocus: true,
                maxLength: maxLen,
                minLines: 1,
                maxLines: 6,
                decoration: InputDecoration(labelText: '${widget.input?['label'] ?? ''}'),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              t('$_left 秒后自动选择「$defLabel」', 'Picks "$defLabel" in ${_left}s'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      actions: [
        for (final a in widget.actions)
          TextButton(
            onPressed: () => Navigator.of(context).pop(('${a['id']}', widget.controller?.text)),
            child: Text('${a['label'] ?? a['id']}'),
          ),
      ],
    );
  }
}

/// Material icon for a plugin menu's `icon` name; unknown names fall back to a puzzle piece.
IconData pluginMenuIcon(String? name) => switch (name) {
      'star' => Icons.star_rounded,
      'bolt' => Icons.bolt_rounded,
      'edit' => Icons.edit_rounded,
      'note' => Icons.sticky_note_2_outlined,
      'book' => Icons.menu_book_rounded,
      'dice' || 'casino' => Icons.casino_rounded,
      'magic' || 'auto_awesome' => Icons.auto_awesome_rounded,
      'settings' => Icons.settings_rounded,
      'send' => Icons.send_rounded,
      'search' => Icons.search_rounded,
      'memory' || 'psychology' => Icons.psychology_alt_rounded,
      'save' => Icons.save_rounded,
      'refresh' => Icons.refresh_rounded,
      'music' => Icons.music_note_rounded,
      'image' => Icons.image_outlined,
      _ => Icons.extension_rounded,
    };
