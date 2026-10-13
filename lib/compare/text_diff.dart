class DiffSpan {
  const DiffSpan(this.text, {this.changed = false});

  final String text;
  final bool changed;
}

class TextDiff {
  const TextDiff({required this.a, required this.b});

  final List<DiffSpan> a;
  final List<DiffSpan> b;
}

class _Token {
  const _Token(this.text, this.start, this.end);

  final String text;
  final int start;
  final int end;
}

List<String> tokenizeText(String text) =>
    _tokens(text).map((token) => token.text).toList();

TextDiff diffText(String a, String b) {
  final aTokens = _tokens(a);
  final bTokens = _tokens(b);
  final aSignificant = [
    for (var i = 0; i < aTokens.length; i++)
      if (_significant(aTokens[i].text)) i,
  ];
  final bSignificant = [
    for (var i = 0; i < bTokens.length; i++)
      if (_significant(bTokens[i].text)) i,
  ];
  final lcs = List.generate(
    aSignificant.length + 1,
    (_) => List<int>.filled(bSignificant.length + 1, 0),
  );
  for (var i = aSignificant.length - 1; i >= 0; i--) {
    for (var j = bSignificant.length - 1; j >= 0; j--) {
      lcs[i][j] =
          _canonical(aTokens[aSignificant[i]].text) ==
              _canonical(bTokens[bSignificant[j]].text)
          ? lcs[i + 1][j + 1] + 1
          : (lcs[i + 1][j] > lcs[i][j + 1] ? lcs[i + 1][j] : lcs[i][j + 1]);
    }
  }
  final matchedA = <int>{};
  final matchedB = <int>{};
  var i = 0;
  var j = 0;
  while (i < aSignificant.length && j < bSignificant.length) {
    final ai = aSignificant[i];
    final bj = bSignificant[j];
    if (_canonical(aTokens[ai].text) == _canonical(bTokens[bj].text)) {
      matchedA.add(ai);
      matchedB.add(bj);
      i++;
      j++;
    } else if (lcs[i + 1][j] >= lcs[i][j + 1]) {
      i++;
    } else {
      j++;
    }
  }
  return TextDiff(
    a: _spans(a, aTokens, matchedA),
    b: _spans(b, bTokens, matchedB),
  );
}

List<_Token> _tokens(String text) {
  final result = <_Token>[];
  final runes = text.runes.toList();
  var offset = 0;
  for (var i = 0; i < runes.length;) {
    final start = offset;
    final rune = runes[i];
    final value = String.fromCharCode(rune);
    if (_isSpace(rune)) {
      offset += value.length;
      i++;
      continue;
    }
    if (_isWordRune(rune)) {
      final buffer = StringBuffer();
      while (i < runes.length && _isWordRune(runes[i])) {
        final part = String.fromCharCode(runes[i]);
        buffer.write(part);
        offset += part.length;
        i++;
      }
      result.add(_Token(buffer.toString(), start, offset));
      continue;
    }
    offset += value.length;
    i++;
    result.add(_Token(value, start, offset));
  }
  return result;
}

bool _isWordRune(int rune) =>
    rune >= 0x30 && rune <= 0x39 ||
    rune >= 0x41 && rune <= 0x5a ||
    rune >= 0x61 && rune <= 0x7a ||
    rune == 0x27;

bool _isSpace(int rune) =>
    rune == 0x20 || rune == 0x09 || rune == 0x0a || rune == 0x0d;

bool _isCjk(int rune) =>
    rune >= 0x3040 && rune <= 0x30ff ||
    rune >= 0x31f0 && rune <= 0x31ff ||
    rune >= 0x3400 && rune <= 0x4dbf ||
    rune >= 0x4e00 && rune <= 0x9fff ||
    rune >= 0x20000 && rune <= 0x2fa1f;

bool _significant(String value) {
  final runes = value.runes.toList();
  if (runes.every(_isWordRune)) return true;
  if (runes.length != 1) return false;
  final rune = runes.single;
  if (_isCjk(rune) || _isWordRune(rune)) return true;
  return !RegExp(
    r'^[!"#$%&()*+,\-./:;<=>?@\[\\\]^_`{|}~。、・「」『』！？…]$',
  ).hasMatch(value);
}

String _canonical(String value) => value.replaceAllMapped(
  RegExp(r'[A-Z]'),
  (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 32),
);

List<DiffSpan> _spans(String text, List<_Token> tokens, Set<int> matched) {
  final spans = <DiffSpan>[];
  var offset = 0;
  for (var index = 0; index < tokens.length; index++) {
    final token = tokens[index];
    if (token.start > offset) {
      spans.add(DiffSpan(text.substring(offset, token.start)));
    }
    spans.add(
      DiffSpan(
        token.text,
        changed: _significant(token.text) && !matched.contains(index),
      ),
    );
    offset = token.end;
  }
  if (offset < text.length) spans.add(DiffSpan(text.substring(offset)));
  return spans;
}
