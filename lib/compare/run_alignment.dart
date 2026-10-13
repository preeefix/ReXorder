import '../domain/transcript_segment.dart';

class AlignedRunRow {
  const AlignedRunRow({required this.a, required this.b});

  final TranscriptSegment? a;
  final List<TranscriptSegment> b;
}

List<AlignedRunRow> alignRuns(
  List<TranscriptSegment> a,
  List<TranscriptSegment> b,
) {
  final orderedA = [...a]..sort((x, y) => x.startMs.compareTo(y.startMs));
  final orderedB = [...b]..sort((x, y) => x.startMs.compareTo(y.startMs));
  if (orderedA.isEmpty) {
    return orderedB.isEmpty ? const [] : [AlignedRunRow(a: null, b: orderedB)];
  }
  final assigned = List.generate(orderedA.length, (_) => <TranscriptSegment>[]);
  for (final segment in orderedB) {
    var bestIndex = 0;
    var bestOverlap = 0;
    var bestDistance = 1 << 62;
    final midpoint = (segment.startMs + segment.endMs) ~/ 2;
    for (var i = 0; i < orderedA.length; i++) {
      final target = orderedA[i];
      final rawOverlap =
          (segment.endMs < target.endMs ? segment.endMs : target.endMs) -
          (segment.startMs > target.startMs ? segment.startMs : target.startMs);
      final overlap = rawOverlap > 0 ? rawOverlap : 0;
      final distance = midpoint < target.startMs
          ? target.startMs - midpoint
          : midpoint > target.endMs
          ? midpoint - target.endMs
          : 0;
      if (overlap > bestOverlap ||
          (overlap == bestOverlap && distance < bestDistance)) {
        bestIndex = i;
        bestOverlap = overlap;
        bestDistance = distance;
      }
    }
    assigned[bestIndex].add(segment);
  }
  return [
    for (var i = 0; i < orderedA.length; i++)
      AlignedRunRow(a: orderedA[i], b: assigned[i]),
  ];
}
