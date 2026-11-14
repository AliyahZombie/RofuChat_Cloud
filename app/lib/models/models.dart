// Data classes mirroring the backend JSON (docs/backend-spec.md §4).
// Each wraps the raw JSON map so unknown fields survive a GET → PUT round trip.

typedef Json = Map<String, dynamic>;

Json _copy(Json j) => Map<String, dynamic>.from(j);

String _s(Json j, String k, [String d = '']) => (j[k] as String?) ?? d;
int _i(Json j, String k, [int d = 0]) => (j[k] as num?)?.toInt() ?? d;
bool _b(Json j, String k, [bool d = false]) => (j[k] as bool?) ?? d;
List<String> _ls(Json j, String k) => ((j[k] as List?) ?? const []).map((e) => e.toString()).toList();
Json _m(Json j, String k) {
  final v = j[k];
  if (v is Map) {
    final m = Map<String, dynamic>.from(v);
    j[k] = m;
    return m;
  }
  final m = <String, dynamic>{};
  j[k] = m;
  return m;
}

abstract class JsonModel {
  final Json json;
  JsonModel(Json j) : json = _copy(j);
  String get id => _s(json, 'id');
  Json toJson() => json;
}

class User extends JsonModel {
  User(super.j);
  String get username => _s(json, 'username');
  bool get isRoot => _b(json, 'is_root');
  int get createdAt => _i(json, 'created_at');
}

class ProviderCfg extends JsonModel {
  ProviderCfg(super.j);
  factory ProviderCfg.blank() => ProviderCfg({'name': '', 'kind': 'openai', 'base_url': '', 'api_key': '', 'enabled': true, 'headers': <String, dynamic>{}});
  String get name => _s(json, 'name');
  set name(String v) => json['name'] = v;
  String get kind => _s(json, 'kind', 'openai');
  set kind(String v) => json['kind'] = v;
  String get baseUrl => _s(json, 'base_url');
  set baseUrl(String v) => json['base_url'] = v;
  String get apiKey => _s(json, 'api_key');
  set apiKey(String v) => json['api_key'] = v;
  bool get enabled => _b(json, 'enabled', true);
  set enabled(bool v) => json['enabled'] = v;
  String get icon => _s(json, 'icon');
  Map<String, String> get headers => _m(json, 'headers').map((k, v) => MapEntry(k, v.toString()));
  set headers(Map<String, String> v) => json['headers'] = v;
}

class ModelCfg extends JsonModel {
  ModelCfg(super.j);
  String get providerId => _s(json, 'provider_id');
  set providerId(String v) => json['provider_id'] = v;
  String get modelId => _s(json, 'model_id');
  set modelId(String v) => json['model_id'] = v;
  String get name => _s(json, 'name').isEmpty ? modelId : _s(json, 'name');
  set name(String v) => json['name'] = v;
  int get contextLength => _i(json, 'context_length');
  set contextLength(int v) => json['context_length'] = v;
  int get maxOutput => _i(json, 'max_output');
  set maxOutput(int v) => json['max_output'] = v;
  bool get vision => _b(json, 'vision');
  set vision(bool v) => json['vision'] = v;
  bool get toolCall => _b(json, 'tool_call');
  set toolCall(bool v) => json['tool_call'] = v;
  bool get reasoning => _b(json, 'reasoning');
  set reasoning(bool v) => json['reasoning'] = v;
  String get icon => _s(json, 'icon');
  set icon(String v) => json['icon'] = v;
}

class McpServerCfg {
  final Json json;
  McpServerCfg(Json j) : json = _copy(j);
  factory McpServerCfg.blank() => McpServerCfg({'name': '', 'url': '', 'transport': 'http', 'headers': <String, dynamic>{}, 'enabled': true});
  String get name => _s(json, 'name');
  set name(String v) => json['name'] = v;
  String get url => _s(json, 'url');
  set url(String v) => json['url'] = v;
  String get transport => _s(json, 'transport', 'http');
  set transport(String v) => json['transport'] = v;
  bool get enabled => _b(json, 'enabled', true);
  set enabled(bool v) => json['enabled'] = v;
  Map<String, String> get headers => _m(json, 'headers').map((k, v) => MapEntry(k, v.toString()));
  set headers(Map<String, String> v) => json['headers'] = v;
}

class Character extends JsonModel {
  Character(super.j);
  factory Character.blank() => Character({
        'name': '',
        'avatar': '',
        'model_id': '',
        'card': <String, dynamic>{'name': ''},
        'mcp': <dynamic>[],
        'tool_ids': <dynamic>[],
        'context': <String, dynamic>{'mode': 'traditional', 'compress_threshold': 0, 'keep_recent': 6, 'display_recent': 4},
        'memory': <String, dynamic>{'enabled': true, 'auto_scan': true, 'share_global': true},
        'params': <String, dynamic>{'reasoning_effort': ''},
      });
  String get name => _s(json, 'name');
  set name(String v) => json['name'] = v;
  String get avatar => _s(json, 'avatar');
  set avatar(String v) => json['avatar'] = v;
  String get modelId => _s(json, 'model_id');
  set modelId(String v) => json['model_id'] = v;
  Json get card => _m(json, 'card');
  Json get context => _m(json, 'context');
  Json get memory => _m(json, 'memory');
  Json get params => _m(json, 'params');
  String get contextMode => _s(context, 'mode', 'traditional');
  List<String> get toolIds => _ls(json, 'tool_ids');
  set toolIds(List<String> v) => json['tool_ids'] = v;
  List<McpServerCfg> get mcp => ((json['mcp'] as List?) ?? const []).map((e) => McpServerCfg(Map<String, dynamic>.from(e as Map))).toList();
  set mcp(List<McpServerCfg> v) => json['mcp'] = v.map((e) => e.json).toList();
  String get reasoningEffort => _s(params, 'reasoning_effort');
  String cardStr(String k) => _s(card, k);
  void setCard(String k, dynamic v) => card[k] = v;
  List<String> get greetings {
    final out = <String>[];
    if (cardStr('first_mes').isNotEmpty) out.add(cardStr('first_mes'));
    out.addAll(_ls(card, 'alternate_greetings'));
    return out;
  }
}

