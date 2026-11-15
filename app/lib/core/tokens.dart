// Material 3 design tokens used across the app (docs/md3/audit-reconciled.md, shared foundation).
//
// Spacing sits on a 4dp grid, corners use the M3 corner-radius scale, and every animation
// uses a non-linear M3 easing (the product rule: no linear motion). Named product
// exceptions are documented where they are declared.
import 'package:flutter/material.dart';

/// Spacing on the 4dp grid. `x3` = 12dp and so on.
abstract final class Insets {
  static const double x1 = 4, x2 = 8, x3 = 12, x4 = 16, x5 = 20, x6 = 24, x8 = 32, x10 = 40, x12 = 48;

  /// Minimum size of every interactive target (M3 §State layers). Never shrink a hit area
  /// below this; compact mode only tightens content spacing.
  static const double target = 48;

  /// Optical exception: 2dp hairline gaps between tightly related glyphs/labels.
  static const double hairline = 2;
}

/// Corner radii from the M3 scale: none 0, extra-small 4, small 8, medium 12, large 16,
/// large-increased 20, extra-large 28, full.
abstract final class Corners {
  static const double none = 0, xs = 4, sm = 8, md = 12, lg = 16, lgIncreased = 20, xl = 28;

  static const BorderRadius rXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius rSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl));

  /// User chat bubble: M3 large-increased (20dp), also frontend-spec §3.1.
  static const BorderRadius bubble = BorderRadius.all(Radius.circular(lgIncreased));
  static const BorderRadius sheetTop = BorderRadius.vertical(top: Radius.circular(xl));
  static const StadiumBorder full = StadiumBorder();
}

/// M3 elevation levels 0..5 in dp.
abstract final class Elevation {
  static const double level0 = 0, level1 = 1, level2 = 3, level3 = 6, level4 = 8, level5 = 12;
}

/// M3 motion tokens: durations short1..extraLong4 and the standard / emphasized easings.
abstract final class Motion {
  static const short1 = Duration(milliseconds: 50);
  static const short2 = Duration(milliseconds: 100);
  static const short3 = Duration(milliseconds: 150);
  static const short4 = Duration(milliseconds: 200);
  static const medium1 = Duration(milliseconds: 250);
  static const medium2 = Duration(milliseconds: 300);
  static const medium3 = Duration(milliseconds: 350);
  static const medium4 = Duration(milliseconds: 400);
  static const long1 = Duration(milliseconds: 450);
  static const long2 = Duration(milliseconds: 500);
  static const long3 = Duration(milliseconds: 550);
  static const long4 = Duration(milliseconds: 600);
  static const extraLong1 = Duration(milliseconds: 700);
  static const extraLong2 = Duration(milliseconds: 800);
  static const extraLong3 = Duration(milliseconds: 900);
  static const extraLong4 = Duration(milliseconds: 1000);

  static const Curve standard = Cubic(0.2, 0, 0, 1);
  static const Curve standardDecelerate = Cubic(0, 0, 0, 1);
  static const Curve standardAccelerate = Cubic(0.3, 0, 1, 1);
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0, 0.8, 0.15);

  /// True when the platform asks for reduced motion.
  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [token], or zero when the platform asks for reduced motion.
  static Duration of(BuildContext context, Duration token) => reduced(context) ? Duration.zero : token;
}

/// Opacity of a message that is excluded from the model context (frontend-spec §3.1).
const double kExcludedOpacity = 0.5;

/// M3 window size classes by available width (independent of the watch predicate and of
/// the input device).
enum WindowSizeClass { compact, medium, expanded, large, extraLarge }

WindowSizeClass windowSizeClassOf(double width) => switch (width) {
      < 600 => WindowSizeClass.compact,
      < 840 => WindowSizeClass.medium,
      < 1200 => WindowSizeClass.expanded,
      < 1600 => WindowSizeClass.large,
      _ => WindowSizeClass.extraLarge,
    };

/// Readable maximum width for forms and settings on large windows.
const double kFormMaxWidth = 720;
