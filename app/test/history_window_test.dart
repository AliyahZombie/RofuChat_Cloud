import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/core/api.dart';
import 'package:rofuchat/features/chat/chat_controller.dart';

/// A server with [n] messages (seq 1..n) answering paged requests 100 at a time.
class _PagedApi extends Api {
  final int n;
  int pageCalls = 0;
  _PagedApi(this.n) : super('http://fake');

  Map<String, dynamic> _msg(int seq) => {
        'id': 'm$seq',
        'seq': seq,
        'role': seq.isOdd ? 'user' : 'assistant',
        'content': 'message $seq',
        'visible': true,
        'parts': {'segments': [], 'images': []},
      };

  @override
  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    if (!path.endsWith('/messages')) return <String, dynamic>{'id': 'c', 'generating': false};
    if (query?['max_chars'] == null) return <String, dynamic>{};
    pageCalls++;
    final before = int.tryParse(query?['before_seq'] ?? '') ?? n + 1;
    final from = (before - 100).clamp(1, n + 1);
    final list = [for (var s = from; s < before; s++) _msg(s)];
    return {'messages': list, 'has_more': from > 1, 'chars': list.length * 10, 'bytes': list.length * 100};
  }
}

void main() {
  test('background loading fills the window, then freezes the rest', () async {
    final api = _PagedApi(1000);
    final ctl = ChatController(api, 'c', windowMessages: 300);
    await ctl.load();
    while (ctl.hasMore || ctl.loadingOlder) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(ctl.loadedCount, 1000);
    expect(ctl.messages.length, 300);
    expect(ctl.messages.last.seq, 1000);
    expect(ctl.coldCount, 700);
    expect(ctl.canLoadOlder, isTrue);
    ctl.dispose();
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('scrolling up thaws the cache; back at the bottom it trims again', () async {
    final api = _PagedApi(1000);
    final ctl = ChatController(api, 'c', windowMessages: 300);
    await ctl.load();
    while (ctl.hasMore || ctl.loadingOlder) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    final calls = api.pageCalls;
    await ctl.loadOlder();
    expect(ctl.messages.length, 300 + kThawChunk);
    expect(ctl.messages.first.seq, 1000 - 300 - kThawChunk + 1);
    expect(api.pageCalls, calls, reason: 'thawing needs no request');
    final evicted = <String>[];
    ctl.onEvict = evicted.addAll;
    ctl.trimToWindow();
    expect(ctl.messages.length, 300);
    expect(evicted.length, kThawChunk);
    expect(ctl.loadedCount, 1000);
    ctl.dispose();
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('reveal brings a far message into the live window', () async {
    final api = _PagedApi(1000);
    final ctl = ChatController(api, 'c', windowMessages: 300, autoLoad: false);
    await ctl.load();
    expect(ctl.messages.length, 100);
    final id = await ctl.reveal(42);
    expect(id, 'm42');
    expect(ctl.messages.first.seq, lessThanOrEqualTo(42));
    expect(await ctl.reveal(5000), isNull);
    ctl.dispose();
  });
}
