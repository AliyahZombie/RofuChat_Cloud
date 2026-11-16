import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/widgets/fit_action_row.dart';

Widget _box(String k) => Listener(key: ValueKey(k), behavior: HitTestBehavior.opaque, child: const SizedBox(width: 48, height: 48));

Future<void> _pump(WidgetTester tester, double width) => tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: FitActionRow(children: [
            ActionSlot(drop: 2, child: _box('copy')),
            _box('nav'),
            ActionSlot(drop: 1, child: _box('edit')),
            _box('more'),
          ]),
        ),
      ),
    ));

void main() {
  testWidgets('fits at full size', (tester) async {
    await _pump(tester, 400);
    expect(tester.getSize(find.byType(FitActionRow)).height, 48);
    expect(tester.getTopLeft(find.byKey(const ValueKey('more'))).dx, 144);
  });

  testWidgets('scales down on one line before folding', (tester) async {
    await _pump(tester, 168); // 192 * 0.875
    final h = tester.getSize(find.byType(FitActionRow)).height;
    expect(h, closeTo(42, 0.01));
    expect(tester.getTopLeft(find.byKey(const ValueKey('more'))).dy, 0);
    expect(find.byKey(const ValueKey('edit')).hitTestable(), findsOneWidget);
  });

  testWidgets('folds edit first, then copy', (tester) async {
    await _pump(tester, 140);
    expect(find.byKey(const ValueKey('edit')).hitTestable(), findsNothing);
    expect(find.byKey(const ValueKey('copy')).hitTestable(), findsOneWidget);
    await _pump(tester, 100);
    expect(find.byKey(const ValueKey('copy')).hitTestable(), findsNothing);
    expect(find.byKey(const ValueKey('more')).hitTestable(), findsOneWidget);
  });
}
