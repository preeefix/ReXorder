import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/asr/asr_engine.dart';

void main() {
  test('SenseVoice language tags are removed and normalized', () {
    final transcript = normalizeTranscriptLanguage(
      '<|ja|>こんにちは<|emotion|><|happy|>',
      '',
    );
    expect(transcript.text, 'こんにちは');
    expect(transcript.language, 'ja');
  });

  test('recognized language is normalized to English, Japanese, or other', () {
    expect(normalizeTranscriptLanguage('hello', 'en').language, 'en');
    expect(normalizeTranscriptLanguage('こんにちは', 'ja').language, 'ja');
    expect(normalizeTranscriptLanguage('hola', 'es').language, 'other');
  });
}
