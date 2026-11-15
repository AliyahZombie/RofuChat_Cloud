import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/core/api.dart';
import 'package:rofuchat/core/storage.dart';
import 'package:rofuchat/core/theme.dart';
import 'package:rofuchat/features/sidebar/sidebar.dart';
import 'package:rofuchat/state/app_state.dart';
import 'package:rofuchat/widgets/slide_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MenuApi extends Api {
  final List<Map<String, Object>> chars = [
    {'id': 'c1', 'name': 'Alice', 'card': <String, Object>{}},
    {'id': 'c2', 'name': 'Bob', 'card': <String, Object>{}},
  ];
  _MenuApi() : super('http://example.test');
  @override
  Future<dynamic> get(String path, {Map<String, String>? query}) async =>
      path == '/api/characters'
      ? chars
      : [
          {'id': 'conv', 'character_id': 'c1', 'title': 'Test conversation'},
        ];
  @override
  Future<dynamic> delete(String path) async {
    chars.removeWhere((c) => c['id'] == path.split('/').last);
    return null;
  }
}

void main() {
  for (final size in [const Size(360, 800), const Size(240, 240)]) {
    for (final scale in [1.0, 2.0]) {
      for (final picker in [false, true]) {
        testWidgets('Delete character, picker=$picker, $size, text=$scale', (
          t,
        ) async {
          t.view.physicalSize = size;
          t.view.devicePixelRatio = 1;
          t.view.padding = const FakeViewPadding(bottom: 24);
          addTearDown(t.view.reset);
          SharedPreferences.setMockInitialValues({});
          final store = await LocalStore.open();
          final drawer = GlobalKey<SlideDrawerState>();
          final api = _MenuApi();
          await t.pumpWidget(
            ProviderScope(
              overrides: [
                storeProvider.overrideWithValue(store),
                apiProvider.overrideWithValue(api),
                conversationsProvider.overrideWith((ref, id) async => []),
              ],
              child: MaterialApp(
                theme: buildTheme(const Appearance(), Brightness.light),
                builder: (c, child) => MediaQuery(
                  data: MediaQuery.of(c)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: SlideDrawer(
                  key: drawer,
                  width: size.width - 40,
                  drawer: Sidebar(onNewConversation: (_) {}),
                  child: const Scaffold(body: Text('Chat')),
                ),
              ),
            ),
          );
          drawer.currentState!.open();
          await t.pumpAndSettle();
          final container = ProviderScope.containerOf(
            t.element(find.byType(Sidebar)),
          );
          container.read(selectedCharacterIdProvider.notifier).select('c1');
          container
              .read(selectedConversationIdProvider.notifier)
              .select('old-chat');
          await t.pumpAndSettle();
          if (picker) {
            await t.tap(find.text('Alice').last);
            await t.pumpAndSettle();
          }
          await t.longPress(find.text('Alice').last);
          await t.pumpAndSettle();
          expect(find.byType(BottomSheet), findsOneWidget);
          expect(
            FocusManager.instance.primaryFocus?.debugLabel,
            isNot('SlideDrawer'),
            reason: 'cancelled drawer drag must not steal sheet focus',
          );
          if (size.width == 360) {
            expect(
              find.text('Delete').hitTestable(),
              findsOneWidget,
              reason: 'all five actions fit on the phone, also at 2x',
            );
          }
          final sheetScroll = find.descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          );
          await t.scrollUntilVisible(
            find.text('Delete'),
            50,
            scrollable: sheetScroll,
          );
          await t.ensureVisible(find.text('Delete'));
          await t.pumpAndSettle();
          expect(find.text('Delete').hitTestable(), findsOneWidget);
          await t.tap(find.text('Delete'));
          await t.pumpAndSettle();
          expect(find.byType(Dialog), findsOneWidget);
          await t.scrollUntilVisible(
            find.widgetWithText(TextButton, 'Delete'),
            50,
            scrollable: find
                .descendant(
                  of: find.byType(Dialog),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await t.ensureVisible(find.widgetWithText(TextButton, 'Delete'));
          await t.pumpAndSettle();
          expect(
            find.widgetWithText(TextButton, 'Delete').hitTestable(),
            findsOneWidget,
          );
          await t.tap(find.widgetWithText(TextButton, 'Delete'));
          await t.pumpAndSettle();
          expect(container.read(currentCharacterProvider)?.id, 'c2');
          expect(container.read(selectedCharacterIdProvider), 'c2');
          expect(container.read(selectedConversationIdProvider), isNull);
          await t.longPress(find.text('Bob').last);
          await t.pumpAndSettle();
          await t.scrollUntilVisible(
            find.text('Delete'),
            50,
            scrollable: find.descendant(
              of: find.byType(BottomSheet),
              matching: find.byType(Scrollable),
            ),
          );
          await t.ensureVisible(find.text('Delete'));
          await t.pumpAndSettle();
          expect(find.text('Delete').hitTestable(), findsOneWidget);
          await t.tap(find.text('Delete'));
          await t.pumpAndSettle();
          await t.scrollUntilVisible(
            find.widgetWithText(TextButton, 'Delete'),
            50,
            scrollable: find
                .descendant(
                  of: find.byType(Dialog),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await t.ensureVisible(find.widgetWithText(TextButton, 'Delete'));
          await t.pumpAndSettle();
          await t.tap(find.widgetWithText(TextButton, 'Delete'));
          await t.pumpAndSettle();
          expect(container.read(currentCharacterProvider), isNull);
          expect(container.read(selectedCharacterIdProvider), isNull);
          expect(t.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('conversation long press through drawer opens its confirmation', (
    t,
  ) async {
    t.view.physicalSize = const Size(360, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    SharedPreferences.setMockInitialValues({});
    final store = await LocalStore.open();
    final api = _MenuApi();
    final drawer = GlobalKey<SlideDrawerState>();
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          storeProvider.overrideWithValue(store),
          apiProvider.overrideWithValue(api),
        ],
        child: MaterialApp(
          home: SlideDrawer(
            key: drawer,
            width: 320,
            drawer: Sidebar(onNewConversation: (_) {}),
            child: const Scaffold(),
          ),
        ),
      ),
    );
    drawer.currentState!.open();
    await t.pumpAndSettle();
    await t.longPress(find.text('Test conversation'));
    await t.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      isNot('SlideDrawer'),
    );
    await t.tap(find.text('Delete'));
    await t.pumpAndSettle();
    expect(find.text('Delete this chat?'), findsOneWidget);
    await t.tap(find.widgetWithText(TextButton, 'Delete'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
}
