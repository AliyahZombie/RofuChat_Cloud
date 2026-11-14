/// Web: no embedded backend.
class EmbeddedBackend {
  static bool get supported => false;
  static Future<int> start({required String dataDir, required String rootPassword}) async =>
      throw UnsupportedError('Embedded backend is not available on this platform');
  static Future<void> stop() async {}
}
