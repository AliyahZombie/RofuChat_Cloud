import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'tokens.dart';

class Appearance {
  final String themeMode; // system | light | dark | black

  /// Where the colour scheme comes from: 'seed' (a preset or custom seed in [seed]) or
  /// 'dynamic' (the platform palette, Android 12+ / desktop accent; falls back to [seed]).
  final String colorSource;
  final int seed; // ARGB
  final double fontScale;
  final bool compact;
  final bool fullWidth;
  final bool showAvatars;
  final bool showTokens;
  final bool enterToSend;
  final String language; // '' | zh | en
  /// Characters of history fetched per page when opening a chat / scrolling up.
  final int loadChars;

  /// How far from the left edge a rightward swipe may start to open the sidebar,
  /// in tenths of the screen width (1 to 10; 10 = anywhere).
  final int swipeZone;

  /// Keep loading older history in the background after a chat opens.
  final bool autoLoadHistory;

  /// Most messages kept live in a chat; older loaded ones are cached compactly and brought
  /// back as you scroll up.
  final int windowMessages;

  /// Device shape: 'auto' (Wear OS feature flag / screen roundness from Android, else the
  /// shortestSide < 300 rule), 'round' or 'square' (watch layout), or 'phone'.
  final String deviceShape;

  const Appearance({
    this.themeMode = 'system',
    this.colorSource = 'seed',
    this.seed = 0xFF5C6BC0,
    this.fontScale = 1.0,
    this.compact = true,
    this.fullWidth = true,
    this.showAvatars = true,
    this.showTokens = true,
    this.enterToSend = false,
    this.language = '',
    this.loadChars = 20000,
    this.swipeZone = 6,
    this.autoLoadHistory = true,
    this.windowMessages = 1000,
    this.deviceShape = 'auto',
  });

  factory Appearance.fromJson(Map<String, dynamic> j) => Appearance(
    themeMode: j['theme_mode'] as String? ?? 'system',
    colorSource: j['color_source'] == 'dynamic' ? 'dynamic' : 'seed',
    seed: (j['seed'] as num?)?.toInt() ?? 0xFF5C6BC0,
    fontScale: (j['font_scale'] as num?)?.toDouble() ?? 1.0,
    compact: j['compact'] as bool? ?? true,
    fullWidth: j['full_width'] as bool? ?? true,
    showAvatars: j['show_avatars'] as bool? ?? true,
    showTokens: j['show_tokens'] as bool? ?? true,
    enterToSend: j['enter_sends'] as bool? ?? false,
    language: j['language'] as String? ?? '',
    loadChars: (j['load_chars'] as num?)?.toInt() ?? 20000,
    swipeZone: ((j['swipe_zone'] as num?)?.toInt() ?? 6).clamp(1, 10),
    autoLoadHistory: j['auto_load_history'] as bool? ?? true,
    windowMessages: ((j['window_messages'] as num?)?.toInt() ?? 1000).clamp(100, 10000),
    deviceShape: switch (j['device_shape']) {
      'round' => 'round',
      'square' => 'square',
      'phone' => 'phone',
      _ => 'auto',
    },
  );

  Map<String, dynamic> toJson() => {
    'theme_mode': themeMode,
    'color_source': colorSource,
    'seed': seed,
    'font_scale': fontScale,
    'compact': compact,
    'full_width': fullWidth,
    'show_avatars': showAvatars,
    'show_tokens': showTokens,
    'enter_sends': enterToSend,
    'language': language,
    'load_chars': loadChars,
    'swipe_zone': swipeZone,
    'auto_load_history': autoLoadHistory,
    'window_messages': windowMessages,
    'device_shape': deviceShape,
  };

