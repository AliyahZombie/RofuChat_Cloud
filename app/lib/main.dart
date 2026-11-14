import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/i18n.dart';
import 'core/storage.dart';
import 'core/theme.dart';
import 'features/chat/chat_page.dart';
import 'features/connect/connect_page.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LocalStore.open();
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
    return MaterialApp(
      title: 'RofuChat',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(a, Brightness.light),
      darkTheme: buildTheme(a, Brightness.dark),
      themeMode: a.mode,
      locale: a.language.isEmpty ? null : Locale(a.language),
      scrollBehavior: AppScrollBehavior(),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // Watches get a smaller base text size.
        final watchScale = mq.size.shortestSide < 300 ? 0.85 : 1.0;
        return MediaQuery(data: mq.copyWith(textScaler: TextScaler.linear(mq.textScaler.scale(1) * watchScale)), child: child!);
      },
      home: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: KeyedSubtree(key: ValueKey('$status${I18n.isZh}'), child: home)),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
