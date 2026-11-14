import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

typedef _StartC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _StopC = Int32 Function();
typedef _StopD = int Function();
typedef _FreeC = Void Function(Pointer<Utf8>);
typedef _FreeD = void Function(Pointer<Utf8>);

/// The Rust backend (`rofu_ffi`) running inside the app process.
class EmbeddedBackend {
  static int? _port;

  static bool get supported => Platform.isAndroid || Platform.isLinux || Platform.isWindows || Platform.isMacOS || Platform.isIOS;

  static DynamicLibrary _open() {
    if (Platform.isWindows) return DynamicLibrary.open('rofu_ffi.dll');
    if (Platform.isMacOS) return DynamicLibrary.open('librofu_ffi.dylib');
    if (Platform.isIOS) return DynamicLibrary.process();
    return DynamicLibrary.open('librofu_ffi.so');
  }

  /// Starts the backend (idempotent) and returns its localhost port.
  static Future<int> start({required String dataDir, required String rootPassword}) async {
    if (_port != null) return _port!;
    final cfg = jsonEncode({'data_dir': dataDir, 'root_password': rootPassword, 'listen': '127.0.0.1:0'});
    final res = await Isolate.run(() {
      final lib = _open();
      final start = lib.lookupFunction<_StartC, _StartC>('rofu_start');
      final free = lib.lookupFunction<_FreeC, _FreeD>('rofu_free_string');
      final arg = cfg.toNativeUtf8();
      try {
        final out = start(arg);
        final s = out.toDartString();
        free(out);
        return s;
      } finally {
        malloc.free(arg);
      }
    });
    final j = jsonDecode(res) as Map;
    if (j['ok'] != true) throw Exception(j['error'] ?? 'failed to start embedded backend');
    _port = (j['port'] as num).toInt();
    return _port!;
  }

  static Future<void> stop() async {
    if (_port == null) return;
    _open().lookupFunction<_StopC, _StopD>('rofu_stop')();
    _port = null;
  }
}
