import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/form_factor.dart';
import 'core/i18n.dart';
import 'core/storage.dart';
import 'core/theme.dart';
import 'core/tokens.dart';
import 'features/chat/chat_page.dart';
import 'features/connect/connect_page.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LocalStore.open();
  await DeviceInfo.probe();
  runApp(ProviderScope(overrides: [storeProvider.overrideWithValue(store)], child: const RofuApp()));
}

class RofuApp extends ConsumerWidget {
  const RofuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(appearanceProvider);
    final status = ref.watch(appProvider.select((s) => s.status));
    final Widget home = switch (status) {
      AppStatus.loading => const _Splash(),
      AppStatus.connect => const ConnectPage(),
      AppStatus.login => const LoginPage(),
      AppStatus.ready => const ChatPage(),
    };
    // Dynamic colour (Android 12+ wallpaper palette, desktop accent) when the user chose it;
    // otherwise, or when the platform has none, the seeded scheme.
    return DynamicColorBuilder(
      builder: (light, dark) => DeviceShape(
        setting: a.deviceShape,
        child: MaterialApp(
          title: 'RofuChat',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(a, Brightness.light, platform: light),
          darkTheme: buildTheme(a, Brightness.dark, platform: dark),
          themeMode: a.mode,
          locale: a.language.isEmpty ? null : Locale(a.language),
          // English first: an unsupported system language falls back to English, matching t().
          supportedLocales: const [Locale('en'), Locale('zh')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          scrollBehavior: AppScrollBehavior(),
          // The platform TextScaler is kept as is (it may be nonlinear); watches get a smaller
          // base type scale through the theme instead.
          builder: (context, child) => context.isWatch ? Theme(data: watchTheme(Theme.of(context)), child: child!) : child!,
          home: AnimatedSwitcher(
            duration: Motion.medium2,
            switchInCurve: Motion.emphasizedDecelerate,
            switchOutCurve: Motion.emphasizedAccelerate,
            child: KeyedSubtree(key: ValueKey('$status${I18n.isZh}'), child: home),
          ),
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: CircularProgressIndicator(semanticsLabel: t('正在加载', 'Loading'))),
  );
}
