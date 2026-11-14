import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/widgets/common.dart';
import 'package:rofuchat/widgets/motion.dart';
import 'package:rofuchat/widgets/slide_drawer.dart';

void main() {
  testWidgets('SlideDrawer opens with an eased curve and closes on scrim tap', (t) async {
    final key = GlobalKey<SlideDrawerState>();
    await t.pumpWidget(MaterialApp(
      home: SlideDrawer(key: key, width: 300, drawer: const Text('side'), child: const Scaffold(body: Text('main'))),
    ));
    expect(find.text('side'), findsNothing);
    key.currentState!.open();
    await t.pump();
    await t.pump(const Duration(milliseconds: 190)); // half the 380 ms
    final left = t.getTopLeft(find.byType(Drawer)).dx;
    // Linear would sit at -150; easeOutCubic is already ~87% open.
    expect(left, greaterThan(-60));
    await t.pumpAndSettle();
    expect(t.getTopLeft(find.byType(Drawer)).dx, 0);
    await t.tapAt(const Offset(500, 300));
    await t.pumpAndSettle();
    expect(find.text('side'), findsNothing);
  });

  testWidgets('Collapsible animates height and drops the child when closed', (t) async {
    Widget app(bool open) => MaterialApp(
          home: Scaffold(body: Column(children: [Collapsible(open: open, child: const SizedBox(height: 100, child: Text('body')))])),
        );
    await t.pumpWidget(app(false));
    expect(find.text('body'), findsNothing);
    await t.pumpWidget(app(true));
    await t.pump(const Duration(milliseconds: 130));
    final h = t.getSize(find.byType(Collapsible)).height;
    expect(h, greaterThan(50)); // eased, past linear midpoint
    expect(h, lessThan(100));
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(Collapsible)).height, 100);
  });

  testWidgets('showActions: right click gives a popup menu, long press a sheet', (t) async {
    String? got;
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (c) => GestureDetector(
            onSecondaryTapUp: (d) async => got = await showActions(c, const [MenuAction('del', Icons.delete, 'Delete')], at: d.globalPosition),
            onLongPress: () async => got = await showActions(c, const [MenuAction('ren', Icons.edit, 'Rename')]),
            child: const SizedBox(width: 200, height: 60, child: Text('row')),
          ),
        ),
      ),
    ));
    await t.tap(find.text('row'), buttons: kSecondaryButton);
    await t.pumpAndSettle();
    expect(find.byType(PopupMenuItem<String>), findsOneWidget);
    await t.tap(find.text('Delete'));
    await t.pumpAndSettle();
    expect(got, 'del');
    await t.longPress(find.text('row'));
    await t.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await t.tap(find.text('Rename'));
    await t.pumpAndSettle();
    expect(got, 'ren');
  });
}
