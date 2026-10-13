import 'dart:convert';

import 'package:intl/intl.dart';

import '../domain/bookmark.dart';
import '../domain/recording.dart';
import '../domain/transcript_segment.dart';

String exportTxt(
  Recording recording,
  List<TranscriptSegment> segments,
  Map<int, String> names, {
  List<Bookmark> bookmarks = const [],
}) {
  final date = DateFormat(
    'yyyy-MM-dd HH:mm',
  ).format(recording.createdAt.toLocal());
  final lines = [
    for (final segment in segments)
      '[${_formatClock(segment.startMs)}] '
          '${_withSpeaker(segment.text ?? '', segment.speaker, names)}',
  ];
  return '${recording.title}\n$date\n\n${lines.join('\n')}';
}

String exportSrt(
  Recording recording,
  List<TranscriptSegment> segments,
  Map<int, String> names, {
  List<Bookmark> bookmarks = const [],
}) {
  final cues = <String>[];
  for (var index = 0; index < segments.length; index++) {
    final segment = segments[index];
    cues.add(
      '${index + 1}\n'
      '${_formatTimestamp(segment.startMs, ',')} --> '
      '${_formatTimestamp(segment.endMs, ',')}\n'
      '${_withSpeaker(segment.text ?? '', segment.speaker, names)}',
    );
  }
  return cues.isEmpty ? '' : '${cues.join('\n\n')}\n\n';
}

String exportVtt(
  Recording recording,
  List<TranscriptSegment> segments,
  Map<int, String> names, {
  List<Bookmark> bookmarks = const [],
}) {
  final cues = [
    for (final segment in segments)
      '${_formatTimestamp(segment.startMs, '.')} --> '
          '${_formatTimestamp(segment.endMs, '.')}\n'
          '${segment.speaker == null ? segment.text ?? '' : '<v ${_speakerName(segment.speaker!, names)}>${segment.text ?? ''}'}',
  ];
  return 'WEBVTT\n\n${cues.join('\n\n')}${cues.isEmpty ? '' : '\n'}';
}

String exportJson(
  Recording recording,
  List<TranscriptSegment> segments,
  Map<int, String> names, {
  List<Bookmark> bookmarks = const [],
}) => const JsonEncoder.withIndent('  ').convert({
  'id': recording.id,
  'title': recording.title,
  'createdAt': recording.createdAt.toUtc().toIso8601String(),
  'durationMs': recording.durationMs,
  'asrModelId': recording.asrModelId,
  'languageHint': recording.languageHint.name,
  'segments': [
    for (final segment in segments)
      {
        'startMs': segment.startMs,
        'endMs': segment.endMs,
        'text': segment.text,
        'lang': segment.lang,
        'speaker': segment.speaker,
        'speakerName': segment.speaker == null
            ? null
            : _speakerName(segment.speaker!, names),
      },
  ],
  'bookmarks': [
    for (final bookmark in bookmarks)
      {'positionMs': bookmark.positionMs, 'label': bookmark.label},
  ],
});

String sanitizeExportFilename(String title) {
  final sanitized = title
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F\x7F]'), '_')
      .trim();
  final shortened = sanitized.length > 80
      ? sanitized.substring(0, 80).trim()
      : sanitized;
  return shortened.isEmpty ? 'Untitled' : shortened;
}

String _withSpeaker(String text, int? speaker, Map<int, String> names) =>
    speaker == null ? text : '${_speakerName(speaker, names)}: $text';

String _speakerName(int speaker, Map<int, String> names) =>
    names[speaker] ?? 'Speaker ${speaker + 1}';

String _formatClock(int milliseconds) {
  final duration = Duration(milliseconds: milliseconds);
  return '${duration.inHours.toString().padLeft(2, '0')}:'
      '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
      '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}

String _formatTimestamp(int milliseconds, String separator) {
  final duration = Duration(milliseconds: milliseconds);
  return '${duration.inHours.toString().padLeft(2, '0')}:'
      '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
      '${(duration.inSeconds % 60).toString().padLeft(2, '0')}'
      '$separator'
      '${(milliseconds % 1000).toString().padLeft(3, '0')}';
}
