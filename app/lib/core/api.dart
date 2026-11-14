import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => message;
}

/// Thin client over the RofuChat HTTP API (docs/backend-spec.md §6).
class Api {
  final String baseUrl;
  String? token;
  final http.Client _http;
  void Function()? onUnauthorized;

  Api(String base, {this.token, http.Client? client})
      : baseUrl = base.replaceAll(RegExp(r'/+$'), ''),
        _http = client ?? http.Client();

  Uri uri(String path, [Map<String, String>? q]) {
    final u = Uri.parse('$baseUrl$path');
    return q == null ? u : u.replace(queryParameters: {...u.queryParameters, ...q});
  }

  /// URL usable directly in Image.network (adds ?token=).
  String authedUrl(String path) {
    if (path.startsWith('data:') || path.startsWith('http')) return path;
    return uri(path, {'token': ?token}).toString();
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': ?(token == null ? null : 'Bearer $token'),
      };

  Future<dynamic> _send(String method, String path, {Object? body, Map<String, String>? query}) async {
    final req = http.Request(method, uri(path, query))..headers.addAll(_headers);
    if (body != null) req.body = jsonEncode(body);
    final res = await http.Response.fromStream(await _http.send(req).timeout(const Duration(seconds: 120)));
    final text = utf8.decode(res.bodyBytes);
    if (res.statusCode == 401) onUnauthorized?.call();
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'HTTP ${res.statusCode}';
      try {
        final j = jsonDecode(text);
        if (j is Map && j['error'] != null) msg = j['error'].toString();
      } catch (_) {
        if (text.isNotEmpty) msg = '$msg: ${text.length > 300 ? text.substring(0, 300) : text}';
      }
      throw ApiException(res.statusCode, msg);
    }
    if (text.isEmpty) return null;
    return jsonDecode(text);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) => _send('GET', path, query: query);
  Future<dynamic> post(String path, [Object? body]) => _send('POST', path, body: body ?? const {});
  Future<dynamic> put(String path, Object body) => _send('PUT', path, body: body);
  Future<dynamic> patch(String path, Object body) => _send('PATCH', path, body: body);
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<List<int>> getBytes(String path, {Map<String, String>? query}) async {
    final res = await _http.get(uri(path, query), headers: _headers);
    if (res.statusCode != 200) throw ApiException(res.statusCode, 'HTTP ${res.statusCode}');
    return res.bodyBytes;
  }

  // ---- typed helpers
  Future<Json> health() async => Map<String, dynamic>.from(await get('/api/health') as Map);

  Future<(String, User)> login(String username, String password, {bool register = false}) async {
    final j = await post(register ? '/api/auth/register' : '/api/auth/login', {'username': username, 'password': password}) as Map;
    return (j['token'] as String, User(Map<String, dynamic>.from(j['user'] as Map)));
  }

  Future<List<T>> list<T>(String path, T Function(Json) f, {Map<String, String>? query}) async {
    final j = await get(path, query: query);
    return ((j as List?) ?? const []).map((e) => f(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// POST an SSE endpoint and yield decoded JSON events.
  Stream<Json> sse(String path, Object body) async* {
    final req = http.Request('POST', uri(path))
      ..headers.addAll({..._headers, 'Accept': 'text/event-stream'})
      ..body = jsonEncode(body);
    final res = await _http.send(req);
    if (res.statusCode != 200) {
      final text = await res.stream.bytesToString();
      String msg = 'HTTP ${res.statusCode}';
      try {
        final j = jsonDecode(text);
        if (j is Map && j['error'] != null) msg = j['error'].toString();
      } catch (_) {}
      if (res.statusCode == 401) onUnauthorized?.call();
      throw ApiException(res.statusCode, msg);
    }
    final lines = res.stream.transform(utf8.decoder).transform(const LineSplitter());
    final data = StringBuffer();
    await for (final line in lines) {
      if (line.isEmpty) {
        if (data.isNotEmpty) {
          final s = data.toString();
          data.clear();
          try {
            final j = jsonDecode(s);
            if (j is Map) yield Map<String, dynamic>.from(j);
          } catch (_) {}
        }
        continue;
      }
      if (line.startsWith(':')) continue;
      if (line.startsWith('data:')) {
        if (data.isNotEmpty) data.write('\n');
        data.write(line.substring(5).trimLeft());
      }
    }
    if (data.isNotEmpty) {
      try {
        final j = jsonDecode(data.toString());
        if (j is Map) yield Map<String, dynamic>.from(j);
      } catch (_) {}
    }
  }
}
