import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/form_factor.dart';
import '../../core/format.dart';
import '../../core/i18n.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../admin/admin_page.dart';
import '../chat/model_picker.dart';
import '../providers/providers_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final settings = ref.watch(settingsProvider);
    final models = ref.watch(modelsProvider).value ?? const <ModelCfg>[];
    final a = ref.watch(appearanceProvider);
    final watch = context.isWatch;
    String modelName(String id) => models.where((m) => m.id == id).firstOrNull?.name ?? t('未设置', 'Not set');
    final s = settings.value;

    Future<void> saveSettings(void Function(UserSettings) f) async {
      final cur = settings.value;
      if (cur == null) return;
      final next = UserSettings(Map<String, dynamic>.from(cur.json));
      f(next);
      try {
        await ref.read(settingsProvider.notifier).save(next);
      } catch (e) {
        if (context.mounted) showError(context, e);
      }
    }

    void setA(Appearance n) => ref.read(appearanceProvider.notifier).set(n);

    final children = <Widget>[
      SectionTitle(t('连接与账户', 'Connection & account')),
      ListTile(
        leading: Icon(app.active?.isLocal == true ? Icons.phone_android_rounded : Icons.cloud_outlined),
        title: Text(app.active?.isLocal == true ? t('本地后端', 'Local backend') : (app.active?.url ?? '')),
        subtitle: Text('${app.user?.username ?? ''}${app.user?.isRoot == true ? ' (root)' : ''}'),
        trailing: TextButton(onPressed: () {
          Navigator.of(context).popUntil((r) => r.isFirst);
          ref.read(appProvider.notifier).showConnect();
        }, child: Text(t('切换', 'Switch'))),
      ),
      if (!watch && app.active?.isLocal != true)
        ListTile(leading: const Icon(Icons.password_rounded), title: Text(t('修改密码', 'Change password')), onTap: () => _changePassword(context, ref)),
      if (!watch && app.user?.isRoot == true)
        ListTile(
          leading: const Icon(Icons.admin_panel_settings_outlined),
          title: Text(t('用户管理', 'User management')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPage())),
        ),
      if (app.active?.isLocal != true)
        ListTile(leading: const Icon(Icons.logout), title: Text(t('退出登录', 'Sign out')), onTap: () async {
          Navigator.of(context).popUntil((r) => r.isFirst);
          await ref.read(appProvider.notifier).logout();
        }),
      SectionTitle(t('模型', 'Models')),
      if (!watch)
        ListTile(
          leading: const Icon(Icons.hub_outlined),
          title: Text(t('模型供应商', 'Model providers')),
          subtitle: Text(t('${(ref.watch(providersProvider).value ?? const []).length} 个供应商 · ${models.length} 个模型', '${(ref.watch(providersProvider).value ?? const []).length} providers · ${models.length} models')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProvidersPage())),
        ),
      ListTile(
        leading: const Icon(Icons.star_outline_rounded),
        title: Text(t('默认模型', 'Default model')),
        subtitle: Text(s == null ? '…' : modelName(s.defaultModelId)),
        onTap: s == null
            ? null
            : () async {
                final id = await showModelPicker(context, ref, selected: s.defaultModelId, title: t('默认模型', 'Default model'));
                if (id != null) await saveSettings((x) => x.defaultModelId = id);
              },
      ),
      ListTile(
        leading: const Icon(Icons.bolt_rounded),
        title: const Text('Fast model'),
        subtitle: Text(s == null ? '…' : '${modelName(s.fastModelId)} · ${t('用于标题、压缩、记忆整理', 'titles, compression, memory')}'),
        onTap: s == null
            ? null
            : () async {
                final id = await showModelPicker(context, ref, selected: s.fastModelId, title: 'Fast model');
                if (id != null) await saveSettings((x) => x.fastModelId = id);
              },
      ),
      if (!watch && s != null) ...[
        SectionTitle(t('个人', 'Personal')),
        ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: Text(t('你的名字（{{user}}）', 'Your name ({{user}})')),
          subtitle: Text(s.userName),
          onTap: () async {
            final v = await promptText(context, t('你的名字', 'Your name'), initial: s.userName);
            if (v != null) await saveSettings((x) => x.userName = v.trim().isEmpty ? 'User' : v.trim());
          },
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(t('你的人设（persona）', 'Your persona')),
          subtitle: Text(s.userPersona.isEmpty ? t('未填写', 'Empty') : s.userPersona, maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () async {
            final v = await promptText(context, t('你的人设', 'Your persona'), initial: s.userPersona, maxLines: 8);
            if (v != null) await saveSettings((x) => x.userPersona = v);
          },
        ),
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: Text(t('记忆整理：空闲分钟数', 'Memory extraction: idle minutes')),
          subtitle: Text('${s.memoryIdleMinutes}'),
          onTap: () async {
            final v = await promptText(context, t('空闲多少分钟后整理记忆', 'Idle minutes before extraction'), initial: '${s.memoryIdleMinutes}');
            final n = int.tryParse(v ?? '');
            if (n != null && n > 0) await saveSettings((x) => x.memoryIdleMinutes = n);
          },
        ),
      ],
      SectionTitle(t('外观', 'Appearance')),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: SegmentedButton<String>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 'system', label: Text(t('系统', 'System'))),
            ButtonSegment(value: 'light', label: Text(t('浅色', 'Light'))),
            ButtonSegment(value: 'dark', label: Text(t('深色', 'Dark'))),
            ButtonSegment(value: 'black', label: Text(t('纯黑', 'Black'))),
          ],
          selected: {a.themeMode},
          onSelectionChanged: (v) => setA(a.copyWith(themeMode: v.first)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          for (final (zh, en, color) in seedPresets)
            Tooltip(
              message: t(zh, en),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setA(a.copyWith(seed: color)),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(color),
                  child: a.seed == color ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                ),
              ),
            ),
        ]),
      ),
      ListTile(
        title: Text(t('字体大小', 'Font size')),
        subtitle: Slider(value: a.fontScale, min: 0.8, max: 1.4, divisions: 12, label: a.fontScale.toStringAsFixed(2), onChanged: (v) => setA(a.copyWith(fontScale: v))),
      ),
      SwitchListTile(title: Text(t('紧凑布局', 'Compact layout')), value: a.compact, onChanged: (v) => setA(a.copyWith(compact: v))),
      if (!watch) SwitchListTile(title: Text(t('聊天铺满宽度（桌面）', 'Full-width chat (desktop)')), value: a.fullWidth, onChanged: (v) => setA(a.copyWith(fullWidth: v))),
      _LoadCharsTile(value: a.loadChars, onChanged: (v) => setA(a.copyWith(loadChars: v))),
      if (!watch && !context.isDesktop) _SwipeZoneTile(value: a.swipeZone, onChanged: (v) => setA(a.copyWith(swipeZone: v))),
      SwitchListTile(title: Text(t('显示头像', 'Show avatars')), value: a.showAvatars, onChanged: (v) => setA(a.copyWith(showAvatars: v))),
      SwitchListTile(title: Text(t('显示 Token 用量', 'Show token usage')), value: a.showTokens, onChanged: (v) => setA(a.copyWith(showTokens: v))),
      if (!watch) SwitchListTile(title: Text(t('Enter 发送（Shift+Enter 换行）', 'Enter to send (Shift+Enter newline)')), value: a.enterToSend, onChanged: (v) => setA(a.copyWith(enterToSend: v))),
      ListTile(
        title: Text(t('语言', 'Language')),
        trailing: DropdownButton<String>(
          value: a.language,
          items: [
            DropdownMenuItem(value: '', child: Text(t('跟随系统', 'System'))),
            const DropdownMenuItem(value: 'zh', child: Text('中文')),
            const DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (v) => setA(a.copyWith(language: v ?? '')),
        ),
      ),
      SectionTitle(t('关于', 'About')),
      ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('RofuChat'),
        subtitle: Text(t('Agent-Native 角色扮演引擎', 'Agent-native roleplay engine')),
        onTap: () => showLicensePage(context: context, applicationName: 'RofuChat'),
      ),
      const SizedBox(height: 24),
    ];

    return Scaffold(
      appBar: watch ? null : AppBar(title: Text(t('设置', 'Settings'))),
      body: ListView(padding: EdgeInsets.symmetric(horizontal: watch ? watchInset(context) * 0.6 : 0), children: children),
    );
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final old = TextEditingController();
    final nw = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t('修改密码', 'Change password')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: old, obscureText: true, decoration: InputDecoration(labelText: t('当前密码', 'Current password'))),
          const SizedBox(height: 8),
          TextField(controller: nw, obscureText: true, decoration: InputDecoration(labelText: t('新密码', 'New password'))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('取消', 'Cancel'))),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t('确定', 'OK'))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(apiProvider).post('/api/auth/password', {'old_password': old.text, 'new_password': nw.text});
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('密码已修改', 'Password changed'))));
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}