class LocalTool extends JsonModel {
  LocalTool(super.j);
  factory LocalTool.blank() => LocalTool({
        'name': 'my_tool',
        'description': '',
        'parameters': {'type': 'object', 'properties': <String, dynamic>{}},
        'code': '// args 为模型传入的参数对象；可使用 console.log 与同步 http(method, url, body, headers)\nfunction main(args) {\n  return { echo: args };\n}\n',
        'models': <dynamic>[],
        'enabled': true,
      });
  String get name => _s(json, 'name');
  set name(String v) => json['name'] = v;
  String get description => _s(json, 'description');
  set description(String v) => json['description'] = v;
  dynamic get parameters => json['parameters'];
  set parameters(dynamic v) => json['parameters'] = v;
  String get code => _s(json, 'code');
  set code(String v) => json['code'] = v;
  List<String> get models => _ls(json, 'models');
  set models(List<String> v) => json['models'] = v;
  bool get enabled => _b(json, 'enabled', true);
  set enabled(bool v) => json['enabled'] = v;
}

class Memory extends JsonModel {
  Memory(super.j);
  String? get characterId => json['character_id'] as String?;
  String get content => _s(json, 'content');
  set content(String v) => json['content'] = v;
  List<String> get tags => _ls(json, 'tags');
  set tags(List<String> v) => json['tags'] = v;
  bool get pinned => _b(json, 'pinned');
  set pinned(bool v) => json['pinned'] = v;
  String get source => _s(json, 'source');
  int get updatedAt => _i(json, 'updated_at');
}

class Conversation extends JsonModel {
  Conversation(super.j);
  String get characterId => _s(json, 'character_id');
  String get title => _s(json, 'title');
  int get updatedAt => _i(json, 'updated_at');
  bool get generating => _b(json, 'generating');
}

class Usage {
  final Json json;
  Usage(this.json);
  int get input => _i(json, 'input');
  int get output => _i(json, 'output');
  int get cached => _i(json, 'cached');
  int get reasoning => _i(json, 'reasoning');
  int get durationMs => _i(json, 'duration_ms');
  int get ttftMs => _i(json, 'ttft_ms');
  bool get estimated => _b(json, 'estimated');
}

/// One piece of an assistant turn.
class Segment {
  final Json json;
  Segment(this.json);
  String get type => _s(json, 'type');
  String get text => _s(json, 'text');
  int get durationMs => _i(json, 'duration_ms');
  String get toolId => _s(json, 'id');
  String get name => _s(json, 'name');
  String get arguments => _s(json, 'arguments');
  String? get result => json['result'] as String?;
  bool get isError => _b(json, 'is_error');
}

class Message extends JsonModel {
  Message(super.j);
  String get conversationId => _s(json, 'conversation_id');
  int get seq => _i(json, 'seq');
  String get role => _s(json, 'role');
  String get content => _s(json, 'content');
  set content(String v) => json['content'] = v;
  String? get actual => json['actual'] as String?;
  String get actualStatus => _s(json, 'actual_status', 'none');
  String? get actualError => json['actual_error'] as String?;
  bool get visible => _b(json, 'visible', true);
  set visible(bool v) => json['visible'] = v;
  Json get parts => _m(json, 'parts');
  List<Segment> get segments => ((parts['segments'] as List?) ?? const []).map((e) => Segment(Map<String, dynamic>.from(e as Map))).toList();
  List<String> get images => _ls(parts, 'images');
  String? get error => parts['error'] as String?;
  String get model => _s(json, 'model');
  String get modelName => _s(json, 'model_name');
  String get modelIcon => _s(json, 'model_icon');
  Usage? get usage => json['usage'] is Map ? Usage(Map<String, dynamic>.from(json['usage'] as Map)) : null;
  int get createdAt => _i(json, 'created_at');
  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSummary => role == 'summary';
}

class UserSettings {
  final Json json;
  UserSettings(Json j) : json = _copy(j);
  String get defaultModelId => _s(json, 'default_model_id');
  set defaultModelId(String v) => json['default_model_id'] = v;
  String get fastModelId => _s(json, 'fast_model_id');
  set fastModelId(String v) => json['fast_model_id'] = v;
  String get userName => _s(json, 'user_name', 'User');
  set userName(String v) => json['user_name'] = v;
  String get userPersona => _s(json, 'user_persona');
  set userPersona(String v) => json['user_persona'] = v;
  int get memoryIdleMinutes => _i(json, 'memory_idle_minutes', 10);
  set memoryIdleMinutes(int v) => json['memory_idle_minutes'] = v;
  Json get client => _m(json, 'client');
}

class ContextInfo {
  final int tokens;
  final int max;
  final bool estimated;
  final String mode;
  final int threshold;
  const ContextInfo({this.tokens = 0, this.max = 0, this.estimated = true, this.mode = 'traditional', this.threshold = 0});
  factory ContextInfo.fromJson(Json j) => ContextInfo(
        tokens: _i(j, 'tokens'),
        max: _i(j, 'max'),
        estimated: _b(j, 'estimated', true),
        mode: _s(j, 'mode', 'traditional'),
        threshold: _i(j, 'threshold'),
      );
  double get ratio => max <= 0 ? 0 : (tokens / max).clamp(0.0, 1.0);
}
