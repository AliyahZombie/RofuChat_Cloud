import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local preferences + secrets. Secrets fall back to SharedPreferences when the platform
/// keystore is unavailable (e.g. Linux without libsecret).
class LocalStore {
  LocalStore._(this.prefs);
  final SharedPreferences prefs;
  static const _secure = FlutterSecureStorage();

  static Future<LocalStore> open() async => LocalStore._(await SharedPreferences.getInstance());

  Map<String, dynamic> getJson(String key) {
    final s = prefs.getString(key);
    if (s == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(s) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> setJson(String key, Map<String, dynamic> v) => prefs.setString(key, jsonEncode(v));

  Future<String?> secret(String key) async {
    try {
      final v = await _secure.read(key: key);
      if (v != null) return v;
    } catch (_) {}
    return prefs.getString('secret.$key');
  }

  Future<void> setSecret(String key, String? value) async {
    try {
      if (value == null) {
        await _secure.delete(key: key);
      } else {
        await _secure.write(key: key, value: value);
      }
      await prefs.remove('secret.$key');
      return;
    } catch (_) {}
    if (value == null) {
      await prefs.remove('secret.$key');
    } else {
      await prefs.setString('secret.$key', value);
    }
  }
}