  Appearance copyWith({
    String? themeMode,
    String? colorSource,
    int? seed,
    double? fontScale,
    bool? compact,
    bool? fullWidth,
    bool? showAvatars,
    bool? showTokens,
    bool? enterToSend,
    String? language,
    int? loadChars,
    int? swipeZone,
    bool? autoLoadHistory,
    int? windowMessages,
    String? deviceShape,
  }) => Appearance(
    themeMode: themeMode ?? this.themeMode,
    colorSource: colorSource ?? this.colorSource,
    seed: seed ?? this.seed,
    fontScale: fontScale ?? this.fontScale,
    compact: compact ?? this.compact,
    fullWidth: fullWidth ?? this.fullWidth,
    showAvatars: showAvatars ?? this.showAvatars,
    showTokens: showTokens ?? this.showTokens,
    enterToSend: enterToSend ?? this.enterToSend,
    language: language ?? this.language,
    loadChars: loadChars ?? this.loadChars,
    swipeZone: swipeZone ?? this.swipeZone,
    autoLoadHistory: autoLoadHistory ?? this.autoLoadHistory,
    windowMessages: windowMessages ?? this.windowMessages,
    deviceShape: deviceShape ?? this.deviceShape,
  );

  ThemeMode get mode => switch (themeMode) {
    'light' => ThemeMode.light,
    'dark' || 'black' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

const seedPresets = <(String, String, int)>[
  ('靛蓝', 'Indigo', 0xFF5C6BC0),
  ('樱粉', 'Sakura', 0xFFE57399),
  ('薄荷', 'Mint', 0xFF26A69A),
  ('琥珀', 'Amber', 0xFFFFA726),
  ('石板', 'Slate', 0xFF607D8B),
  ('紫罗兰', 'Violet', 0xFF8E5CD9),
  ('海蓝', 'Ocean', 0xFF1E88E5),
];

/// Product colour roles that the M3 ColorScheme does not have, with paired on-colours.
/// Warning keeps the orange meaning required by frontend-spec §3.1 (context ring 60–85%).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  const AppColors({required this.warning, required this.onWarning, required this.warningContainer, required this.onWarningContainer});

  /// Derived per brightness from an orange source, so the tones contrast with the surface
  /// like any other M3 accent role.
  factory AppColors.of(Brightness b) {
    final w = ColorScheme.fromSeed(seedColor: const Color(0xFFFB8C00), brightness: b, dynamicSchemeVariant: DynamicSchemeVariant.fidelity);
    return AppColors(warning: w.primary, onWarning: w.onPrimary, warningContainer: w.primaryContainer, onWarningContainer: w.onPrimaryContainer);
  }

  static AppColors resolve(BuildContext context) => Theme.of(context).extension<AppColors>() ?? AppColors.of(Theme.of(context).brightness);

  @override
  AppColors copyWith({Color? warning, Color? onWarning, Color? warningContainer, Color? onWarningContainer}) => AppColors(
        warning: warning ?? this.warning,
        onWarning: onWarning ?? this.onWarning,
        warningContainer: warningContainer ?? this.warningContainer,
        onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
    );
  }
}

/// Typography policy beyond the M3 TextTheme: the user's chat font size and the code style.
///
/// [chatScale] (Appearance → Font size) applies to every chat text role — assistant
/// markdown, user bubbles, reasoning/tool steps, summaries and the composer — while app
/// chrome follows the M3 roles. Both compose with the platform TextScaler, which is never
/// replaced.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  final double chatScale;
  final bool compact;
  const AppTypography({this.chatScale = 1, this.compact = true});

  static AppTypography of(BuildContext context) => Theme.of(context).extension<AppTypography>() ?? const AppTypography();

  /// A chat text role scaled by the user's font size.
  static TextStyle chat(BuildContext context, TextStyle? role) {
    final r = role ?? Theme.of(context).textTheme.bodyLarge!;
    final scale = of(context).chatScale;
    return scale == 1 || r.fontSize == null ? r : r.copyWith(fontSize: r.fontSize! * scale);
  }

  /// Monospace style derived from an M3 role (bodyMedium by default): only the family
  /// changes, so tracking, line height and scaling follow the role.
  static TextStyle code(BuildContext context, {TextStyle? role}) =>
      (role ?? Theme.of(context).textTheme.bodyMedium!).copyWith(fontFamily: 'monospace', fontFamilyFallback: const ['Menlo', 'Consolas', 'Noto Sans Mono CJK SC', 'monospace']);

  @override
  AppTypography copyWith({double? chatScale, bool? compact}) => AppTypography(chatScale: chatScale ?? this.chatScale, compact: compact ?? this.compact);

  @override
  AppTypography lerp(AppTypography? other, double t) {
    if (other == null) return this;
    return AppTypography(chatScale: chatScale + (other.chatScale - chatScale) * t, compact: t < 0.5 ? compact : other.compact);
  }
}

