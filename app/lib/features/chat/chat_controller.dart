import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/api.dart';
import '../../models/models.dart';

/// Holds one conversation's messages and drives the SSE chat stream
/// (docs/backend-spec.md §6.9, docs/frontend-spec.md §9).
class ChatController extends ChangeNotifier {
  final Api api;
  final String conversationId;
  ChatController(this.api, this.conversationId);

  List<Message> messages = [];
  bool loading = true;
  bool generating = false;
  bool compressing = false;
  String? loadError;
  ContextInfo context = const ContextInfo();

  /// Non-fatal notices per assistant message id (shown as grey lines).
  final Map<String, List<String>> notices = {};

  /// Message ids whose `actual` is being generated.
  final Set<String> actualPending = {};

  /// Id of the assistant message currently streaming.
  String? streamingId;

  /// Bumped on every streaming delta; widgets use it to throttle markdown re-parsing.
  int rev = 0;

  StreamSubscription<Json>? _sub;
  Timer? _poll;
  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    _notify();
    try {
      final conv = Map<String, dynamic>.from(await api.get('/api/conversations/$conversationId') as Map);
      messages = await api.list('/api/conversations/$conversationId/messages', Message.new);
      loadError = null;
      if (conv['generating'] == true && _sub == null) {
        generating = true;
        _startPolling();
      }
      unawaited(refreshContext());
    } catch (e) {
      loadError = '$e';
    }
    loading = false;
    _notify();
  }

  Future<void> refreshContext() async {
    try {
      context = ContextInfo.fromJson(Map<String, dynamic>.from(await api.get('/api/conversations/$conversationId/context') as Map));
      _notify();
    } catch (_) {}
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(milliseconds: 1500), (_) async {
      try {
        final conv = Map<String, dynamic>.from(await api.get('/api/conversations/$conversationId') as Map);
        messages = await api.list('/api/conversations/$conversationId/messages', Message.new);
        rev++;
        if (conv['generating'] != true) {
          _poll?.cancel();
          _poll = null;
          generating = false;
          streamingId = null;
          unawaited(refreshContext());
        }
        _notify();
      } catch (_) {}
    });
  }

  Message? byId(String id) => messages.where((m) => m.id == id).firstOrNull;

  void _upsert(Message m) {
    final i = messages.indexWhere((x) => x.id == m.id);
    if (i >= 0) {
      messages[i] = m;
    } else {
      messages.add(m);
      messages.sort((a, b) => a.seq.compareTo(b.seq));
    }
  }

  Message? get _streaming => streamingId == null ? null : byId(streamingId!);

  List<dynamic> _segments(Message m) {
    final parts = m.parts;
    final segs = parts['segments'];
    if (segs is List) return segs;
    final l = <dynamic>[];
    parts['segments'] = l;
    return l;
  }

  void _appendSeg(String type, String delta) {
    final m = _streaming;
    if (m == null) return;
    final segs = _segments(m);
    if (segs.isNotEmpty && (segs.last as Map)['type'] == type) {
      final last = segs.last as Map;
      last['text'] = '${last['text'] ?? ''}$delta';
    } else {
      segs.add(<String, dynamic>{'type': type, 'text': delta});
    }
  }

  Future<void> send({String content = '', List<String> images = const [], bool regenerate = false, String? editMessageId}) async {
    if (generating) return;
    generating = true;
    String? tempId;
    if (!regenerate && editMessageId == null) {
      tempId = 'local-${DateTime.now().microsecondsSinceEpoch}';
      messages.add(Message({
        'id': tempId,
        'conversation_id': conversationId,
        'seq': (messages.isEmpty ? 0 : messages.last.seq) + 1,
        'role': 'user',
        'content': content,
        'visible': true,
        'parts': {'images': images, 'segments': <dynamic>[]},
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }));
    } else if (editMessageId != null) {
      final m = byId(editMessageId);
      if (m != null) {
        m.content = content;
        messages.removeWhere((x) => x.seq > m.seq);
      }
    } else {
      final lastUser = messages.lastIndexWhere((m) => m.isUser);
      if (lastUser >= 0) messages.removeRange(lastUser + 1, messages.length);
    }
    _notify();
    final body = {'content': content, 'images': images, 'regenerate': regenerate, 'edit_message_id': editMessageId};
    final completer = Completer<void>();
    _sub = api.sse('/api/conversations/$conversationId/chat', body).listen(
      (ev) => _handle(ev, tempId),
      onError: (Object e) {
        if (tempId != null && e is ApiException && e.status != 200) messages.removeWhere((m) => m.id == tempId);
        _sub = null;
        if (streamingId != null) {
          // Lost the stream mid-generation: fall back to polling.
          _startPolling();
        } else {
          generating = false;
          loadError = '$e';
        }
        _notify();
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        _sub = null;
        if (_poll == null) {
          generating = false;
          streamingId = null;
        }
        _notify();
        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );
    return completer.future;
  }

  int _lastNotify = 0;
  void _throttledNotify() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastNotify > 40) {
      _lastNotify = now;
      _notify();
    } else {
      Future.delayed(const Duration(milliseconds: 45), () {
        if (DateTime.now().millisecondsSinceEpoch - _lastNotify >= 40) {
          _lastNotify = DateTime.now().millisecondsSinceEpoch;
          _notify();
        }
      });
    }
  }

  void _handle(Json ev, String? tempId) {
    Message msg() => Message(Map<String, dynamic>.from(ev['message'] as Map));
    switch (ev['type']) {
      case 'user_message':
        if (tempId != null) messages.removeWhere((m) => m.id == tempId);
        _upsert(msg());
      case 'assistant_start':
        final m = msg();
        streamingId = m.id;
        _upsert(m);
      case 'text':
        _appendSeg('text', ev['delta'] as String? ?? '');
        rev++;
        _throttledNotify();
        return;
      case 'reasoning':
        _appendSeg('reasoning', ev['delta'] as String? ?? '');
        rev++;
        _throttledNotify();
        return;
      case 'reasoning_end':
        final m = _streaming;
        if (m != null) {
          final segs = _segments(m);
          for (final s in segs.reversed) {
            if ((s as Map)['type'] == 'reasoning') {
              s['duration_ms'] = ev['duration_ms'];
              break;
            }
          }
        }
      case 'tool_start':
        final m = _streaming;
        if (m != null) {
          _segments(m).add(<String, dynamic>{'type': 'tool', 'id': ev['id'], 'name': ev['name'], 'arguments': ev['arguments'] ?? '', 'result': null});
        }
      case 'tool_end':
        final m = _streaming;
        if (m != null) {
          for (final s in _segments(m)) {
            if ((s as Map)['type'] == 'tool' && s['id'] == ev['id']) {
              s['result'] = ev['result'];
              s['is_error'] = ev['is_error'] ?? false;
              s['duration_ms'] = ev['duration_ms'] ?? 0;
            }
          }
        }
      case 'notice':
        final id = streamingId ?? (messages.isNotEmpty ? messages.last.id : '');
        notices.putIfAbsent(id, () => []).add(ev['message'] as String? ?? '');
      case 'assistant_done':
        final m = msg();
        _upsert(m);
        streamingId = null;
      case 'actual_pending':
        actualPending.add(ev['id'] as String? ?? '');
      case 'actual':
        final m = msg();
        actualPending.remove(m.id);
        _upsert(m);
      case 'compressing':
        compressing = true;
      case 'summary':
        compressing = false;
        final hidden = ((ev['hidden_ids'] as List?) ?? const []).map((e) => e.toString()).toSet();
        for (final m in messages) {
          if (hidden.contains(m.id)) m.visible = false;
        }
        _upsert(msg());
      case 'context':
        context = ContextInfo(
          tokens: (ev['tokens'] as num?)?.toInt() ?? context.tokens,
          max: (ev['max'] as num?)?.toInt() ?? context.max,
          estimated: context.estimated,
          mode: context.mode,
          threshold: context.threshold,
        );
      case 'error':
        loadError = null;
        final m = _streaming;
        if (m != null) {
          m.parts['error'] = ev['error'];
        } else {
          final id = messages.isNotEmpty ? messages.last.id : '';
          notices.putIfAbsent(id, () => []).add(ev['error'] as String? ?? 'error');
        }
      case 'done':
        generating = false;
        compressing = false;
        streamingId = null;
        unawaited(refreshContext());
    }
    rev++;
    _notify();
  }

  Future<void> stop() async {
    try {
      await api.post('/api/conversations/$conversationId/stop');
    } catch (_) {}
  }

  Future<void> deleteMessage(Message m) async {
    await api.delete('/api/messages/${m.id}');
    messages.removeWhere((x) => x.id == m.id);
    _notify();
    unawaited(refreshContext());
  }

  Future<void> setVisible(Message m, bool v) async {
    final j = await api.patch('/api/messages/${m.id}', {'visible': v});
    _upsert(j is Map ? Message(Map<String, dynamic>.from(j)) : (m..visible = v));
    _notify();
    unawaited(refreshContext());
  }

  Future<void> editContent(Message m, String content) async {
    final j = await api.patch('/api/messages/${m.id}', {'content': content});
    _upsert(j is Map ? Message(Map<String, dynamic>.from(j)) : (m..content = content));
    rev++;
    _notify();
  }

  Future<void> editActual(Message m, String actual) async {
    final j = await api.patch('/api/messages/${m.id}', {'actual': actual});
    if (j is Map) _upsert(Message(Map<String, dynamic>.from(j)));
    _notify();
  }

  Future<void> retryActual(Message m) async {
    actualPending.add(m.id);
    _notify();
    try {
      final j = await api.post('/api/messages/${m.id}/actual');
      if (j is Map) _upsert(Message(Map<String, dynamic>.from(j)));
    } finally {
      actualPending.remove(m.id);
      _notify();
    }
  }

  Future<String?> branch(Message m) async {
    final j = await api.post('/api/messages/${m.id}/branch');
    return j is Map ? j['id'] as String? : null;
  }

  Future<void> compressNow() async {
    compressing = true;
    _notify();
    try {
      await api.post('/api/conversations/$conversationId/compress');
      messages = await api.list('/api/conversations/$conversationId/messages', Message.new);
      rev++;
    } finally {
      compressing = false;
      _notify();
      unawaited(refreshContext());
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _poll?.cancel();
    super.dispose();
  }
}
