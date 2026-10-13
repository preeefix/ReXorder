import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/compare/run_alignment.dart';
import 'package:rexorder/domain/transcript_segment.dart';

TranscriptSegment segment(int index, int start, int end) => TranscriptSegment(
  id: index,
  recordingId: 'r',
  index: index,
  startMs: start,
  endMs: end,
);

void main() {
  test('assigns B segments to the A segment with greatest overlap', () {
    final rows = alignRuns(
      [segment(0, 0, 1000), segment(1, 1000, 2000)],
      [segment(2, 800, 1300)],
    );
    expect(rows[0].b, isEmpty);
    expect(rows[1].b.single.id, 2);
  });

  test('attaches B segments outside A to the nearest segment', () {
    final rows = alignRuns(
      [segment(0, 1000, 2000), segment(1, 3000, 4000)],
      [segment(2, 0, 500), segment(3, 4500, 5000)],
    );
    expect(rows.first.b.single.id, 2);
    expect(rows.last.b.single.id, 3);
  });

  test('handles empty runs', () {
    expect(alignRuns([], []), isEmpty);
    expect(alignRuns([segment(0, 0, 1000)], []), hasLength(1));
  });
}
