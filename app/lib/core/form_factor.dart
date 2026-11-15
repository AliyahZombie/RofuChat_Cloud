import 'package:flutter/material.dart';

enum FormFactor { watch, phone, desktop }

FormFactor formFactorOf(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  // Round watches are tiny; rectangular ones (e.g. 408x502 px at ~1.3x) can reach ~320x390 dp,
  // still far shorter than any phone (longest side >= 568 dp).
  if (size.shortestSide < 300 || (size.shortestSide < 420 && size.longestSide < 560)) return FormFactor.watch;
  if (size.width >= 1000) return FormFactor.desktop;
  return FormFactor.phone;
}

extension FormFactorX on BuildContext {
  FormFactor get formFactor => formFactorOf(this);
  bool get isWatch => formFactor == FormFactor.watch;
  bool get isDesktop => formFactor == FormFactor.desktop;
}

/// Extra horizontal inset for round (square-ish) watch screens so content stays inside the circle.
double watchInset(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final round = (size.width - size.height).abs() < 24;
  return formFactorOf(context) == FormFactor.watch && round ? size.width * 0.146 : 0;
}