/// History loaded per page (opening a chat, then each scroll to the top), in characters.
class _LoadCharsTile extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _LoadCharsTile({required this.value, required this.onChanged});

  static const steps = [1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000];

  @override
  Widget build(BuildContext context) {
    var i = steps.indexWhere((s) => s >= value);
    if (i < 0) i = steps.length - 1;
    return ListTile(
      title: Text(t('每次加载历史', 'History per load')),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t('${fmtCount(value)} 字，预估约 ${fmtBytes(estimateHistoryBytes(value))}；至少加载一轮对话',
            '${fmtCount(value)} chars, about ${fmtBytes(estimateHistoryBytes(value))}; at least one exchange')),
        Slider(
          value: i.toDouble(),
          min: 0,
          max: (steps.length - 1).toDouble(),
          divisions: steps.length - 1,
          label: fmtCount(steps[i]),
          onChanged: (v) => onChanged(steps[v.round()]),
        ),
      ]),
    );
  }
}

/// Ten-step slider for where a rightward swipe may start to open the sidebar,
/// with a strip preview of the active zone.
class _SwipeZoneTile extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _SwipeZoneTile({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = value * 10;
    return ListTile(
      title: Text(t('侧滑手势区域', 'Sidebar swipe area')),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value == 10
            ? t('从屏幕任意位置右滑打开侧栏', 'Swipe right from anywhere to open the sidebar')
            : t('从屏幕左侧 $pct% 内右滑打开侧栏', 'Swipe right within the left $pct% to open the sidebar')),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(children: [
              Positioned.fill(child: ColoredBox(color: scheme.surfaceContainerHighest)),
              TweenAnimationBuilder<double>(
                tween: Tween(end: value / 10),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                builder: (_, f, _) => FractionallySizedBox(widthFactor: f, child: ColoredBox(color: scheme.primary.withValues(alpha: 0.5))),
              ),
            ]),
          ),
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '$pct%',
          onChanged: (v) => onChanged(v.round()),
        ),
      ]),
    );
  }
}
