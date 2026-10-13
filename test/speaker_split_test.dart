import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/asr/diarizer.dart';
import 'package:rexorder/asr/speaker_split.dart';
import 'package:rexorder/asr/vad_segmenter.dart';

void main() {
  test('keeps an unlabeled VAD range when there are no turns', () {
    expect(splitBySpeaker([const SpeechSampleRange(0, 10000)], const []), [
      const SpeakerPiece(startSample: 0, endSample: 10000, speaker: null),
    ]);
  });

  test('assigns a single covering turn', () {
    expect(
      splitBySpeaker(
        [const SpeechSampleRange(0, 10000)],
        [const SpeakerTurn(startSample: 0, endSample: 10000, speaker: 7)],
        minPieceSamples: 1,
      ),
      [const SpeakerPiece(startSample: 0, endSample: 10000, speaker: 0)],
    );
  });

  test('splits at a mid-range speaker boundary', () {
    expect(
      splitBySpeaker(
        [const SpeechSampleRange(0, 10000)],
        const [
          SpeakerTurn(startSample: 0, endSample: 5000, speaker: 5),
          SpeakerTurn(startSample: 5000, endSample: 10000, speaker: 9),
        ],
        minPieceSamples: 1,
      ),
      const [
        SpeakerPiece(startSample: 0, endSample: 5000, speaker: 0),
        SpeakerPiece(startSample: 5000, endSample: 10000, speaker: 1),
      ],
    );
  });

  test('resolves overlapping turns by whole-range overlap', () {
    expect(
      splitBySpeaker(
        [const SpeechSampleRange(0, 10000)],
        const [
          SpeakerTurn(startSample: 0, endSample: 8000, speaker: 3),
          SpeakerTurn(startSample: 4000, endSample: 10000, speaker: 8),
        ],
        minPieceSamples: 1,
      ),
      const [
        SpeakerPiece(startSample: 0, endSample: 8000, speaker: 0),
        SpeakerPiece(startSample: 8000, endSample: 10000, speaker: 1),
      ],
    );
  });

  test('uses the nearest turn when an interval has no overlap', () {
    expect(
      splitBySpeaker(
        [const SpeechSampleRange(0, 1000)],
        const [
          SpeakerTurn(startSample: -1000, endSample: -500, speaker: 2),
          SpeakerTurn(startSample: 2000, endSample: 3000, speaker: 7),
        ],
        minPieceSamples: 1,
      ),
      [const SpeakerPiece(startSample: 0, endSample: 1000, speaker: 0)],
    );
  });

  test('folds a short piece into its previous piece', () {
    expect(
      splitBySpeaker(
        [const SpeechSampleRange(0, 10000)],
        const [
          SpeakerTurn(startSample: 0, endSample: 4000, speaker: 1),
          SpeakerTurn(startSample: 4000, endSample: 4500, speaker: 2),
          SpeakerTurn(startSample: 4500, endSample: 10000, speaker: 3),
        ],
        minPieceSamples: 1000,
      ),
      const [
        SpeakerPiece(startSample: 0, endSample: 4500, speaker: 0),
        SpeakerPiece(startSample: 4500, endSample: 10000, speaker: 1),
      ],
    );
  });

  test('renumbers speakers by first appearance', () {
    expect(
      splitBySpeaker(
        [const SpeechSampleRange(0, 12000)],
        const [
          SpeakerTurn(startSample: 0, endSample: 4000, speaker: 8),
          SpeakerTurn(startSample: 4000, endSample: 8000, speaker: 3),
          SpeakerTurn(startSample: 8000, endSample: 12000, speaker: 8),
        ],
        minPieceSamples: 1,
      ).map((piece) => piece.speaker),
      [0, 1, 0],
    );
  });
}
