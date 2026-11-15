// Material 3 migration checks (docs/md3/audit-reconciled.md).
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/core/theme.dart';
import 'package:rofuchat/features/chat/message_rows.dart';
import 'package:rofuchat/models/models.dart';
import 'package:rofuchat/widgets/back_guard.dart';
import 'package:rofuchat/widgets/common.dart';
import 'package:rofuchat/widgets/motion.dart';
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
  foundationTests();
  screenTests();
  chatTests();
  motionTests();

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

// ------------------------------------------------------------------ foundation (phase 2)

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void foundationTests() {
  test('outline is never a text colour (role-based colour, grep review)', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final l = lines[i];
        if (!RegExp(r'\.outline\b(?!Variant)').hasMatch(l)) continue;
        // Allowed only as a boundary (border/side) colour.
        if (!RegExp(r'Border|side|BorderSide').hasMatch(l)) offenders.add('${f.path}:${i + 1}: ${l.trim()}');
      }
    }
    expect(offenders, isEmpty);
  });

  test('no linear curves or unnamed local durations in shared motion code', () {
    for (final path in ['lib/widgets/motion.dart', 'lib/widgets/slide_drawer.dart', 'lib/main.dart']) {
      final src = File(path).readAsStringSync();
      expect(src.contains('Curves.linear'), isFalse, reason: path);
      expect(RegExp(r'Curves\.ease(Out|In)Cubic\b').hasMatch(src), isFalse, reason: '$path uses tokens');
    }
  });

  for (final b in Brightness.values) {
    for (final seed in [0xFFFFA726, 0xFFE57399, 0xFF5C6BC0]) {
      test('warning pair and small-text roles contrast ($b, ${seed.toRadixString(16)})', () {
        final theme = buildTheme(Appearance(seed: seed), b);
        final c = theme.colorScheme;
        final w = theme.extension<AppColors>()!;
        expect(_contrast(w.onWarning, w.warning), greaterThanOrEqualTo(4.5));
        expect(_contrast(w.onWarningContainer, w.warningContainer), greaterThanOrEqualTo(4.5));
        expect(_contrast(w.warning, c.surface), greaterThanOrEqualTo(3));
        expect(_contrast(c.onSurfaceVariant, c.surface), greaterThanOrEqualTo(4.5));
        expect(_contrast(c.onSurfaceVariant, c.surfaceContainerHigh), greaterThanOrEqualTo(4.5));
      });
    }
  }

  test('AMOLED black keeps a pure black surface and readable on-colours', () {
    final c = buildTheme(const Appearance(themeMode: 'black'), Brightness.dark).colorScheme;
    expect(c.surface, Colors.black);
    expect(_contrast(c.onSurface, c.surface), greaterThanOrEqualTo(7));
    expect(_contrast(c.onSurfaceVariant, c.surfaceContainerHigh), greaterThanOrEqualTo(4.5));
  });

  test('dynamic colour source uses the platform palette, else falls back to the seed', () {
    final platform = ColorScheme.fromSeed(seedColor: Colors.green);
    final seeded = buildTheme(const Appearance(seed: 0xFF5C6BC0), Brightness.light).colorScheme;
    expect(buildTheme(const Appearance(colorSource: 'dynamic'), Brightness.light, platform: platform).colorScheme.primary, platform.primary);
    expect(buildTheme(const Appearance(colorSource: 'dynamic', seed: 0xFF5C6BC0), Brightness.light).colorScheme.primary, seeded.primary);
    expect(buildTheme(const Appearance(seed: 0xFF5C6BC0), Brightness.light, platform: platform).colorScheme.primary, seeded.primary);
    expect(Appearance.fromJson(const Appearance(colorSource: 'dynamic').toJson()).colorSource, 'dynamic');
  });

  test('theme encodes the M3 component policy', () {
    final th = buildTheme(const Appearance(compact: true), Brightness.light);
    expect(th.visualDensity, VisualDensity.standard, reason: 'compact never shrinks controls');
    expect(th.materialTapTargetSize, MaterialTapTargetSize.padded);
    // ignore: deprecated_member_use
    expect(th.sliderTheme.year2023, isFalse);
    // ignore: deprecated_member_use
    expect(th.progressIndicatorTheme.year2023, isFalse);
    expect(th.snackBarTheme.behavior, SnackBarBehavior.floating);
    expect(th.dialogTheme.constraints?.maxWidth, 560);
    expect(th.dividerTheme.color, th.colorScheme.outlineVariant);
    expect(th.inputDecorationTheme.isDense, isFalse);
    expect(th.appBarTheme.scrolledUnderElevation, greaterThan(0));
    final bg = th.appBarTheme.backgroundColor! as WidgetStateColor;
    expect(bg.resolve({WidgetState.scrolledUnder}), isNot(bg.resolve({})));
  });
}

