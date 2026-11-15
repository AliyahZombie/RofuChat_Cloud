import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/i18n.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

/// Root-only user management (backend-spec §6.2).
class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});
  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  List<User>? _users;
  bool? _allowRegister;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(apiProvider);
      final users = await api.list('/api/admin/users', User.new);
      final cfg = await api.get('/api/admin/config') as Map;
      setState(() {
        _users = users;
        _allowRegister = cfg['allow_register'] == true;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  Future<void> _create() async {
    final u = TextEditingController();
    final p = TextEditingController();
    String? uErr, pErr;
    final ok = await showEditorDialog(
      context,
      title: t('新建用户', 'New user'),
      ok: t('创建', 'Create'),
      validate: () {
        uErr = u.text.trim().isEmpty ? t('请填写用户名', 'Username is required') : null;
        pErr = p.text.isEmpty ? t('请填写密码', 'Password is required') : null;
        return uErr == null && pErr == null;
      },
      body: (c, set) => Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: u, autofocus: true, decoration: InputDecoration(labelText: t('用户名', 'Username'), errorText: uErr)),
        const SizedBox(height: 16),
        TextField(controller: p, obscureText: true, decoration: InputDecoration(labelText: t('密码', 'Password'), errorText: pErr)),
      ]),
    );
    if (!ok) return;
    try {
      await ref.read(apiProvider).post('/api/admin/users', {'username': u.text.trim(), 'password': p.text});
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _userAction(User u, String v) async {
    final api = ref.read(apiProvider);
    try {
      if (v == 'pw') {
        final p = await promptText(context, t('重置 ${u.username} 的密码', 'Reset password for ${u.username}'), label: t('新密码', 'New password'), ok: t('重置密码', 'Reset password'));
        if (p != null && p.isNotEmpty) await api.post('/api/admin/users/${u.id}/password', {'password': p});
      } else if (v == 'del' && mounted && await confirm(context, t('删除用户 ${u.username} 及其全部数据？', 'Delete ${u.username} and all their data?'), ok: t('删除', 'Delete'))) {
        await api.delete('/api/admin/users/${u.id}');
        await _load();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = _users;
    return Scaffold(
      appBar: AppBar(title: Text(t('用户管理', 'User management'))),
      floatingActionButton: FloatingActionButton(tooltip: t('新建用户', 'New user'), onPressed: _create, child: const Icon(Icons.person_add_alt)),
      body: _error != null
          ? Center(child: Text(_error!))
          : users == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(children: [
                  SwitchListTile(
                    title: Text(t('允许注册', 'Allow registration')),
                    subtitle: Text(t('关闭时只有 root 可以创建用户', 'When off, only root can create users')),
                    value: _allowRegister ?? false,
                    onChanged: (v) async {
                      try {
                        await ref.read(apiProvider).put('/api/admin/config', {'allow_register': v});
                        setState(() => _allowRegister = v);
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      }
                    },
                  ),
                  const Divider(),
                  for (final u in users)
                    ListTile(
                      leading: Icon(u.isRoot ? Icons.shield_outlined : Icons.person_outline),
                      title: Text(u.username),
                      subtitle: Text(fmtTime(u.createdAt)),
                      trailing: OverflowMenu(
                        tooltip: t('${u.username} 的操作', 'Actions for ${u.username}'),
                        entries: [
                          MenuEntry(t('重置密码', 'Reset password'), icon: Icons.password_rounded, onPressed: () => _userAction(u, 'pw')),
                          if (!u.isRoot) MenuEntry(t('删除', 'Delete'), icon: Icons.delete_outline, danger: true, onPressed: () => _userAction(u, 'del')),
                        ],
                      ),
                    ),
                ]),
    );
  }
}
