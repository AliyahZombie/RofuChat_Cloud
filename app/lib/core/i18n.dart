import 'dart:ui' as ui;

/// Minimal bilingual helper: `t('中文', 'English')`.
/// Language follows the system unless overridden in appearance settings.
class I18n {
  static String? override; // 'zh' | 'en' | null
  static bool get isZh {
    final o = override;
    if (o != null && o.isNotEmpty) return o == 'zh';
    return ui.PlatformDispatcher.instance.locale.languageCode == 'zh';
  }
}

String t(String zh, String en) => I18n.isZh ? zh : en;