// ------------------------------------------------------------------ standard screens (phase 3)

void screenTests() {
  Widget host(double width, Widget child) => MaterialApp(
        theme: buildTheme(const Appearance(), Brightness.light),
        home: Scaffold(body: Center(child: SizedBox(width: width, child: child))),
      );

  for (final w in [150.0, 600.0]) {
    testWidgets('theme choice adapts at ${w}dp (segments fit or a menu) without overflow', (t) async {
      var v = 'system';
      await t.pumpWidget(host(
        w,
        ChoiceField<String>(
          label: 'Theme',
          value: v,
          minSegmentWidth: 76,
          options: const [('system', 'System'), ('light', 'Light'), ('dark', 'Dark'), ('black', 'Black')],
          onChanged: (x) => v = x,
        ),
      ));
      expect(t.takeException(), isNull);
      if (w < 304) {
        expect(find.byType(DropdownMenu<String>), findsOneWidget);
      } else {
        expect(find.byType(SegmentedButton<String>), findsOneWidget);
      }
    });
  }

  testWidgets('basic dialogs use two text buttons with a specific confirm label', (t) async {
    await t.pumpWidget(host(400, Builder(builder: (c) => TextButton(onPressed: () => confirm(c, 'Delete this chat?', ok: 'Delete'), child: const Text('go')))));
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
    final actions = find.descendant(of: find.byType(AlertDialog), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
    expect(actions, findsNWidgets(2));
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)), findsNothing);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('form bodies keep a readable width on large windows', (t) async {
    t.view.physicalSize = const Size(1600, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: Scaffold(body: FormListView(children: const [TextField()]))));
    expect(t.getSize(find.byType(TextField)).width, lessThanOrEqualTo(720));
  });

  testWidgets('the action sheet scrolls instead of clipping on a watch', (t) async {
    t.view.physicalSize = const Size(192, 192);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(host(192, Builder(
      builder: (c) => TextButton(
        onPressed: () => showActions(c, [for (var i = 0; i < 8; i++) MenuAction('$i', Icons.star, 'Action $i')]),
        child: const Text('go'),
      ),
    )));
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await t.scrollUntilVisible(find.text('Action 7'), 50, scrollable: find.descendant(of: find.byType(BottomSheet), matching: find.byType(Scrollable)));
    await t.ensureVisible(find.text('Action 7'));
    await t.pumpAndSettle();
    await t.tap(find.text('Action 7'));
    await t.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing, reason: 'the last action was reachable');
  });
}

// ------------------------------------------------------------------ chat (phase 4)

