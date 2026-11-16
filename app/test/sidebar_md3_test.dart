// Sidebar (RikkaHub layout, desktop panel and watch) under the MD3 rules: no overflow,
// 48dp footer targets (no FittedBox shrinking), named controls.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/core/storage.dart';
import 'package:rofuchat/core/theme.dart';
import 'package:rofuchat/features/sidebar/sidebar.dart';
import 'package:rofuchat/models/models.dart';
import 'package:rofuchat/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Chars extends CharactersCtl {
  @override
  Future<List<Character>> build() async => [
        Character({'id': 'c1', 'name': 'Alice with a fairly long character name', 'card': {}}),
        Character({'id': 'c2', 'name': '小雪', 'card': {}}),
      ];
}

void main() {
  for (final size in const [Size(192, 192), Size(400, 480), Size(360, 800), Size(1280, 800)]) {
    testWidgets('sidebar at ${size.width}x${size.height}: no overflow, footer targets >= 48dp', (t) async {
      t.view.physicalSize = size;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      SharedPreferences.setMockInitialValues({});
      final store = await LocalStore.open();
      final now = DateTime.now().millisecondsSinceEpoch;
      await t.pumpWidget(ProviderScope(
        overrides: [
          storeProvider.overrideWithValue(store),
          charactersProvider.overrideWith(_Chars.new),
          conversationsProvider.overrideWith((ref, id) async => [
                for (var i = 0; i < 6; i++) Conversation({'id': 'v$i', 'character_id': id, 'title': 'Chat $i about something', 'updated_at': now - i * 86400000, 'generating': i == 0}),
              ]),
        ],
        child: MaterialApp(
          theme: buildTheme(const Appearance(), Brightness.dark),
          home: Scaffold(body: Sidebar(onNewConversation: (_) {})),
        ),
      ));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      expect(t.takeException(), isNull);
      expect(find.byType(FittedBox), findsNothing);
      expect(find.text('Chat 0 about something', skipOffstage: false), findsOneWidget, reason: 'conversations rendered');
      final buttons = find.byType(IconButton);
      for (var i = 0; i < buttons.evaluate().length; i++) {
        final s = t.getSize(buttons.at(i));
        expect(s.shortestSide, greaterThanOrEqualTo(48), reason: 'icon button $i');
        expect(t.widget<IconButton>(buttons.at(i)).tooltip, isNotNull, reason: 'icon button $i is named');
      }
    });
  }
}
