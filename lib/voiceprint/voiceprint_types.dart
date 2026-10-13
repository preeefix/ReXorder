import 'dart:typed_data';

class SpeakerRunEmbedding {
  const SpeakerRunEmbedding({
    required this.runId,
    required this.speaker,
    required this.embedding,
    required this.speechMs,
  });

  final String runId;
  final int speaker;
  final Float32List embedding;
  final int speechMs;
}

class SpeakerNameDetails {
  const SpeakerNameDetails({
    required this.name,
    required this.source,
    this.personId,
    this.matchScore,
  });

  final String name;
  final String source;
  final String? personId;
  final double? matchScore;
}

class VoiceprintPersonSummary {
  const VoiceprintPersonSummary({
    required this.id,
    required this.name,
    required this.voiceprintCount,
    required this.activeRecordingCount,
  });

  final String id;
  final String name;
  final int voiceprintCount;
  final int activeRecordingCount;
}