/// The scheme for [a] in brightness [b]. [platform] is the platform's dynamic palette when
/// available; it is used only when the user picked the dynamic colour source.
ColorScheme resolveScheme(Appearance a, Brightness b, {ColorScheme? platform}) {
  var scheme = (a.colorSource == 'dynamic' ? platform : null) ?? ColorScheme.fromSeed(seedColor: Color(a.seed), brightness: b);
  if (b == Brightness.dark && a.themeMode == 'black') {
    // AMOLED black (frontend-spec §10): an intentional deviation from the seeded neutrals.
    // The container hierarchy keeps distinct steps; on-colours are unchanged.
    scheme = scheme.copyWith(
      surface: Colors.black,
      surfaceDim: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: const Color(0xFF0B0B0D),
      surfaceContainer: const Color(0xFF111114),
      surfaceContainerHigh: const Color(0xFF17171B),
      surfaceContainerHighest: const Color(0xFF1E1E23),
    );
  }
  return scheme;
}

ThemeData buildTheme(Appearance a, Brightness b, {ColorScheme? platform}) {
  final scheme = resolveScheme(a, b, platform: platform);
  final scrim = scheme.scrim.withValues(alpha: 0.32);
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: b,
    // Compact mode tightens content spacing only (AppTypography.compact); controls keep
    // standard density and padded 48dp targets on every platform.
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    extensions: [AppColors.of(b), AppTypography(chatScale: a.fontScale, compact: a.compact)],
    // Scrolled-under app bars change tone (surface → surfaceContainer) instead of using
    // the deprecated tint overlay or a shadow.
    appBarTheme: AppBarTheme(
      backgroundColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.scrolledUnder) ? scheme.surfaceContainer : scheme.surface),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: Elevation.level2,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: Corners.rXs),
      isDense: false,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(visualDensity: VisualDensity.standard, tapTargetSize: MaterialTapTargetSize.padded),
    ),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: Corners.rMd),
      clipBehavior: Clip.antiAlias,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      barrierColor: scrim,
      elevation: Elevation.level3,
      shape: const RoundedRectangleBorder(borderRadius: Corners.rXl),
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      modalBarrierColor: scrim,
      modalElevation: Elevation.level1,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: Corners.sheetTop),
      constraints: const BoxConstraints(maxWidth: 640),
    ),
    // Baseline M3 menus: surfaceContainer, level 2, 4dp corners.
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
        elevation: const WidgetStatePropertyAll(Elevation.level2),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Corners.rXs)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainer,
      elevation: Elevation.level2,
      shape: const RoundedRectangleBorder(borderRadius: Corners.rXs),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(borderRadius: Corners.rXs)),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Corners.rXs)),
      ),
    ),
    // Opt into the current M3 slider and progress indicators (handle, track gap, stop).
    // ignore: deprecated_member_use
    sliderTheme: const SliderThemeData(year2023: false),
    // ignore: deprecated_member_use
    progressIndicatorTheme: const ProgressIndicatorThemeData(year2023: false),
    // Forward/back navigation: Android keeps predictive Back; Linux/Windows use the M3
    // fade-forwards pattern instead of the older zoom; Apple platforms keep Cupertino.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: Corners.rXs),
    ),
  );
}

/// Watch theme: a smaller base type scale (frontend-spec §4) applied to the text roles,
/// leaving the platform TextScaler untouched.
ThemeData watchTheme(ThemeData base) {
  // Theme.of() is already localized (sizes present); an unlocalized ThemeData gets the
  // English-like geometry first so every role has a size to scale.
  TextTheme sized(TextTheme t) => t.bodyLarge?.fontSize == null ? base.typography.englishLike.merge(t) : t;
  TextTheme shrink(TextTheme t) => sized(t).apply(fontSizeFactor: 0.85);
  return base.copyWith(textTheme: shrink(base.textTheme), primaryTextTheme: shrink(base.primaryTextTheme));
}
