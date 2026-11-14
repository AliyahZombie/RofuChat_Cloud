import 'package:flutter/material.dart';

enum FormFactor { watch, phone, desktop }

FormFactor formFactorOf(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  if (size.shortestSide < 300) return FormFactor.watch;
  if (size.width >= 1000) return FormFactor.desktop;
  return FormFactor.phone;
}

extension FormFactorX on BuildContext {
  FormFactor get formFactor => formFactorOf(this);
  bool get isWatch => formFactor == FormFactor.watch;
  bool get isDesktop => formFactor == FormFactor.desktop;
}

/// Extra horizontal inset for round watch screens so content stays inside the circle.
double watchInset(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.shortestSide < 300 ? size.width * 0.146 : 0;
}
