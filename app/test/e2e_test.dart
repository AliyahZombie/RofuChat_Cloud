// End-to-end contract check against a running rofu-server.
// Run: ROFU_E2E_URL=http://127.0.0.1:7860 ROFU_E2E_ROOT=<root password> ROFU_E2E_LLM=http://127.0.0.1:<mock>/v1 flutter test test/e2e_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/core/api.dart';
import 'package:rofuchat/core/builtin_tools.dart';
import 'package:rofuchat/features/chat/chat_controller.dart';
import 'package:rofuchat/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // for rootBundle (dice.js asset)
  setUpAll(() => HttpOverrides.global = null); // real network to the server under test
  final url = Platform.environment['ROFU_E2E_URL'];
  final root = Platform.environment['ROFU_E2E_ROOT'] ?? '';
  final llm = Platform.environment['ROFU_E2E_LLM'] ?? '';
  final skip = url == null ? 'set ROFU_E2E_URL to run' : null;

  test('frontend calls match the backend contract', () async {
    final api = Api(url!);
    final h = await api.health();
    expect(h['name'], 'RofuChat');
    final (token, user) = await api.login('root', root);
    api.token = token;
    expect(user.isRoot, true);
    final me = User(Map<String, dynamic>.from(await api.get('/api/auth/me') as Map));
    expect(me.username, 'root');

    final p = ProviderCfg.blank()
      ..json['name'] = 'mock'
      ..json['base_url'] = llm
      ..json['api_key'] = 'sk-test';
    final prov = ProviderCfg(Map<String, dynamic>.from(await api.post('/api/providers', p.toJson()) as Map));
    expect(prov.id, isNotEmpty);
    final remote = await api.post('/api/providers/${prov.id}/remote_models');
    expect(remote, isNotNull);

    final det = await api.post('/api/models/detect', {'model_id': 'deepseek-r1', 'provider_id': prov.id});
    final mj = Map<String, dynamic>.from(det as Map)
      ..['provider_id'] = prov.id
      ..['model_id'] = 'gpt-4o';
    final created = await api.post('/api/models', [mj]);
    final models = await api.list('/api/models', ModelCfg.new);
    expect(models, isNotEmpty, reason: 'create returned $created');
    final model = models.first;

    final c = Character.blank()
      ..name = 'Rofu'
      ..modelId = model.id
      ..setCard('first_mes', 'Hi {{user}}');
    final ch = Character(Map<String, dynamic>.from(await api.post('/api/characters', c.toJson()) as Map));
    expect(ch.id, isNotEmpty);

    final conv = Conversation(Map<String, dynamic>.from(
        await api.post('/api/conversations', ch.newConversationBody(0)) as Map));
    final convs = await api.list('/api/conversations', Conversation.new, query: {'character_id': ch.id});
    expect(convs.map((e) => e.id), contains(conv.id));

    final ctl = ChatController(api, conv.id);
    await ctl.load();
    expect(ctl.messages.first.content, contains('Hi'));
    await ctl.send(content: 'hello');
    for (var i = 0; i < 100 && ctl.generating; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect(ctl.loadError, isNull);
    expect(ctl.messages.last.error, isNull, reason: ctl.messages.last.json.toString());
    final last = ctl.messages.last;
    expect(last.role, 'assistant');
    expect(last.content, contains('world'));
    expect(last.segments.any((s) => s.type == 'reasoning'), true, reason: last.json.toString());

    // reload from server: same view
    final ctl2 = ChatController(api, conv.id);
    await ctl2.load();
    expect(ctl2.messages.last.content, last.content);
    await ctl2.refreshContext();
    expect(ctl2.context.tokens, greaterThan(0));
    expect(ctl2.context.max, greaterThan(0));

    for (final path in ['/api/tools', '/api/memories', '/api/admin/users']) {
      expect(await api.get(path), isA<List>(), reason: path);
    }
    expect(await api.get('/api/settings'), isA<Map>());
    expect(await api.get('/api/admin/config'), isA<Map>());
    final tool = await api.post('/api/tools', {'name': 'add', 'description': 'add', 'parameters': {'type': 'object'}, 'code': 'function main(args) { return args.a + args.b; }'});
    final run = await api.post('/api/tools/run', {'code': 'function main(args) { return args.a + args.b; }', 'args': {'a': 1, 'b': 2}});
    expect(run.toString(), contains('3'), reason: 'tool $tool');

    // built-in dice tool runs in the backend's QuickJS
    final dice = await builtinTools.first.toToolJson();
    for (final e in ['1d20+5 attack', '4d6kh3, 2d20kl1', '1d20+3 adv', '10d6>=5', '3#1d8+2', 'd%', '4dF', '2d6!!', '2d10ro<2']) {
      final r = Map<String, dynamic>.from(await api.post('/api/tools/run', {'code': dice['code'], 'args': {'expression': e}}) as Map);
      expect(r['is_error'], false, reason: '$e: ${r['result']}');
      expect(r['result'], contains('**'), reason: e);
    }
    final bad = Map<String, dynamic>.from(await api.post('/api/tools/run', {'code': dice['code'], 'args': {'expression': '1d0'}}) as Map);
    expect(bad['is_error'], true);
  }, skip: skip, timeout: const Timeout(Duration(seconds: 60)));
}
