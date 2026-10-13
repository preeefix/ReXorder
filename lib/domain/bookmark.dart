class Bookmark {
  const Bookmark({
    required this.id,
    required this.recordingId,
    required this.positionMs,
    required this.createdAt,
    this.label,
  });

  final int id;
  final String recordingId;
  final int positionMs;
  final DateTime createdAt;
  final String? label;

  @override
  bool operator ==(Object other) =>
      other is Bookmark &&
      other.id == id &&
      other.recordingId == recordingId &&
      other.positionMs == positionMs &&
      other.createdAt == createdAt &&
      other.label == label;

  @override
  int get hashCode =>
      Object.hash(id, recordingId, positionMs, createdAt, label);
}
