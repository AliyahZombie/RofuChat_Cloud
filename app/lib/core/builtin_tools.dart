import 'package:flutter/services.dart' show rootBundle;

/// Local tools that ship with the app. They are created on the server as ordinary
/// LocalTools the first time a user's tool list loads, so users can edit or delete them.
class BuiltinTool {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final String asset;
  const BuiltinTool({required this.name, required this.description, required this.parameters, required this.asset});

  Future<Map<String, dynamic>> toToolJson() async => {
        'name': name,
        'description': description,
        'parameters': parameters,
        'code': await rootBundle.loadString(asset),
        'models': <dynamic>[],
        'enabled': true,
      };
}

const builtinTools = <BuiltinTool>[
  BuiltinTool(
    name: 'roll_dice',
    asset: 'assets/builtin_tools/dice.js',
    description: 'Roll dice for D&D / TRPG with standard dice notation. Always use this tool instead of inventing results. '
        'Syntax: d20, 1d20+5, 2d6+1d4+3, (1d8+2)*2, d%, 4dF; keep/drop: 4d6kh3, 2d20kl1, 4d6dl1; '
        'advantage/disadvantage: adv, dis, 1d20+5 adv; exploding d6!, d6!>5, compounding d6!!; reroll 2d10r1, reroll once 2d10ro<2; '
        'success pools 10d6>=5; repeat 6#4d6kh3; several rolls separated by commas; a trailing word is a label ("1d20+5 attack"). '
        'Natural 20/1 on a single d20 is flagged as CRITICAL/FUMBLE.',
    parameters: {
      'type': 'object',
      'properties': {
        'expression': {'type': 'string', 'description': 'Dice expression(s), e.g. "1d20+5 attack, 2d6+3 damage"'},
        'reason': {'type': 'string', 'description': 'What the roll is for, e.g. "Stealth check"'},
      },
      'required': ['expression'],
    },
  ),
];

Set<String> get builtinToolNames => {for (final b in builtinTools) b.name};
