import 'vad_segmenter.dart';
import 'diarizer.dart';

class SpeakerPiece {
  const SpeakerPiece({
    required this.startSample,
    required this.endSample,
    required this.speaker,
  });

  final int startSample;
  final int endSample;
  final int? speaker;

  @override
  bool operator ==(Object other) =>
      other is SpeakerPiece &&
      other.startSample == startSample &&
      other.endSample == endSample &&
      other.speaker == speaker;

  @override
  int get hashCode => Object.hash(startSample, endSample, speaker);
}

List<SpeakerPiece> splitBySpeaker(
  List<SpeechSampleRange> vad,
  List<SpeakerTurn> turns, {
  int minPieceSamples = 4800,
}) {
  final pieces = <SpeakerPiece>[];
  for (final range in vad) {
    if (range.endSample <= range.startSample) continue;
    final boundaries = <int>{range.startSample, range.endSample};
    for (final turn in turns) {
      if (turn.startSample > range.startSample &&
          turn.startSample < range.endSample) {
        boundaries.add(turn.startSample);
      }
      if (turn.endSample > range.startSample &&
          turn.endSample < range.endSample) {
        boundaries.add(turn.endSample);
      }
    }
    final sorted = boundaries.toList()..sort();
    final rangeOverlaps = <int, int>{};
    for (final turn in turns) {
      final overlap = _overlap(
        range.startSample,
        range.endSample,
        turn.startSample,
        turn.endSample,
      );
      if (overlap > 0) {
        rangeOverlaps.update(
          turn.speaker,
          (value) => value + overlap,
          ifAbsent: () => overlap,
        );
      }
    }
    for (var index = 0; index < sorted.length - 1; index++) {
      final start = sorted[index];
      final end = sorted[index + 1];
      if (end <= start) continue;
      final intervalOverlaps = <int, int>{};
      for (final turn in turns) {
        final overlap = _overlap(start, end, turn.startSample, turn.endSample);
        if (overlap > 0) {
          intervalOverlaps.update(
            turn.speaker,
            (value) => value + overlap,
            ifAbsent: () => overlap,
          );
        }
      }
      final speaker = intervalOverlaps.isEmpty
          ? _nearestSpeaker(start, end, turns, rangeOverlaps)
          : intervalOverlaps.length == 1
          ? intervalOverlaps.keys.single
          : _mostTotalOverlap(intervalOverlaps.keys, rangeOverlaps);
      if (pieces.isNotEmpty &&
          pieces.last.endSample == start &&
          pieces.last.speaker == speaker) {
        final previous = pieces.removeLast();
        pieces.add(
          SpeakerPiece(
            startSample: previous.startSample,
            endSample: end,
            speaker: speaker,
          ),
        );
      } else {
        pieces.add(
          SpeakerPiece(startSample: start, endSample: end, speaker: speaker),
        );
      }
    }
  }

  var index = 0;
  while (pieces.length > 1 && index < pieces.length) {
    final piece = pieces[index];
    if (piece.endSample - piece.startSample >= minPieceSamples) {
      index++;
      continue;
    }
    if (index > 0) {
      final previous = pieces[index - 1];
      pieces[index - 1] = SpeakerPiece(
        startSample: previous.startSample,
        endSample: piece.endSample,
        speaker: previous.speaker,
      );
      pieces.removeAt(index);
      index--;
    } else {
      final next = pieces[index + 1];
      pieces[index + 1] = SpeakerPiece(
        startSample: piece.startSample,
        endSample: next.endSample,
        speaker: next.speaker,
      );
      pieces.removeAt(index);
    }
  }

  final speakerNumbers = <int, int>{};
  return [
    for (final piece in pieces)
      SpeakerPiece(
        startSample: piece.startSample,
        endSample: piece.endSample,
        speaker: piece.speaker == null
            ? null
            : speakerNumbers.putIfAbsent(
                piece.speaker!,
                () => speakerNumbers.length,
              ),
      ),
  ];
}

int _overlap(int start, int end, int otherStart, int otherEnd) =>
    (end < otherEnd ? end : otherEnd) -
    (start > otherStart ? start : otherStart);

int? _nearestSpeaker(
  int start,
  int end,
  List<SpeakerTurn> turns,
  Map<int, int> rangeOverlaps,
) {
  if (turns.isEmpty) return null;
  var minimumDistance = 1 << 62;
  final nearest = <int>{};
  for (final turn in turns) {
    final distance = turn.endSample <= start
        ? start - turn.endSample
        : turn.startSample >= end
        ? turn.startSample - end
        : 0;
    if (distance < minimumDistance) {
      minimumDistance = distance;
      nearest
        ..clear()
        ..add(turn.speaker);
    } else if (distance == minimumDistance) {
      nearest.add(turn.speaker);
    }
  }
  return _mostTotalOverlap(nearest, rangeOverlaps);
}

int _mostTotalOverlap(Iterable<int> candidates, Map<int, int> totals) {
  final ordered = candidates.toSet().toList()
    ..sort((left, right) {
      final totalOrder = (totals[right] ?? 0).compareTo(totals[left] ?? 0);
      return totalOrder != 0 ? totalOrder : left.compareTo(right);
    });
  return ordered.first;
}
