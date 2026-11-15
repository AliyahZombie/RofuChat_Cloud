import 'package:flutter_test/flutter_test.dart';
import 'package:md_single_block_renderer/md_single_block_renderer.dart';
import 'package:rofuchat/features/chat/markdown_fix.dart';

String dump(List<BlockInlineNode> n) =>
    n.map((e) => e.type == 'text' ? e.text : '<${e.type}${e.text != null ? ':${e.text}' : ''}>${dump(e.children)}</>').join();

List<Block> parse(String s) => markdownToBlocks(preprocessMarkdown(s));

void main() {
  test('tight list items keep inline formatting on one line', () {
    final b = parse('- 粗体斜体***粗斜体***\n- ~~删除线~~ `行内代码`\n- 转义:\\*不是斜体\\*');
    expect(dump(b[0].inlines), '粗体斜体<em><strong>粗斜体</></>');
    expect(dump(b[1].inlines), '<del>删除线</> <code:行内代码></>');
    expect(dump(b[2].inlines), '转义:*不是斜体*');
  });

  test('superscript and subscript become inline math, code untouched', () {
    final b = parse('- 上标：X^2^ / 下标：H~2~O\n\n`a^b^ c~d~`');
    expect(dump(b[0].inlines), '上标：X<math:^{2}></> / 下标：H<math:_{2}></>O');
    expect(dump(b[1].inlines), '<code:a^b^ c~d~></>');
    expect(dump(parse('~~del~~')[0].inlines), '<del>del</>');
  });

  test(r'$$ block right after a paragraph line renders as math', () {
    final b = parse('块级:\n\$\$\n\\int_0^1 x dx\n\$\$\n后文');
    expect(b.map((e) => e.blockTag), ['p', 'math_block', 'p']);
    expect(b[1].math, r'\int_0^1 x dx');
  });

  test(r'$$ inside a code fence is left alone', () {
    final b = parse('```\na\n\$\$\nb\n```');
    expect(b.every((e) => e.blockTag != 'math_block'), isTrue);
  });

  test('nested quotes keep their depth in the path', () {
    final b = parse('> a\n>\n> > b\n> >\n> > > c');
    expect(b.map((e) => e.path.where((p) => p.tag == 'blockquote').length), [1, 2, 3]);
  });
}
