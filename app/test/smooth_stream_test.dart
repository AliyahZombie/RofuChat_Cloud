import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/core/api.dart';
import 'package:rofuchat/features/chat/chat_controller.dart';

class _FakeApi extends Api {
  final StreamController<Map<String, dynamic>> events = StreamController();
  _FakeApi() : super('http://fake');
  @override
  Stream<Map<String, dynamic>> sse(String path, Object body) => events.stream;
  @override
  Future<dynamic> get(String path, {Map<String, String>? query}) async => <String, dynamic>{};
}

void main() {
  test('deltas are revealed gradually and events keep their order', () async {
    final api = _FakeApi();
    final ctl = ChatController(api, 'c');
    final lengths = <int>[];
    ctl.addListener(() {
      final id = ctl.streamingId;
      final m = id == null ? null : ctl.byId(id);
      if (m != null) lengths.add(m.segments.isEmpty ? 0 : m.segments.last.text.length);
    });
    final done = ctl.send(content: 'hi');
    final msg = {'id': 'a1', 'seq': 2, 'role': 'assistant', 'content': '', 'parts': {'segments': []}};
    api.events.add({'type': 'assistant_start', 'message': msg});
    final text = 'x' * 400;
    api.events.add({'type': 'text', 'delta': text}); // one big burst
    api.events.add({'type': 'assistant_done', 'message': {...msg, 'content': text, 'parts': {'segments': [{'type': 'text', 'text': text}]}}});
    api.events.add({'type': 'done'});
    await api.events.close();
    await done;
    // the burst was painted over several frames, growing monotonically
    final grow = lengths.where((l) => l > 0 && l < 400).toList();
    expect(grow.length, greaterThan(3));
    for (var i = 1; i < grow.length; i++) {
      expect(grow[i], greaterThanOrEqualTo(grow[i - 1]));
    }
    expect(ctl.generating, false);
    expect(ctl.byId('a1')!.content, text);
    expect(ctl.justFinishedId, 'a1');
    ctl.dispose();
  });
}
