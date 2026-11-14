import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'storage.dart';

/// Model metadata (context window, max output, vision, tool calls, reasoning, maker) from
/// the public models.dev catalogue. The ~6 MB catalogue is condensed into a small index
/// keyed by bare model id, cached locally and refreshed weekly.
class ModelCatalog {
  static const url = 'https://models.dev/api.json';
  static const _key = 'model_catalog.v1';
  static const _maxAge = Duration(days: 7);

  final Map<String, CatalogEntry> _index;
  final DateTime fetchedAt;
  ModelCatalog._(this._index, this.fetchedAt);

  int get length => _index.length;

  static ModelCatalog? _mem;
  static Future<ModelCatalog>? _loading;

  /// The cached catalogue, downloading it when missing, older than a week, or [force]d.
  /// Falls back to a stale cache when the download fails.
  static Future<ModelCatalog> load(LocalStore store, {bool force = false}) {
    final mem = _mem;
    if (!force && mem != null && DateTime.now().difference(mem.fetchedAt) < _maxAge) return Future.value(mem);
    return _loading ??= _load(store, force).whenComplete(() => _loading = null);
  }

  static Future<ModelCatalog> _load(LocalStore store, bool force) async {
    final cached = store.getJson(_key);
    final at = DateTime.tryParse(cached['at'] as String? ?? '');
    ModelCatalog? fromCache;
    if (at != null && cached['index'] is Map) {
      fromCache = ModelCatalog._(
        {for (final e in (cached['index'] as Map).entries) e.key as String: CatalogEntry.fromList(e.value as List)},
        at,
      );
      if (!force && DateTime.now().difference(at) < _maxAge) return _mem = fromCache;
    }
    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 40));
      if (res.statusCode != 200) throw Exception('models.dev HTTP ${res.statusCode}');
      final index = await compute(_buildIndex, res.body);
      final now = DateTime.now();
      await store.setJson(_key, {
        'at': now.toIso8601String(),
        'index': {for (final e in index.entries) e.key: e.value.toList()},
      });
      return _mem = ModelCatalog._(index, now);
    } catch (e) {
      if (fromCache != null) return _mem = fromCache;
      rethrow;
    }
  }

  /// Looks a model up by the id the provider uses (e.g. `anthropic/claude-opus-4-6`,
  /// `deepseek-v4-flash`, `gpt-5-2025-08-07`).
  CatalogEntry? lookup(String modelId) {
    for (final k in candidateKeys(modelId)) {
      final hit = _index[k];
      if (hit != null) return hit;
    }
    return null;
  }

  /// Fills a model's capabilities from the catalogue. Returns false when the model is unknown.
  bool apply(ModelCfg m, {bool overwriteIcon = false}) {
    final e = lookup(m.modelId);
    if (e == null) return false;
    if (e.context > 0) m.contextLength = e.context;
    if (e.output > 0) m.maxOutput = e.output;
    m.vision = e.vision;
    m.toolCall = e.tools;
    m.reasoning = e.reasoning;
    final icon = iconForLab(e.lab);
    if (icon.isNotEmpty && (overwriteIcon || m.icon.isEmpty)) m.icon = icon;
    return true;
  }
}

class CatalogEntry {
  final int context;
  final int output;
  final bool vision;
  final bool tools;
  final bool reasoning;
  final String lab;
  const CatalogEntry({required this.context, required this.output, required this.vision, required this.tools, required this.reasoning, required this.lab});

  factory CatalogEntry.fromList(List l) => CatalogEntry(
        context: (l[0] as num).toInt(),
        output: (l[1] as num).toInt(),
        vision: l[2] == 1,
        tools: l[3] == 1,
        reasoning: l[4] == 1,
        lab: l[5] as String,
      );
  List<Object> toList() => [context, output, vision ? 1 : 0, tools ? 1 : 0, reasoning ? 1 : 0, lab];
}

