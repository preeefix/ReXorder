import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/voiceprint/matcher.dart';

void main() {
  const references = [
    VoiceprintReference(
      personId: 'alice',
      name: 'Alice',
      embedding: [1, 0],
      speechMs: 10000,
    ),
    VoiceprintReference(
      personId: 'bob',
      name: 'Bob',
      embedding: [0, 1],
      speechMs: 10000,
    ),
  ];

  test('matches above the threshold with the required margin', () {
    final matches = matchVoiceprints(
      speakers: const [
        SpeakerVoiceprintCandidate(
          runId: 'run',
          speaker: 0,
          embedding: [0.9, 0.1],
          speechMs: 4000,
        ),
      ],
      references: references,
    );
    expect(matches.single.personId, 'alice');
    expect(
      matches.single.score,
      greaterThanOrEqualTo(voiceprintMatchThreshold),
    );
  });

  test('rejects similarity below the threshold', () {
    final matches = matchVoiceprints(
      speakers: const [
        SpeakerVoiceprintCandidate(
          runId: 'run',
          speaker: 0,
          embedding: [0.59, 0.807],
          speechMs: 4000,
        ),
      ],
      references: [references.first],
    );
    expect(matches, isEmpty);
  });

  test('requires the score margin over the runner-up', () {
    final matches = matchVoiceprints(
      speakers: const [
        SpeakerVoiceprintCandidate(
          runId: 'run',
          speaker: 0,
          embedding: [1, 0.98],
          speechMs: 4000,
        ),
      ],
      references: references,
    );
    expect(matches, isEmpty);
  });

  test('requires at least three seconds of speech', () {
    final matches = matchVoiceprints(
      speakers: const [
        SpeakerVoiceprintCandidate(
          runId: 'run',
          speaker: 0,
          embedding: [1, 0],
          speechMs: 2999,
        ),
      ],
      references: references,
    );
    expect(matches, isEmpty);
  });

  test('assigns a person at most once per run', () {
    final matches = matchVoiceprints(
      speakers: const [
        SpeakerVoiceprintCandidate(
          runId: 'run',
          speaker: 0,
          embedding: [1, 0],
          speechMs: 5000,
        ),
        SpeakerVoiceprintCandidate(
          runId: 'run',
          speaker: 1,
          embedding: [0.99, 0.01],
          speechMs: 5000,
        ),
      ],
      references: [references.first],
    );
    expect(matches, hasLength(1));
  });

  test('leaves manual, confirmed, and rejected rows unmatched', () {
    final matches = matchVoiceprints(
      speakers: const [
        SpeakerVoiceprintCandidate(
          runId: 'run',
          speaker: 0,
          embedding: [1, 0],
          speechMs: 5000,
          nameSource: 'manual',
        ),
        SpeakerVoiceprintCandidate(
          runId: 'run',
          speaker: 1,
          embedding: [1, 0],
          speechMs: 5000,
          nameSource: 'confirmed',
        ),
        SpeakerVoiceprintCandidate(
          runId: 'run',
          speaker: 2,
          embedding: [1, 0],
          speechMs: 5000,
          nameSource: 'manual',
        ),
      ],
      references: [references.first],
    );
    expect(matches, isEmpty);
  });
}
