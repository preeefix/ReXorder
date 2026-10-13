import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/domain/bookmark.dart';
import 'package:rexorder/domain/recording.dart';
import 'package:rexorder/domain/transcript_segment.dart';
import 'package:rexorder/export/transcript_export.dart';

void main() {
  final recording = Recording(
    id: 'recording-id',
    title: 'Interview',
    createdAt: DateTime(2025, 1, 2, 3, 4),
    durationMs: 4000000,
    fileName: 'recording-id.wav',
    sampleRate: 16000,
    status: RecordingStatus.ready,
    asrModelId: 'sense-voice',
    languageHint: LanguageHint.ja,
  );
  const segments = [
    TranscriptSegment(
      id: 1,
      recordingId: 'recording-id',
      index: 0,
      startMs: 3723456,
      endMs: 3724678,
      text: 'Hello',
      lang: 'en',
      speaker: 0,
    ),
    TranscriptSegment(
      id: 2,
      recordingId: 'recording-id',
      index: 1,
      startMs: 65007,
      endMs: 65123,
      text: 'こんにちは',
      lang: 'ja',
    ),
    TranscriptSegment(
      id: 3,
      recordingId: 'recording-id',
      index: 2,
      startMs: 1000,
      endMs: 2000,
      text: 'Fallback',
      speaker: 2,
    ),
  ];
  const names = {0: 'Alice'};

  test('exports TXT with date, speaker names, and long timestamps', () {
    expect(
      exportTxt(recording, segments, names),
      'Interview\n'
      '2025-01-02 03:04\n\n'
      '[01:02:03] Alice: Hello\n'
      '[00:01:05] こんにちは\n'
      '[00:00:01] Speaker 3: Fallback',
    );
  });

  test('exports SRT with numbered cues and millisecond timestamps', () {
    expect(
      exportSrt(recording, segments, names),
      '1\n'
      '01:02:03,456 --> 01:02:04,678\n'
      'Alice: Hello\n\n'
      '2\n'
      '00:01:05,007 --> 00:01:05,123\n'
      'こんにちは\n\n'
      '3\n'
      '00:00:01,000 --> 00:00:02,000\n'
      'Speaker 3: Fallback\n\n',
    );
  });

  test('exports WebVTT with voice labels and millisecond timestamps', () {
    expect(
      exportVtt(recording, segments, names),
      'WEBVTT\n\n'
      '01:02:03.456 --> 01:02:04.678\n'
      '<v Alice>Hello\n\n'
      '00:01:05.007 --> 00:01:05.123\n'
      'こんにちは\n\n'
      '00:00:01.000 --> 00:00:02.000\n'
      '<v Speaker 3>Fallback\n',
    );
  });

  test('exports pretty JSON with metadata, bookmarks, and escaped text', () {
    final quotedRecording = recording.copyWith(
      title: 'A "title"\ncontinued',
      createdAt: DateTime.utc(2025, 1, 2, 3, 4, 5, 678),
    );
    final content = exportJson(
      quotedRecording,
      [
        const TranscriptSegment(
          id: 4,
          recordingId: 'recording-id',
          index: 0,
          startMs: 12,
          endMs: 34,
          text: 'say "hello"\nagain',
          lang: 'en',
          speaker: 0,
        ),
      ],
      {0: 'Speaker "A"'},
      bookmarks: [
        Bookmark(
          id: 1,
          recordingId: 'recording-id',
          positionMs: 1234,
          label: 'opening',
          createdAt: DateTime.utc(2025),
        ),
      ],
    );
    final json = jsonDecode(content) as Map<String, dynamic>;

    expect(content, contains('\n  "segments": ['));
    expect(json, {
      'id': 'recording-id',
      'title': 'A "title"\ncontinued',
      'createdAt': '2025-01-02T03:04:05.678Z',
      'durationMs': 4000000,
      'asrModelId': 'sense-voice',
      'languageHint': 'ja',
      'segments': [
        {
          'startMs': 12,
          'endMs': 34,
          'text': 'say "hello"\nagain',
          'lang': 'en',
          'speaker': 0,
          'speakerName': 'Speaker "A"',
        },
      ],
      'bookmarks': [
        {'positionMs': 1234, 'label': 'opening'},
      ],
    });
  });

  test('sanitizes and caps export filenames', () {
    expect(sanitizeExportFilename(' /:?"<>|*\\\n '), '__________');
    expect(sanitizeExportFilename('  meeting notes  '), 'meeting notes');
    expect(sanitizeExportFilename('x' * 90), 'x' * 80);
  });
}