String _bare(String id) {
  var s = id.trim().toLowerCase();
  final slash = s.lastIndexOf('/');
  if (slash >= 0) s = s.substring(slash + 1);
  final colon = s.indexOf(':');
  if (colon > 0) s = s.substring(0, colon); // openrouter ":free", ollama ":latest"
  return s;
}

final _dateSuffix = RegExp(r'[-_@](\d{4}-\d{2}-\d{2}|\d{8}|\d{6}|\d{4})$');

/// Keys tried in order: exact bare id, then without a trailing date or "-latest".
List<String> candidateKeys(String id) {
  final b = _bare(id);
  final out = <String>[b];
  var s = b;
  for (final suffix in ['-latest', '-preview', '-exp']) {
    if (s.endsWith(suffix)) s = s.substring(0, s.length - suffix.length);
  }
  s = s.replaceFirst(_dateSuffix, '');
  if (s != b) out.add(s);
  return out;
}

/// models.dev maker id → bundled icon key.
String iconForLab(String lab) {
  const map = {
    'anthropic': 'claude',
    'google': 'gemini',
    'openai': 'openai',
    'deepseek': 'deepseek',
    'xai': 'grok',
    'x-ai': 'grok',
    'moonshotai': 'moonshot',
    'moonshot': 'moonshot',
    'zhipuai': 'zhipu',
    'z-ai': 'zhipu',
    'zai': 'zhipu',
    'qwen': 'qwen',
    'alibaba': 'qwen',
    'meta-llama': 'meta',
    'meta': 'meta',
    'mistralai': 'mistral',
    'mistral': 'mistral',
    'minimax': 'minimax',
    'baidu': 'wenxin',
    'tencent': 'hunyuan',
    'bytedance': 'doubao',
    'bytedance-seed': 'doubao',
    'stepfun': 'stepfun',
    'stepfun-ai': 'stepfun',
    '01-ai': 'yi',
    'cohere': 'cohere',
    'nvidia': 'nvidia',
    'microsoft': 'microsoft',
    'perplexity': 'perplexity',
    'baichuan': 'baichuan',
    'iflytek': 'spark',
    'amazon': 'aws',
  };
  return map[lab.toLowerCase()] ?? '';
}

/// Runs in an isolate: condenses models.dev's api.json into {bareId: entry}. When several
/// providers list the same model, the maker's own listing (provider == canonical lab) wins,
/// then the listing with the largest context.
@visibleForTesting
Map<String, CatalogEntry> buildCatalogIndex(String body) => _buildIndex(body);

Map<String, CatalogEntry> _buildIndex(String body) {
  final data = jsonDecode(body) as Map<String, dynamic>;
  final best = <String, (int, CatalogEntry)>{};
  void put(String key, int rank, CatalogEntry e) {
    final cur = best[key];
    if (cur == null || rank > cur.$1 || (rank == cur.$1 && e.context > cur.$2.context)) best[key] = (rank, e);
  }

  for (final p in data.entries) {
    final models = (p.value as Map)['models'];
    if (models is! Map) continue;
    for (final me in models.entries) {
      final m = me.value;
      if (m is! Map) continue;
      final canonical = (m['canonical_model_id'] as String?) ?? '';
      final slash = canonical.indexOf('/');
      final lab = slash > 0 ? canonical.substring(0, slash) : p.key;
      final input = ((m['modalities'] as Map?)?['input'] as List?) ?? const [];
      final limit = (m['limit'] as Map?) ?? const {};
      final e = CatalogEntry(
        context: (limit['context'] as num?)?.toInt() ?? 0,
        output: (limit['output'] as num?)?.toInt() ?? 0,
        vision: input.contains('image'),
        tools: m['tool_call'] == true,
        reasoning: m['reasoning'] == true,
        lab: lab,
      );
      final rank = p.key == lab ? 2 : 1;
      put(_bare(me.key as String), rank, e);
      if (canonical.isNotEmpty) put(_bare(canonical), rank, e);
    }
  }
  return {for (final e in best.entries) e.key: e.value.$2};
}
