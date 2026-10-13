class SearchHit {
  const SearchHit({
    required this.recordingId,
    required this.recordingTitle,
    required this.createdAt,
    required this.segmentStartMs,
    required this.text,
  });

  final String recordingId;
  final String recordingTitle;
  final DateTime createdAt;
  final int? segmentStartMs;
  final String? text;
}
