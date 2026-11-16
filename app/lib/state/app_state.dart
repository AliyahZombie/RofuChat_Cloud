import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../core/api.dart';
import '../core/backend_ffi.dart';
import '../core/i18n.dart';
import '../core/builtin_tools.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../models/models.dart';

/// Overridden in main() with an opened store.
final storeProvider = Provider<LocalStore>((ref) => throw UnimplementedError());

// ---------------------------------------------------------------- appearance

class AppearanceCtl extends Notifier<Appearance> {
  @override
  Appearance build() {
    final a = Appearance.fromJson(ref.read(storeProvider).getJson('appearance'));
    I18n.override = a.language;
    return a;
  }

  void set(Appearance a) {
    state = a;
    I18n.override = a.language;
    ref.read(storeProvider).setJson('appearance', a.toJson());
    // Sync to the server's client settings, best effort.
    final app = ref.read(appProvider);
    if (app.status == AppStatus.ready) {
      unawaited(ref.read(settingsProvider.notifier).patchClient({'appearance': a.toJson()}).catchError((_) {}));
    }
  }
}

final appearanceProvider = NotifierProvider<AppearanceCtl, Appearance>(AppearanceCtl.new);

// ---------------------------------------------------------------- connections

class ConnectionCfg {
  final String id;
  final String name;
  final String kind; // local | remote
  final String url;
  final String username;
  const ConnectionCfg({required this.id, required this.name, required this.kind, this.url = '', this.username = ''});
  bool get isLocal => kind == 'local';
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'kind': kind, 'url': url, 'username': username};
  factory ConnectionCfg.fromJson(Map<String, dynamic> j) => ConnectionCfg(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        kind: j['kind'] as String? ?? 'remote',
        url: j['url'] as String? ?? '',
        username: j['username'] as String? ?? '',
      );
  ConnectionCfg copyWith({String? username, String? name}) =>
      ConnectionCfg(id: id, name: name ?? this.name, kind: kind, url: url, username: username ?? this.username);
}

enum AppStatus { loading, connect, login, ready }

class AppState {
  final AppStatus status;
  final List<ConnectionCfg> connections;
  final ConnectionCfg? active;
  final Api? api;
  final User? user;
  final bool allowRegister;
  final String? error;
  const AppState({this.status = AppStatus.loading, this.connections = const [], this.active, this.api, this.user, this.allowRegister = false, this.error});

  AppState copyWith({AppStatus? status, List<ConnectionCfg>? connections, ConnectionCfg? active, Api? api, User? user, bool? allowRegister, String? error, bool clearError = false, bool clearUser = false}) => AppState(
        status: status ?? this.status,
        connections: connections ?? this.connections,
        active: active ?? this.active,
        api: api ?? this.api,
        user: clearUser ? null : (user ?? this.user),
        allowRegister: allowRegister ?? this.allowRegister,
        error: clearError ? null : (error ?? this.error),
      );
}

String _randomSecret(int n) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
  final r = Random.secure();
  return List.generate(n, (_) => chars[r.nextInt(chars.length)]).join();
}

class AppCtl extends Notifier<AppState> {
  LocalStore get _store => ref.read(storeProvider);

  @override
  AppState build() {
    Future.microtask(init);
    return const AppState();
  }

