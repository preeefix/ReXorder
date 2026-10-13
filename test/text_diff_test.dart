import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/compare/text_diff.dart';

void main() {
  test('diffs English tokens while ignoring ASCII case', () {
    final diff = diffText('Hello world', 'hello there');
    expect(diff.a.where((span) => span.changed).map((span) => span.text), [
      'world',
    ]);
    expect(diff.b.where((span) => span.changed).map((span) => span.text), [
      'there',
    ]);
  });

  test('ignores punctuation differences', () {
    final diff = diffText('Hello, world!', 'hello world');
    expect(diff.a.where((span) => span.changed), isEmpty);
    expect(diff.b.where((span) => span.changed), isEmpty);
  });

  test('diffs Japanese characters individually', () {
    final diff = diffText('弁当制', '当性');
    expect(diff.a.where((span) => span.changed).map((span) => span.text), [
      '弁',
      '制',
    ]);
    expect(diff.b.where((span) => span.changed).map((span) => span.text), [
      '性',
    ]);
  });

  test('diffs Korean syllables individually', () {
    final diff = diffText('조금만 생각을 하면서 살면', '조금만 생각을 하면서 살자');
    expect(diff.a.where((span) => span.changed).map((span) => span.text), [
      '면',
    ]);
    expect(diff.b.where((span) => span.changed).map((span) => span.text), [
      '자',
    ]);
  });

  test('rendered spans preserve English, Japanese, and Korean text', () {
    const pairs = [
      ('Hello, world!', 'Hello there, world!'),
      ('弁当制を食べる。', '弁当制を食べます。'),
      ('조금만 생각을 하면서 살면', '조금만 생각을 하면서 살자'),
    ];
    for (final (a, b) in pairs) {
      final diff = diffText(a, b);
      expect(diff.a.map((span) => span.text).join(), a);
      expect(diff.b.map((span) => span.text).join(), b);
    }
  });

  test('identical strings have no differences', () {
    final diff = diffText('same text', 'same text');
    expect(diff.a.where((span) => span.changed), isEmpty);
    expect(diff.b.where((span) => span.changed), isEmpty);
  });
}
