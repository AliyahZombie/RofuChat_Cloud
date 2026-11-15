import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/backend_ffi.dart';
import '../../core/form_factor.dart';
import '../../core/i18n.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

/// Choose a backend: start the embedded one, or connect to a server (frontend-spec §2).
class ConnectPage extends ConsumerStatefulWidget {
  const ConnectPage({super.key});
  @override
  ConsumerState<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends ConsumerState<ConnectPage> {
  final _url = TextEditingController();
  String? _urlError;

  void _connect(AppCtl ctl) {
    if (_url.text.trim().isEmpty) {
      setState(() => _urlError = t('请填写服务器地址', 'Enter the server URL'));
      return;
    }
    setState(() => _urlError = null);
    ctl.addRemote(_url.text);
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appProvider);
    final ctl = ref.read(appProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final inset = context.isWatch ? watchInset(context) : 24.0;
    final remotes = app.connections.where((c) => !c.isLocal).toList();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(shrinkWrap: true, padding: EdgeInsets.all(inset), children: [
              Icon(Icons.auto_stories_rounded, size: context.isWatch ? 32 : 56, color: scheme.primary),
              const SizedBox(height: 8),
              Text('RofuChat', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              if (app.error != null)
                Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(app.error!, style: TextStyle(color: scheme.error), textAlign: TextAlign.center)),
              if (EmbeddedBackend.supported) ...[
                FilledButton.icon(
                  onPressed: ctl.useLocal,
                  icon: const Icon(Icons.phone_android_rounded),
                  label: Text(t('本地启动（推荐）', 'Run locally (recommended)')),
                ),
                if (!context.isWatch)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Text(t('数据保存在本机，内置后端随应用启动。', 'Data stays on this device; the built-in backend starts with the app.'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                  ),
                Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(t('或', 'or'))), const Expanded(child: Divider())]),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _url,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: t('服务器地址', 'Server URL'), hintText: 'https://rofu.example.com', prefixIcon: const Icon(Icons.dns_rounded), errorText: _urlError),
                onSubmitted: (_) => _connect(ctl),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(onPressed: () => _connect(ctl), child: Text(t('连接服务器', 'Connect'))),
              if (remotes.isNotEmpty) ...[
                SectionTitle(t('已保存的服务器', 'Saved servers')),
                for (final c in remotes)
                  ListTile(
                    leading: const Icon(Icons.cloud_rounded),
                    title: Text(c.name),
                    subtitle: Text('${c.username.isEmpty ? '' : '${c.username} @ '}${c.url}', maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => ctl.activate(c),
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: t('移除 ${c.name}', 'Remove ${c.name}'),
                      onPressed: () => ctl.removeConnection(c),
                    ),
                  ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final _user = TextEditingController(text: ref.read(appProvider).active?.username ?? '');
  final _pw = TextEditingController();
  bool _register = false;
  bool _busy = false;

  Future<void> _submit() async {
    setState(() => _busy = true);
    await ref.read(appProvider.notifier).login(_user.text.trim(), _pw.text, register: _register);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => ref.read(appProvider.notifier).showConnect()),
        title: Text(app.active?.name ?? ''),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(shrinkWrap: true, padding: EdgeInsets.all(context.isWatch ? watchInset(context) : 24), children: [
            Text(_register ? t('注册', 'Create account') : t('登录', 'Sign in'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (app.error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(app.error!, style: TextStyle(color: scheme.error))),
            TextField(controller: _user, autofillHints: const [AutofillHints.username], decoration: InputDecoration(labelText: t('用户名', 'Username'))),
            const SizedBox(height: 12),
            TextField(controller: _pw, obscureText: true, autofillHints: const [AutofillHints.password], decoration: InputDecoration(labelText: t('密码', 'Password')), onSubmitted: (_) => _submit()),
            const SizedBox(height: 16),
            FilledButton(onPressed: _busy ? null : _submit, child: Text(_register ? t('注册', 'Create account') : t('登录', 'Sign in'))),
            if (app.allowRegister)
              TextButton(onPressed: () => setState(() => _register = !_register), child: Text(_register ? t('已有账号？登录', 'Have an account? Sign in') : t('没有账号？注册', 'No account? Register'))),
          ]),
        ),
      ),
    );
  }
}