  List<ConnectionCfg> _loadConnections() {
    final j = _store.getJson('connections');
    return ((j['list'] as List?) ?? const []).map((e) => ConnectionCfg.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> _saveConnections(List<ConnectionCfg> list, String? activeId) =>
      _store.setJson('connections', {'list': list.map((e) => e.toJson()).toList(), 'active': activeId});

  Future<void> init() async {
    final list = _loadConnections();
    final activeId = _store.getJson('connections')['active'] as String?;
    final active = list.where((c) => c.id == activeId).firstOrNull;
    state = AppState(status: AppStatus.loading, connections: list);
    if (active == null) {
      state = state.copyWith(status: AppStatus.connect);
      return;
    }
    await activate(active);
  }

  Api _newApi(String url, String? token) {
    final api = Api(url, token: token);
    api.onUnauthorized = () {
      if (state.status == AppStatus.ready && !(state.active?.isLocal ?? false)) {
        state = state.copyWith(status: AppStatus.login, error: t('登录已失效，请重新登录', 'Session expired, please sign in again'));
      }
    };
    return api;
  }

  /// Connect to a saved connection.
  Future<void> activate(ConnectionCfg c) async {
    state = state.copyWith(status: AppStatus.loading, active: c, clearError: true, clearUser: true);
    try {
      if (c.isLocal) {
        await _startLocal(c);
        return;
      }
      final token = await _store.secret('token.${c.id}');
      final api = _newApi(c.url, token);
      final health = await api.health();
      state = state.copyWith(api: api, allowRegister: health['allow_register'] == true);
      if (token != null) {
        try {
          final me = User(Map<String, dynamic>.from(await api.get('/api/auth/me') as Map));
          await _saveConnections(state.connections, c.id);
          state = state.copyWith(status: AppStatus.ready, user: me);
          _afterLogin();
          return;
        } catch (_) {}
      }
      state = state.copyWith(status: AppStatus.login);
    } catch (e) {
      state = state.copyWith(status: AppStatus.connect, error: '$e');
    }
  }

  Future<void> _startLocal(ConnectionCfg c) async {
    final dir = await getApplicationSupportDirectory();
    var pw = await _store.secret('local_root_password');
    if (pw == null) {
      pw = _randomSecret(32);
      await _store.setSecret('local_root_password', pw);
    }
    final port = await EmbeddedBackend.start(dataDir: '${dir.path}/rofu', rootPassword: pw);
    final api = _newApi('http://127.0.0.1:$port', null);
    final (token, user) = await api.login('root', pw);
    api.token = token;
    await _saveConnections(state.connections, c.id);
    state = state.copyWith(status: AppStatus.ready, api: api, user: user);
    _afterLogin();
  }

  Future<void> useLocal() async {
    var list = state.connections;
    var local = list.where((c) => c.isLocal).firstOrNull;
    if (local == null) {
      local = ConnectionCfg(id: 'local', name: t('本地', 'Local'), kind: 'local', username: 'root');
      list = [local, ...list];
      state = state.copyWith(connections: list);
      await _saveConnections(list, local.id);
    }
    await activate(local);
  }

  /// Validate a server URL and prepare for login.
  Future<void> addRemote(String url) async {
    var u = url.trim();
    if (!u.startsWith('http://') && !u.startsWith('https://')) u = 'https://$u';
    u = u.replaceAll(RegExp(r'/+$'), '');
    state = state.copyWith(status: AppStatus.loading, clearError: true);
    try {
      final api = _newApi(u, null);
      final health = await api.health();
      var list = state.connections;
      var c = list.where((x) => x.url == u).firstOrNull;
      if (c == null) {
        c = ConnectionCfg(id: _randomSecret(10), name: Uri.parse(u).host, kind: 'remote', url: u);
        list = [...list, c];
        await _saveConnections(list, c.id);
      }
      state = state.copyWith(status: AppStatus.login, connections: list, active: c, api: api, allowRegister: health['allow_register'] == true);
    } catch (e) {
      state = state.copyWith(status: AppStatus.connect, error: t('无法连接：$e', 'Cannot connect: $e'));
    }
  }

  Future<void> login(String username, String password, {bool register = false}) async {
    final api = state.api;
    final c = state.active;
    if (api == null || c == null) return;
    state = state.copyWith(clearError: true);
    try {
      final (token, user) = await api.login(username, password, register: register);
      api.token = token;
      await _store.setSecret('token.${c.id}', token);
      final updated = c.copyWith(username: username);
      final list = state.connections.map((x) => x.id == c.id ? updated : x).toList();
      await _saveConnections(list, c.id);
      state = state.copyWith(status: AppStatus.ready, user: user, connections: list, active: updated);
      _afterLogin();
    } catch (e) {
      state = state.copyWith(error: '$e');
    }
  }

  Future<void> logout() async {
    final c = state.active;
    try {
      await state.api?.post('/api/auth/logout');
    } catch (_) {}
    if (c != null) await _store.setSecret('token.${c.id}', null);
    state.api?.token = null;
    state = state.copyWith(status: c?.isLocal == true ? AppStatus.connect : AppStatus.login, clearUser: true);
  }

  void showConnect() => state = state.copyWith(status: AppStatus.connect, clearError: true);

  Future<void> removeConnection(ConnectionCfg c) async {
    final list = state.connections.where((x) => x.id != c.id).toList();
    await _store.setSecret('token.${c.id}', null);
    await _saveConnections(list, state.active?.id == c.id ? null : state.active?.id);
    state = state.copyWith(connections: list);
  }

  void _afterLogin() {
    // Pull synced appearance from the server if this device has none yet.
    Future.microtask(() async {
      try {
        final s = await ref.read(settingsProvider.future);
        final a = s.client['appearance'];
        if (a is Map && _store.prefs.getString('appearance') == null) {
          ref.read(appearanceProvider.notifier).set(Appearance.fromJson(Map<String, dynamic>.from(a)));
        }
      } catch (e) {
        debugPrint('settings sync: $e');
      }
    });
  }
}

final appProvider = NotifierProvider<AppCtl, AppState>(AppCtl.new);

/// The API of the active, signed-in connection.
final apiProvider = Provider<Api>((ref) {
  final api = ref.watch(appProvider.select((s) => s.api));
  final user = ref.watch(appProvider.select((s) => s.user));
  if (api == null || user == null) throw StateError('not connected');
  return api;
});

// ---------------------------------------------------------------- server data

abstract class ListCtl<T extends JsonModel> extends AsyncNotifier<List<T>> {
  String get path;
  T make(Json j);

  /// Extra query for the list request (e.g. the tools' code-less summary).
  Map<String, String>? get listQuery => null;

  @override
  Future<List<T>> build() async {
    final api = ref.watch(apiProvider);
    return api.list(path, make, query: listQuery);
  }

  Future<void> refresh() async {
    state = AsyncData(await ref.read(apiProvider).list(path, make, query: listQuery));
  }

  Future<T> save(T item) async {
    final api = ref.read(apiProvider);
    final j = item.id.isEmpty ? await api.post(path, item.toJson()) : await api.put('$path/${item.id}', item.toJson());
    final saved = make(Map<String, dynamic>.from(j as Map));
    await refresh();
    return saved;
  }

  Future<void> remove(String id) async {
    await ref.read(apiProvider).delete('$path/$id');
    await refresh();
  }

  T? byId(String id) => state.value?.where((e) => e.id == id).firstOrNull;
}

class CharactersCtl extends ListCtl<Character> {
  @override
  String get path => '/api/characters';
  @override
  Character make(Json j) => Character(j);

  Future<Character> import(Map<String, dynamic> body) async {
    final j = await ref.read(apiProvider).post('/api/characters/import', body);
    var c = Character(Map<String, dynamic>.from(j as Map));
    // Imported characters get the built-in tools (the dice roller) switched on too.
    try {
      final ids = await builtinToolIds();
      if (ids.any((id) => !c.toolIds.contains(id))) {
        c.toolIds = {...c.toolIds, ...ids}.toList();
        c = await save(c);
      }
    } catch (_) {}
    await refresh();
    return c;
  }

  /// Ids of the enabled built-in tools, waiting for the tool list (and its first-time seeding).
  Future<List<String>> builtinToolIds() async {
    final tools = await ref.read(toolsProvider.future);
    return [for (final tool in tools) if (builtinToolNames.contains(tool.name) && tool.enabled) tool.id];
  }

  Future<void> reorder(List<String> ids) async {
    await ref.read(apiProvider).put('/api/characters/order', ids);
    await refresh();
  }
}

class ProvidersCtl extends ListCtl<ProviderCfg> {
  @override
  String get path => '/api/providers';
  @override
  ProviderCfg make(Json j) => ProviderCfg(j);
}

class ModelsCtl extends ListCtl<ModelCfg> {
  @override
  String get path => '/api/models';
  @override
  ModelCfg make(Json j) => ModelCfg(j);

  Future<void> addMany(List<ModelCfg> models) async {
    await ref.read(apiProvider).post(path, models.map((m) => m.toJson()).toList());
    await refresh();
  }
}

class ToolsCtl extends ListCtl<LocalTool> {
  @override
  String get path => '/api/tools';
  @override
  LocalTool make(Json j) => LocalTool(j);

  /// List without code (older servers ignore it and send full tools); the editor fetches
  /// the full tool, and a PUT without `code` keeps the stored code.
  @override
  Map<String, String>? get listQuery => const {'summary': '1'};

  @override
  Future<List<LocalTool>> build() async {
    final list = await super.build();
    try {
      final added = await _addBuiltins(list, onlyFirstTime: true);
      if (added) return await ref.read(apiProvider).list(path, make, query: listQuery);
    } catch (_) {}
    return list;
  }

  String _seedKey() {
    final app = ref.read(appProvider);
    return 'builtin_tools_seeded.${app.active?.id ?? ''}.${app.user?.id ?? ''}';
  }

  /// Creates built-in tools that are missing. With [onlyFirstTime], each one is created at most
  /// once per connection and user, so a tool the user deleted stays deleted.
  Future<bool> _addBuiltins(List<LocalTool> list, {required bool onlyFirstTime}) async {
    final store = ref.read(storeProvider);
    final seeded = Set<String>.from((store.getJson(_seedKey())['names'] as List?) ?? const []);
    final have = {for (final t in list) t.name};
    final toAdd = [for (final b in builtinTools) if (!have.contains(b.name) && !(onlyFirstTime && seeded.contains(b.name))) b];
    // Mark first, so two concurrent loads cannot both create the tool.
    await store.setJson(_seedKey(), {'names': {...seeded, ...builtinToolNames}.toList()});
    for (final b in toAdd) {
      await ref.read(apiProvider).post(path, await b.toToolJson());
    }
    final added = toAdd.isNotEmpty;
    return added;
  }

  /// Re-adds any built-in tool the user deleted.
  Future<void> restoreBuiltins() async {
    await _addBuiltins(state.value ?? const [], onlyFirstTime: false);
    await refresh();
  }
}

class PluginsCtl extends ListCtl<Plugin> {
  @override
  String get path => '/api/plugins';
  @override
  Plugin make(Json j) => Plugin(j);

  @override
  Future<List<Plugin>> build() async {
    try {
      return await super.build();
    } on ApiException catch (e) {
      // Servers before schema 3 have no plugin routes.
      if (e.status == 404) return const [];
      rethrow;
    }
  }

  Future<Plugin> full(String id) async => Plugin(Map<String, dynamic>.from(await ref.read(apiProvider).get('$path/$id') as Map));

  /// Grants the declared permissions (enabled) or clears the grants (disabled).
  Future<Plugin> setEnabled(String id, bool enabled) async {
    final j = await ref.read(apiProvider).post('$path/$id/enable', {'enabled': enabled});
    await refresh();
    ref.invalidate(pluginMenusProvider);
    return Plugin(Map<String, dynamic>.from(j as Map));
  }
}

final charactersProvider = AsyncNotifierProvider<CharactersCtl, List<Character>>(CharactersCtl.new);
final providersProvider = AsyncNotifierProvider<ProvidersCtl, List<ProviderCfg>>(ProvidersCtl.new);
final modelsProvider = AsyncNotifierProvider<ModelsCtl, List<ModelCfg>>(ModelsCtl.new);
final toolsProvider = AsyncNotifierProvider<ToolsCtl, List<LocalTool>>(ToolsCtl.new);
final pluginsProvider = AsyncNotifierProvider<PluginsCtl, List<Plugin>>(PluginsCtl.new);

/// Composer + menu entries registered by the plugins enabled for a conversation.
final pluginMenusProvider = FutureProvider.family<List<PluginMenu>, String>((ref, conversationId) async {
  if (conversationId.isEmpty) return const [];
  try {
    return await ref.watch(apiProvider).list('/api/conversations/$conversationId/plugin_menus', PluginMenu.new);
  } catch (_) {
    return const [];
  }
});

class SettingsCtl extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    final api = ref.watch(apiProvider);
    return UserSettings(Map<String, dynamic>.from(await api.get('/api/settings') as Map));
  }

