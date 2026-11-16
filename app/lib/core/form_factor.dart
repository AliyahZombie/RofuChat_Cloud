import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Product form factors. [FormFactor.watch] comes from the device itself (Android
/// FEATURE_WATCH), the user's override in Appearance, or the shortestSide < 300 rule
/// (frontend-spec §4); [FormFactor.desktop] is the app-specific 1000dp dock threshold for
/// the persistent sidebar (frontend-spec §3.2/3.3). Neither says anything about the input
/// device: context menus dispatch on the actual pointer/touch origin instead.
enum FormFactor { watch, phone, desktop }

/// Width at which the sidebar docks permanently (app-specific, not an M3 breakpoint).
const double kDockWidth = 1000;

/// What the platform says about the screen. Filled once at startup by [probe].
class DeviceInfo {
  /// Android reports FEATURE_WATCH (Wear OS).
  static bool watch = false;

  /// Configuration.isScreenRound(); null when the platform does not say.
  static bool? round;

  static const _channel = MethodChannel('rofu/device');

  static Future<void> probe() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final m = await _channel.invokeMapMethod<String, dynamic>('info');
      watch = m?['watch'] == true;
      round = m?['round'] as bool?;
    } catch (_) {
      // Older builds without the channel: keep the size rule.
    }
  }
}

/// Resolved shape for the subtree: whether to use the watch layout and whether the screen
/// is round (needs a side inset).
class DeviceShape extends InheritedWidget {
  /// 'auto' | 'round' | 'square' | 'phone' (Appearance.deviceShape).
  final String setting;
  const DeviceShape({super.key, required this.setting, required super.child});

  static String settingOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DeviceShape>()?.setting ?? 'auto';

  @override
  bool updateShouldNotify(DeviceShape old) => old.setting != setting;
}

bool _watchOf(BuildContext context) => switch (DeviceShape.settingOf(context)) {
  'round' || 'square' => true,
  'phone' => false,
  _ => DeviceInfo.watch || MediaQuery.sizeOf(context).shortestSide < 300,
};

bool _roundOf(BuildContext context) => switch (DeviceShape.settingOf(context)) {
  'round' => true,
  'square' || 'phone' => false,
  // Platform answer first; without one a small screen is assumed round (most Wear OS).
  _ => DeviceInfo.round ?? MediaQuery.sizeOf(context).shortestSide < 300,
};

FormFactor formFactorOf(BuildContext context) {
  if (_watchOf(context)) return FormFactor.watch;
  if (MediaQuery.sizeOf(context).width >= kDockWidth) return FormFactor.desktop;
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
/// Square watches get none.
double watchInset(BuildContext context) {
  if (!_watchOf(context) || !_roundOf(context)) return 0;
  return MediaQuery.sizeOf(context).width * 0.146;
}
