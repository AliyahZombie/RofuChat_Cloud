import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_single_block_renderer/md_single_block_renderer.dart';
import 'package:rofuchat/core/form_factor.dart';
import 'package:rofuchat/features/chat/message_rows.dart';
import 'package:rofuchat/models/models.dart';
import 'package:rofuchat/widgets/common.dart';

List<Message> sampleMessages() => [
      Message({
        'id': 'u1', 'seq': 1000, 'role': 'user', 'content': 'lonely Halloween 歌词', 'visible': true,
        'parts': {'segments': [], 'images': []},
      }),
      Message({
        'id': 'a1', 'seq': 2000, 'role': 'assistant', 'content': '…', 'visible': true, 'model_name': 'gemini-3.8-flash', 'model_icon': 'gemini',
        'actual_status': 'failed', 'actual_error': 'fast model returned 500',
        'usage': {'input': 1234, 'output': 456, 'cached': 800, 'duration_ms': 5300, 'ttft_ms': 400},
        'parts': {
          'segments': [
            {'type': 'reasoning', 'text': 'thinking about lyrics', 'duration_ms': 400},
            {'type': 'text', 'text': '我将使用网络搜索工具查询歌曲《Lonely Halloween》的歌词内容。'},
            {'type': 'tool', 'id': 'c1', 'name': 'search__scrape', 'arguments': '{"url":"https://genius.com/Caroline-konstnar-lonely-halloween-song-lyrics"}', 'result': 'lyrics…', 'duration_ms': 4700},
            {'type': 'reasoning', 'text': 'ok', 'duration_ms': 300},
            {'type': 'tool', 'id': 'c2', 'name': 'memory_add', 'arguments': '{"content":"likes halloween"}', 'result': 'Saved', 'duration_ms': 12},
            {'type': 'text', 'text': '# 《Lonely Halloween Song》\n\n**演唱 / 词曲：** Caroline Konstnar\n\n> Wish I had a friend with me\n\n```js\nconsole.log("boo")\n```\n\n| a | b |\n|---|---|\n| 1 | 2 |\n\n- one\n- two\n\n' * 3},
          ],
        },
      }),
      Message({'id': 's1', 'seq': 2999, 'role': 'summary', 'content': '摘要：用户询问了歌词。' * 10, 'visible': true, 'parts': {}}),
      Message({'id': 'u2', 'seq': 3000, 'role': 'user', 'content': '谢谢' * 40, 'visible': false, 'parts': {'images': []}}),
    ];

Widget harness(List<ChatRow> rows) => MaterialApp(
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: Builder(builder: (context) {
        final watch = context.isWatch;
        return Scaffold(
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: watch ? watchInset(context) : 12),
            children: [
              for (final r in rows)
                switch (r) {
                  UserRow() => UserBubble(msg: r.msg, userName: 'Aliyah', showName: !watch, compact: watch, onCopy: () {}, onEdit: () {}, onMore: (_) {}),
                  AssistantHeaderRow() => Row(children: [ModelIcon(iconKey: r.msg.modelIcon, name: r.msg.modelName), Flexible(child: Text(r.msg.modelName))]),
                  StepsRow() => StepsCard(steps: r.steps, live: r.live, compact: watch),
                  BlockRow() => MarkdownSingleBlockRenderer(r.block),
                  SummaryRow() => SummaryCard(msg: r.msg, onEdit: () {}),
                  FooterRow() => Wrap(children: [
                      if (r.msg.usage != null) TokenIndicator(usage: r.msg.usage!),
                      ActualStatusIcon(msg: r.msg, pending: false, onTapFailed: () {}),
                    ]),
                  TypingRow() => const SizedBox(height: 8),
                },
              const ContextRing(info: ContextInfo(tokens: 12000, max: 128000, threshold: 96000)),
            ],
          ),
        );
      }),
    );

void main() {
  test('buildRows flattens messages into rows', () {
    final rows = buildRows(sampleMessages(), BlockCache());
    expect(rows.whereType<UserRow>().length, 2);
    expect(rows.whereType<StepsRow>().length, 2); // reasoning alone, then tool+reasoning+tool
    expect(rows.whereType<BlockRow>().length, greaterThan(5));
    expect(rows.whereType<SummaryRow>().length, 1);
    expect(rows.whereType<FooterRow>().single.isLastAssistant, isTrue);
  });

  test('streaming assistant has no footer and a typing row when empty', () {
    final m = Message({'id': 'a', 'seq': 1, 'role': 'assistant', 'content': '', 'parts': {'segments': []}});
    final rows = buildRows([m], BlockCache(), streamingId: 'a');
    expect(rows.whereType<FooterRow>(), isEmpty);
    expect(rows.whereType<TypingRow>().length, 1);
  });

  for (final size in const [Size(360, 800), Size(1280, 800), Size(192, 192), Size(384, 384), Size(454, 454)]) {
    testWidgets('chat renders without overflow at ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final rows = buildRows(sampleMessages(), BlockCache());
      await tester.pumpWidget(harness(rows));
      await tester.pumpAndSettle();
      // Scroll through the whole list to build every row.
      for (var i = 0; i < 30; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
    });
  }
}