  Future<void> save(UserSettings s) async {
    final j = await ref.read(apiProvider).put('/api/settings', s.json);
    state = AsyncData(UserSettings(Map<String, dynamic>.from((j ?? s.json) as Map)));
  }

  Future<void> patchClient(Map<String, dynamic> patch) async {
    final cur = await future;
    final s = UserSettings(jsonDecode(jsonEncode(cur.json)) as Map<String, dynamic>);
    s.client.addAll(patch);
    await save(s);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsCtl, UserSettings>(SettingsCtl.new);

// ---------------------------------------------------------------- selection

class SelectedCharacterCtl extends Notifier<String?> {
  String get _key => 'selected_character.${ref.read(appProvider).active?.id ?? ''}';
  @override
  String? build() {
    ref.watch(appProvider.select((s) => s.active?.id));
    return ref.read(storeProvider).prefs.getString(_key);
  }

  void select(String? id) {
    state = id;
    final p = ref.read(storeProvider).prefs;
    if (id == null) {
      p.remove(_key);
    } else {
      p.setString(_key, id);
    }
  }
}

final selectedCharacterIdProvider = NotifierProvider<SelectedCharacterCtl, String?>(SelectedCharacterCtl.new);

/// The current character: the selected one, else the first.
final currentCharacterProvider = Provider<Character?>((ref) {
  final list = ref.watch(charactersProvider).value ?? const <Character>[];
  final id = ref.watch(selectedCharacterIdProvider);
  return list.where((c) => c.id == id).firstOrNull ?? list.firstOrNull;
});

final conversationsProvider = FutureProvider.family<List<Conversation>, String>((ref, characterId) async {
  final api = ref.watch(apiProvider);
  return api.list('/api/conversations', Conversation.new, query: {'character_id': characterId});
});

class SelectedConversationCtl extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(currentCharacterProvider.select((c) => c?.id));
    return null;
  }

  void select(String? id) => state = id;
}

final selectedConversationIdProvider = NotifierProvider<SelectedConversationCtl, String?>(SelectedConversationCtl.new);

/// The model used by a character (its own, else the user's default).
final characterModelProvider = Provider.family<ModelCfg?, String>((ref, modelId) {
  final models = ref.watch(modelsProvider).value ?? const <ModelCfg>[];
  var id = modelId;
  if (id.isEmpty) id = ref.watch(settingsProvider).value?.defaultModelId ?? '';
  return models.where((m) => m.id == id).firstOrNull;
});
