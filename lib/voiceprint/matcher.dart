import 'voiceprint_math.dart';

const double voiceprintMatchThreshold = 0.60;
const double voiceprintMatchMargin = 0.05;
const int voiceprintMinimumSpeechMs = 3000;

class VoiceprintReference {
  const VoiceprintReference({
    required this.personId,
    required this.name,
    required this.embedding,
    required this.speechMs,
  });

  final String personId;
  final String name;
  final List<double> embedding;
  final int speechMs;
}

class SpeakerVoiceprintCandidate {
  const SpeakerVoiceprintCandidate({
    required this.runId,
    required this.speaker,
    required this.embedding,
    required this.speechMs,
    this.nameSource,
  });

  final String runId;
  final int speaker;
  final List<double> embedding;
  final int speechMs;
  final String? nameSource;
}

class VoiceprintMatch {
  const VoiceprintMatch({
    required this.runId,
    required this.speaker,
    required this.personId,
    required this.name,
    required this.score,
  });

  final String runId;
  final int speaker;
  final String personId;
  final String name;
  final double score;
}

Map<String, List<double>> voiceprintCentroids(
  Iterable<VoiceprintReference> references,
) {
  final grouped = <String, List<VoiceprintReference>>{};
  for (final reference in references) {
    grouped.putIfAbsent(reference.personId, () => []).add(reference);
  }
  return {
    for (final entry in grouped.entries)
      entry.key: weightedMeanEmbedding([
        for (final reference in entry.value)
          WeightedEmbedding(reference.embedding, reference.speechMs),
      ]),
  };
}

List<VoiceprintMatch> matchVoiceprints({
  required Iterable<SpeakerVoiceprintCandidate> speakers,
  required Iterable<VoiceprintReference> references,
}) {
  final centroids = voiceprintCentroids(references);
  final peopleById = {
    for (final reference in references) reference.personId: reference,
  };
  final ranked = <(SpeakerVoiceprintCandidate, String, double)>[];
  for (final speaker in speakers) {
    if (speaker.speechMs < voiceprintMinimumSpeechMs ||
        speaker.nameSource == 'manual' ||
        speaker.nameSource == 'confirmed' ||
        centroids.isEmpty) {
      continue;
    }
    final scores = [
      for (final entry in centroids.entries)
        (entry.key, cosineSimilarity(speaker.embedding, entry.value)),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final best = scores.first;
    final secondBest = scores.length > 1 ? scores[1].$2 : -1.0;
    if (best.$2 < voiceprintMatchThreshold ||
        best.$2 - secondBest < voiceprintMatchMargin) {
      continue;
    }
    ranked.add((speaker, best.$1, best.$2));
  }
  ranked.sort((a, b) {
    final scoreOrder = b.$3.compareTo(a.$3);
    if (scoreOrder != 0) return scoreOrder;
    final runOrder = a.$1.runId.compareTo(b.$1.runId);
    return runOrder != 0 ? runOrder : a.$1.speaker.compareTo(b.$1.speaker);
  });
  final usedByRun = <String, Set<String>>{};
  final matches = <VoiceprintMatch>[];
  for (final (speaker, personId, score) in ranked) {
    final used = usedByRun.putIfAbsent(speaker.runId, () => {});
    if (!used.add(personId)) continue;
    final reference = peopleById[personId]!;
    matches.add(
      VoiceprintMatch(
        runId: speaker.runId,
        speaker: speaker.speaker,
        personId: personId,
        name: reference.name,
        score: score,
      ),
    );
  }
  return matches;
}
