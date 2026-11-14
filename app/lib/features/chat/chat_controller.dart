import 'dart:async';
import 'dart:collection';
import 'dart:math';

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

  /// The assistant message that finished most recently in this session (its footer fades in).
  String? justFinishedId;

  /// Bumped on every streaming delta; widgets use it to throttle markdown re-parsing.
  int rev = 0;

  StreamSubscription<Json>? _sub;
  Timer? _poll;
  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Messages are fetched newest-first in pages of this size (docs/api.md, messages pagination).
  static const pageSize = 40;

  /// Older messages exist on the server that are not loaded yet.
  bool hasMore = false;
  bool loadingOlder = false;

  /// Fetches one page: the last [limit] messages with seq < [beforeSeq]. Falls back to the
  /// whole list on servers without pagination (they answer with a plain array).
  Future<(List<Message>, bool)> _page({int limit = pageSize, int? beforeSeq}) async {
    final j = await api.get('/api/conversations/$conversationId/messages', query: {
      'limit': '$limit',
      if (beforeSeq != null) 'before_seq': '$beforeSeq',
    });
    if (j is List) return (j.map((e) => Message(Map<String, dynamic>.from(e as Map))).toList(), false);
    final m = Map<String, dynamic>.from(j as Map);
    final list = ((m['messages'] as List?) ?? const []).map((e) => Message(Map<String, dynamic>.from(e as Map))).toList();
    return (list, m['has_more'] == true);
  }

  Future<void> loadOlder() async {
    if (!hasMore || loadingOlder || messages.isEmpty) return;
    loadingOlder = true;
    _notify();
    try {
      final (older, more) = await _page(beforeSeq: messages.first.seq);
      final have = messages.map((m) => m.id).toSet();
      messages.insertAll(0, older.where((m) => !have.contains(m.id)));
      hasMore = more && older.isNotEmpty;
    } catch (_) {}
    loadingOlder = false;
    _notify();
  }

  /// Merges the newest page into the loaded list (used while polling a generation).
  void _mergeTail(List<Message> page) {
    if (page.isEmpty) return;
    final from = page.first.seq;
    messages.removeWhere((m) => m.seq >= from);
    messages.addAll(page);
    messages.sort((a, b) => a.seq.compareTo(b.seq));
  }

  Future<void> load() async {
    loading = true;
    _notify();
    try {
      final conv = Map<String, dynamic>.from(await api.get('/api/conversations/$conversationId') as Map);
      final (page, more) = await _page();
      messages = page;
      hasMore = more;
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
        final (page, _) = await _page(limit: 20);
        _mergeTail(page);
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
      // The reply right after the last user message stays: the server adds a new swipe to it
      // and assistant_start replaces it in place. Anything after it goes.
      final lastUser = messages.lastIndexWhere((m) => m.isUser);
      if (lastUser >= 0) {
        final keep = lastUser + 1 < messages.length && messages[lastUser + 1].isAssistant ? lastUser + 2 : lastUser + 1;
        messages.removeRange(keep, messages.length);
      }
    }
    _notify();
    final body = {'content': content, 'images': images, 'regenerate': regenerate, 'edit_message_id': editMessageId};
    final completer = Completer<void>();
    _sub = api.sse('/api/conversations/$conversationId/chat', body).listen(
      (ev) {
        final type = ev['type'];
        if (type == 'text' || type == 'reasoning') {
          _push(_Delta(type as String, ev['delta'] as String? ?? ''));
        } else {
          _push(() => _handle(ev, tempId));
        }
      },
      onError: (Object e) => _push(() {
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
      }),
      onDone: () => _push(() {
        _sub = null;
        if (_poll == null) {
          generating = false;
          streamingId = null;
        }
        _notify();
        if (!completer.isCompleted) completer.complete();
      }),
      cancelOnError: true,
    );
    return completer.future;
  }

  // ------------------------------------------------------------ smooth streaming
  //
  // Network deltas arrive in bursts. Instead of painting each burst as it lands, text is
  // queued and revealed a few characters per frame (~30 fps), fast enough that any backlog
  // drains within ~0.25 s. Other events wait in the same queue so ordering is preserved.

  final _pending = ListQueue<Object>();
  Timer? _ticker;

  void _push(Object item) {
    _pending.add(item);
    _ticker ??= Timer.periodic(const Duration(milliseconds: 33), (_) => _tick());
  }

  void _tick() {
    if (_disposed) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    var backlog = 0;
    for (final p in _pending) {
      if (p is _Delta) backlog += p.text.length;
    }
    var budget = max(1, (backlog / 8).ceil());
    var changed = false;
    while (_pending.isNotEmpty) {
      final head = _pending.first;
      if (head is _Delta) {
        if (budget <= 0) break;
        var take = min(budget, head.text.length);
        // never split a surrogate pair (emoji)
        if (take < head.text.length && take > 0) {
          final cu = head.text.codeUnitAt(take - 1);
          if (cu >= 0xD800 && cu <= 0xDBFF) take++;
        }
        _appendSeg(head.type, head.text.substring(0, take));
        head.text = head.text.substring(take);
        budget -= take;
        changed = true;
        if (head.text.isEmpty) _pending.removeFirst();
      } else {
        _pending.removeFirst();
        (head as void Function())();
        changed = true;
      }
    }
    if (_pending.isEmpty) {
      _ticker?.cancel();
      _ticker = null;
    }
    if (changed) {
      rev++;
      _notify();
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
      case 'reasoning':
        _appendSeg('reasoning', ev['delta'] as String? ?? '');
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
        justFinishedId = m.id;
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

  /// Applies a swipe response `{messages:[target, ...restored tail]}`.
  void _applySwipe(Message target, dynamic j) {
    final list = ((j is Map ? j['messages'] : j) as List? ?? const []).map((e) => Message(Map<String, dynamic>.from(e as Map))).toList();
    if (list.isEmpty) return;
    final head = list.first;
    if (head.isUser) messages.removeWhere((m) => m.seq > head.seq);
    for (final m in list) {
      _upsert(m);
    }
    rev++;
    _notify();
    unawaited(refreshContext());
  }

  Future<void> swipe(Message m, int index) async {
    if (generating || index < 0 || index >= m.swipeCount || index == m.swipeIndex) return;
    _applySwipe(m, await api.post('/api/messages/${m.id}/swipe', {'index': index}));
  }

  Future<void> deleteSwipe(Message m) async {
    if (generating || m.swipeCount < 2) return;
    _applySwipe(m, await api.delete('/api/messages/${m.id}/swipes/${m.swipeIndex}'));
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
    _ticker?.cancel();
    _sub?.cancel();
    _poll?.cancel();
    super.dispose();
  }
}

class _Delta {
  final String type;
  String text;
  _Delta(this.type, this.text);
}
