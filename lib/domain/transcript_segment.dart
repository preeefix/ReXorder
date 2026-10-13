class TranscriptSegment {
  const TranscriptSegment({
    required this.id,
    required this.recordingId,
    required this.index,
    required this.startMs,
    required this.endMs,
    this.text,
    this.lang,
    this.speaker,
  });

  final int id;
  final String recordingId;
  final int index;
  final int startMs;
  final int endMs;
  final String? text;
  final String? lang;
  final int? speaker;
}

class TranscriptSegmentDraft {
  const TranscriptSegmentDraft({
    required this.index,
    required this.startMs,
    required this.endMs,
    this.text,
    this.lang,
    this.speaker,
  });

  final int index;
  final int startMs;
  final int endMs;
  final String? text;
  final String? lang;
  final int? speaker;
}
