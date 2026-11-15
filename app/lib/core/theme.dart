import 'package:flutter/material.dart';

class Appearance {
  final String themeMode; // system | light | dark | black
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

  const Appearance({
    this.themeMode = 'system',
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
  });

  factory Appearance.fromJson(Map<String, dynamic> j) => Appearance(
    themeMode: j['theme_mode'] as String? ?? 'system',
    seed: (j['seed'] as num?)?.toInt() ?? 0xFF5C6BC0,
    fontScale: (j['font_scale'] as num?)?.toDouble() ?? 1.0,
    compact: j['compact'] as bool? ?? true,
    fullWidth: j['full_width'] as bool? ?? true,
    showAvatars: j['show_avatars'] as bool? ?? true,
    showTokens: j['show_tokens'] as bool? ?? true,
    // New key: the old enter_to_send was saved as true by default, so it is ignored and
    // everyone starts on Enter = newline.
    enterToSend: j['enter_sends'] as bool? ?? false,
    language: j['language'] as String? ?? '',
    loadChars: (j['load_chars'] as num?)?.toInt() ?? 20000,
    swipeZone: ((j['swipe_zone'] as num?)?.toInt() ?? 6).clamp(1, 10),
  );

  Map<String, dynamic> toJson() => {
    'theme_mode': themeMode,
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
  };

  Appearance copyWith({
    String? themeMode,
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
  }) => Appearance(
    themeMode: themeMode ?? this.themeMode,
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

ThemeData buildTheme(Appearance a, Brightness b) {
  var scheme = ColorScheme.fromSeed(seedColor: Color(a.seed), brightness: b);
  if (b == Brightness.dark && a.themeMode == 'black') {
    scheme = scheme.copyWith(
      surface: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: const Color(0xFF0B0B0D),
      surfaceContainer: const Color(0xFF111114),
      surfaceContainerHigh: const Color(0xFF17171B),
      surfaceContainerHighest: const Color(0xFF1E1E23),
    );
  }
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: b,
  );
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    visualDensity: a.compact ? VisualDensity.compact : VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.4),
      space: 1,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
  );
}
