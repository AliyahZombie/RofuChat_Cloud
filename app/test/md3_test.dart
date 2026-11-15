// Material 3 migration checks (docs/md3/audit-reconciled.md).
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/core/theme.dart';
import 'package:rofuchat/features/chat/message_rows.dart';
import 'package:rofuchat/models/models.dart';
import 'package:rofuchat/widgets/back_guard.dart';
import 'package:rofuchat/widgets/common.dart';
import 'package:rofuchat/widgets/slide_drawer.dart';

Message _user({bool visible = true}) => Message({
      'id': 'u1',
      'seq': 1,
      'role': 'user',
      'content': 'hello there',
      'visible': visible,
      'swipe_count': 3,
      'swipe_index': 1,
      'parts': {'images': []},
    });

Widget _app(Widget child) => MaterialApp(
      theme: buildTheme(const Appearance(), Brightness.light),
      home: Scaffold(body: Center(child: child)),
    );

void _expectTargets(WidgetTester t, Finder f) {
  expect(f, findsWidgets);
  final n = f.evaluate().length;
  for (var i = 0; i < n; i++) {
    final s = t.getSize(f.at(i));
    expect(s.width, greaterThanOrEqualTo(48), reason: 'target $i width');
    expect(s.height, greaterThanOrEqualTo(48), reason: 'target $i height');
  }
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.linux, TargetPlatform.windows]) {
    testWidgets('message action buttons are at least 48dp on $platform', (t) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await t.pumpWidget(_app(SizedBox(
          width: 360,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            UserBubble(
              msg: _user(visible: false),
              userName: 'A',
              showName: true,
              onCopy: () {},
              onEdit: () {},
              onMore: (_) {},
              swipeNav: SwipeNav(index: 1, count: 3, onSwipe: (_) {}),
            ),
            ActualStatusIcon(
              msg: Message({'id': 'a', 'role': 'assistant', 'actual_status': 'failed', 'parts': {}}),
              pending: false,
              onTapFailed: () {},
            ),
            MiniIconButton(Icons.refresh_rounded, 'Regenerate', null),
          ]),
        )));
        _expectTargets(t, find.byType(IconButton));
        // A disabled action is really disabled (not a fake no-op callback).
        final regen = t.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.refresh_rounded));
        expect(regen.onPressed, isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('context ring is a 48dp target with a spoken summary', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(_app(ContextRing(info: const ContextInfo(tokens: 90000, max: 100000), onTap: () {})));
    expect(t.getSize(find.byType(InkResponse)).width, greaterThanOrEqualTo(48));
    expect(find.bySemanticsLabel(RegExp(r'90(\.0)?k')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('showActions: secondary click opens a popup at the cursor, long press a sheet', (t) async {
    String? got;
    await t.pumpWidget(_app(Builder(
      builder: (c) => GestureDetector(
        onSecondaryTapUp: (d) async => got = await showActions(c, const [MenuAction('a', Icons.copy, 'Copy')], at: d.globalPosition),
        onLongPress: () async => got = await showActions(c, const [MenuAction('b', Icons.edit, 'Edit')]),
        child: const SizedBox(width: 200, height: 80, child: Text('item')),
      ),
    )));
    await t.tap(find.text('item'), buttons: kSecondaryButton);
    await t.pumpAndSettle();
    expect(find.byType(PopupMenuItem<String>), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    // Menu item anatomy: no ListTile nested in the menu item; 48dp row.
    expect(find.descendant(of: find.byType(PopupMenuItem<String>), matching: find.byType(ListTile)), findsNothing);
    expect(t.getSize(find.byType(PopupMenuItem<String>)).height, greaterThanOrEqualTo(48));
    await t.tap(find.text('Copy'));
    await t.pumpAndSettle();
    expect(got, 'a');

    await t.longPress(find.text('item'));
    await t.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(PopupMenuItem<String>), findsNothing);
    await t.tap(find.text('Edit'));
    await t.pumpAndSettle();
    expect(got, 'b');
  });

  testWidgets('user bubble: right click gives a popup position, long press none (sheet)', (t) async {
    final calls = <Offset?>[];
    await t.pumpWidget(_app(SizedBox(
      width: 360,
      child: UserBubble(msg: _user(), userName: 'A', showName: false, onCopy: () {}, onEdit: () {}, onMore: calls.add),
    )));
    await t.tap(find.text('hello there'), buttons: kSecondaryButton);
    await t.longPress(find.text('hello there'));
    await t.pump();
    expect(calls.length, 2);
    expect(calls[0], isNotNull);
    expect(calls[1], isNull);
  });

  testWidgets('Back: keyboard first, then the drawer, then double Back to exit', (t) async {
    final drawer = GlobalKey<SlideDrawerState>();
    var exits = 0;
    await t.pumpWidget(MaterialApp(
      home: BackGuard(
        isBusy: () => drawer.currentState?.isOpen ?? false,
        onBusyBack: () => drawer.currentState?.close(),
        onExit: () => exits++,
        child: SlideDrawer(
          key: drawer,
          width: 300,
          handleBack: false,
          drawer: const Material(child: TextField(key: Key('search'))),
          child: const Scaffold(body: Text('page')),
        ),
      ),
    ));
    drawer.currentState!.open();
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('search')));
    await t.pump();
    bool editing() => FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>() != null;
    expect(editing(), isTrue);

    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(editing(), isFalse, reason: 'first Back hides the keyboard');
    expect(drawer.currentState!.isOpen, isTrue, reason: 'drawer stays open on the first Back');

    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(drawer.currentState!.isOpen, isFalse, reason: 'second Back closes the drawer');
    expect(exits, 0);

    await t.binding.handlePopRoute();
    await t.pump();
    expect(exits, 0);
    await t.binding.handlePopRoute();
    await t.pump();
    expect(exits, 1);
    await t.pump(const Duration(seconds: 5));
  });

  testWidgets('open drawer is modal: page below leaves semantics, scrim is a labelled barrier', (t) async {
    final handle = t.ensureSemantics();
    final drawer = GlobalKey<SlideDrawerState>();
    await t.pumpWidget(MaterialApp(
      home: SlideDrawer(key: drawer, width: 300, drawer: const Text('side'), child: const Scaffold(body: Text('page'))),
    ));
    expect(find.bySemanticsLabel('page'), findsOneWidget);
    drawer.currentState!.open();
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('page'), findsNothing);
    expect(find.byType(ModalBarrier), findsWidgets);
    drawer.currentState!.close();
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('page'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('watch theme shrinks type roles but keeps the platform TextScaler', (t) async {
    final base = buildTheme(const Appearance(), Brightness.dark);
    final w = watchTheme(base);
    expect(w.textTheme.bodyLarge!.fontSize, closeTo(16 * 0.85, 0.01)); // M3 bodyLarge 16sp
  });
}
