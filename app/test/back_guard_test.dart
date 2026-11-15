import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/widgets/back_guard.dart';

void main() {
  Future<int Function()> pump(
    WidgetTester tester, {
    bool Function()? busy,
  }) async {
    var exits = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BackGuard(
          isBusy: busy,
          onExit: () => exits++,
          child: const Scaffold(body: TextField()),
        ),
      ),
    );
    return () => exits;
  }

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump();
  }

  testWidgets('first Back hides the keyboard, then two Backs exit', (
    tester,
  ) async {
    final exits = await pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>(),
      isNotNull,
    );
    await back(tester);
    expect(exits(), 0);
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>(),
      isNull,
    );
    await back(tester);
    expect(exits(), 0);
    expect(
      find.text('再按一次返回键退出').evaluate().isNotEmpty ||
          find.text('Press Back again to exit').evaluate().isNotEmpty,
      isTrue,
    );
    await back(tester);
    expect(exits(), 1);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('a busy page (open drawer) consumes Back', (tester) async {
    var busy = true;
    final exits = await pump(tester, busy: () => busy);
    await back(tester);
    await back(tester);
    expect(exits(), 0);
    busy = false;
    await back(tester);
    await back(tester);
    expect(exits(), 1);
    await tester.pump(const Duration(seconds: 5));
  });
}