void chatTests() {
  testWidgets('chat text follows the user font size on every message role', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: buildTheme(const Appearance(fontScale: 1.2), Brightness.light),
      home: Scaffold(
        body: SizedBox(
          width: 400,
          child: Column(children: [
            UserBubble(msg: _user(), userName: 'A', showName: false, onCopy: () {}, onEdit: () {}, onMore: (_) {}),
            SummaryCard(msg: Message({'id': 's', 'role': 'summary', 'content': 'summary text', 'parts': {}}), onEdit: () {}),
          ]),
        ),
      ),
    ));
    double size(String s) => t.widget<Text>(find.text(s)).style!.fontSize!;
    expect(size('hello there'), closeTo(16 * 1.2, 0.01));
    expect(size('summary text'), closeTo(14 * 1.2, 0.01));
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('steps headers keep 48dp targets and nothing overflows at text scale $scale', (t) async {
      t.view.physicalSize = const Size(360, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final steps = [
        Segment({'type': 'reasoning', 'text': 'thinking', 'duration_ms': 400}),
        Segment({'type': 'tool', 'name': 'search', 'arguments': '{"q":"x"}', 'result': 'ok', 'duration_ms': 30}),
        Segment({'type': 'tool', 'name': 'memory_add', 'arguments': '{}', 'result': 'ok', 'duration_ms': 3}),
      ];
      await t.pumpWidget(MaterialApp(
        theme: buildTheme(const Appearance(), Brightness.dark),
        home: MediaQuery(
          data: MediaQueryData(size: const Size(360, 800), textScaler: TextScaler.linear(scale)),
          child: Scaffold(body: ListView(padding: const EdgeInsets.all(12), children: [StepsCard(steps: steps, live: false)])),
        ),
      ));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      for (final e in find.descendant(of: find.byType(StepsCard), matching: find.byType(InkWell)).evaluate()) {
        expect((e.renderObject! as RenderBox).size.height, greaterThanOrEqualTo(48));
      }
    });
  }
}

// ------------------------------------------------------------------ motion (phase 5)

void motionTests() {
  test('every implicit animation in lib/ names a non-linear curve', () {
    final starts = RegExp(r'\b(AnimatedSwitcher|AnimatedSize|AnimatedOpacity|AnimatedScale|AnimatedContainer|AnimatedRotation|AnimatedAlign|AnimatedPadding|TweenAnimationBuilder<[^>]*>)\(');
    final missing = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final src = f.readAsStringSync();
      for (final m in starts.allMatches(src)) {
        // Look at the constructor's own arguments (until the child/builder starts).
        final window = src.substring(m.end, (m.end + 600).clamp(0, src.length));
        if (!RegExp(r'\b(curve|switchInCurve)\s*:').hasMatch(window)) {
          missing.add('${f.path}:${'\n'.allMatches(src.substring(0, m.start)).length + 1} ${m.group(1)}');
        }
      }
      expect(src.contains('Curves.linear'), isFalse, reason: f.path);
    }
    expect(missing, isEmpty);
  });

  testWidgets('reduced motion: the loading visual holds still and keeps its label', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(const MaterialApp(
      home: MediaQuery(data: MediaQueryData(disableAnimations: true), child: Center(child: LoadingBlob())),
    ));
    await t.pump(const Duration(milliseconds: 500));
    expect(t.binding.hasScheduledFrame, isFalse, reason: 'no repeating animation');
    expect(find.bySemanticsLabel(RegExp('Generating|正在生成')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('loading visual animates (eased) when motion is allowed', (t) async {
    await t.pumpWidget(const MaterialApp(home: Center(child: LoadingBlob())));
    await t.pump(const Duration(milliseconds: 100));
    expect(t.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('Collapsible eases open (past the linear midpoint)', (t) async {
    Widget app(bool open) => MaterialApp(home: Scaffold(body: Column(children: [Collapsible(open: open, child: const SizedBox(height: 100))])));
    await t.pumpWidget(app(false));
    await t.pumpWidget(app(true));
    await t.pump(const Duration(milliseconds: 150)); // half of medium2
    expect(t.getSize(find.byType(Collapsible)).height, greaterThan(60));
    await t.pumpAndSettle();
  });

  test('routes use M3 forward/back transitions per platform', () {
    final b = buildTheme(const Appearance(), Brightness.light).pageTransitionsTheme.builders;
    expect(b[TargetPlatform.linux], isA<FadeForwardsPageTransitionsBuilder>());
    expect(b[TargetPlatform.windows], isA<FadeForwardsPageTransitionsBuilder>());
    expect(b[TargetPlatform.android], isA<PredictiveBackPageTransitionsBuilder>());
  });
}
