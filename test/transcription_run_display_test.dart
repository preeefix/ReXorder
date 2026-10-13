import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/domain/recording.dart';
import 'package:rexorder/domain/transcription_run.dart';
import 'package:rexorder/domain/transcription_run_display.dart';

void main() {
  test('formats run language labels', () {
    expect(runLanguageLabel(LanguageHint.auto), 'Auto');
    expect(runLanguageLabel(LanguageHint.en), 'English');
    expect(runLanguageLabel(LanguageHint.ja), '日本語');
  });

  test('formats detected and hinted speaker counts', () {
    expect(runSpeakerCountLabel(detected: 2, hint: null), '2 speakers');
    expect(runSpeakerCountLabel(detected: 0, hint: 1), '1 speaker');
    expect(runSpeakerCountLabel(detected: 0, hint: 3), '3 speakers');
    expect(runSpeakerCountLabel(detected: 0, hint: null), 'Auto speakers');
    expect(
      runSpeakerCountLabel(detected: 0, hint: null, diarized: true),
      'No speakers',
    );
  });

  test('shows localized metadata and processing time', () {
    final run = TranscriptionRun(
      id: 'run',
      recordingId: 'recording',
      createdAt: DateTime.utc(2026, 10, 13, 18, 16),
      languageHint: LanguageHint.auto,
      diarized: true,
      status: TranscriptionStatus.done,
      processingMs: 41000,
      speakerCount: 2,
    );
    expect(runDetailsLabel(run), contains('Auto · 2 speakers ·'));
    expect(runDetailsLabel(run), contains('0:41 processing'));
  });
}
