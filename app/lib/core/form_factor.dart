import 'package:flutter/material.dart';

import 'tokens.dart';

/// Product form factors. [FormFactor.watch] is the shortestSide < 300 rule
/// (frontend-spec §4) and [FormFactor.desktop] the app-specific 1000dp dock threshold for
/// the persistent sidebar (frontend-spec §3.2/3.3). Neither says anything about the input
/// device: context menus dispatch on the actual pointer/touch origin instead.
enum FormFactor { watch, phone, desktop }

/// Width at which the sidebar docks permanently (app-specific, not an M3 breakpoint).
const double kDockWidth = 1000;

FormFactor formFactorOf(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  if (size.shortestSide < 300) return FormFactor.watch;
  if (size.width >= kDockWidth) return FormFactor.desktop;
  return FormFactor.phone;
}

extension FormFactorX on BuildContext {
  FormFactor get formFactor => formFactorOf(this);
  bool get isWatch => formFactor == FormFactor.watch;
  bool get isDesktop => formFactor == FormFactor.desktop;

  /// M3 window size class of the whole window (compact < 600 ≤ medium < 840 ≤ expanded
  /// < 1200 ≤ large < 1600 ≤ extra-large). Pane-level layouts use LayoutBuilder widths.
  WindowSizeClass get windowSizeClass => windowSizeClassOf(MediaQuery.sizeOf(this).width);
}

/// Extra horizontal inset for round watch screens so content stays inside the circle.
double watchInset(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.shortestSide < 300 ? size.width * 0.146 : 0;
}
