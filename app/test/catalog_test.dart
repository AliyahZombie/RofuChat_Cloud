import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rofuchat/core/model_catalog.dart';
import 'package:rofuchat/features/chat/message_rows.dart';
import 'package:rofuchat/models/models.dart';

void main() {
  test('catalog index prefers the maker listing and matches loose ids', () {
    final body = jsonEncode({
      'someproxy': {
        'models': {
          'deepseek/deepseek-v4-flash': {'canonical_model_id': 'deepseek/deepseek-v4-flash', 'tool_call': false, 'limit': {'context': 64000, 'output': 8000}, 'modalities': {'input': ['text']}},
        },
      },
      'deepseek': {
        'models': {
          'deepseek-v4-flash': {'canonical_model_id': 'deepseek/deepseek-v4-flash', 'tool_call': true, 'reasoning': true, 'limit': {'context': 1048576, 'output': 393216}, 'modalities': {'input': ['text', 'image']}},
        },
      },
      'anthropic': {
        'models': {
          'claude-opus-4-6': {'canonical_model_id': 'anthropic/claude-opus-4-6', 'tool_call': true, 'reasoning': true, 'limit': {'context': 200000, 'output': 128000}, 'modalities': {'input': ['text', 'image', 'pdf']}},
        },
      },
    });
    final idx = buildCatalogIndex(body);
    final d = idx['deepseek-v4-flash']!;
    expect(d.context, 1048576);
    expect(d.tools, true);
    expect(d.vision, true);
    expect(iconForLab(d.lab), 'deepseek');
    expect(iconForLab(idx['claude-opus-4-6']!.lab), 'claude');
    expect(candidateKeys('openrouter/anthropic/claude-opus-4-6:free'), ['claude-opus-4-6']);
    expect(candidateKeys('gpt-5-2025-08-07'), ['gpt-5-2025-08-07', 'gpt-5']);
  });

  test('real models.dev snapshot, when present', () {
    final f = File('/tmp/md.json');
    if (!f.existsSync()) return;
    final idx = buildCatalogIndex(f.readAsStringSync());
    expect(idx.length, greaterThan(1000));
    for (final id in ['claude-opus-4-6', 'gemini-3.8-flash', 'deepseek-v4-flash', 'gpt-5']) {
      expect(idx[id], isNotNull, reason: id);
    }
    expect(jsonEncode({for (final e in idx.entries) e.key: e.value.toList()}).length, lessThan(600000));
  });

  test('closeStreamingMarkdown closes open syntax', () {
    expect(closeStreamingMarkdown('a\n```dart\nvoid main'), 'a\n```dart\nvoid main\n```');
    expect(closeStreamingMarkdown('this is **bo'), 'this is **bo**');
    expect(closeStreamingMarkdown('run `ls -'), 'run `ls -`');
    expect(closeStreamingMarkdown('done **ok**'), 'done **ok**');
    expect(closeStreamingMarkdown('para\n\n- '), 'para\n\n');
  });

  test('compression switches stick (nested map is not re-copied) and map legacy mode', () {
    final c = Character.blank();
    expect(c.instant, false);
    expect(c.summarize, true);
    c.setCompression(instant: true);
    expect(c.instant, true);
    expect(c.summarize, true);
    expect(c.toJson()['context']['mode'], 'instant');
    c.setCompression(summarize: false);
    expect(c.toJson()['context']['summarize'], false);
    expect(c.toJson()['context']['instant'], true);

    final legacy = Character({'context': <String, dynamic>{'mode': 'instant'}});
    expect(legacy.instant, true);
    expect(legacy.summarize, true);
  });
}
