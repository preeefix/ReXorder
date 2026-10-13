import 'recording.dart';

class TranscriptionJob {
  const TranscriptionJob({required this.recording, required this.run});

  final Recording recording;
  final TranscriptionRun run;
}

class TranscriptionRun {
  const TranscriptionRun({
    required this.id,
    required this.recordingId,
    required this.createdAt,
    required this.languageHint,
    required this.diarized,
    required this.status,
    required this.processingMs,
    this.completedAt,
    this.asrModelId,
    this.speakerCountHint,
    this.error,
    this.segmentCount = 0,
    this.doneCount = 0,
    this.speakerCount = 0,
  });

  final String id;
  final String recordingId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? asrModelId;
  final LanguageHint languageHint;
  final int? speakerCountHint;
  final bool diarized;
  final TranscriptionStatus status;
  final String? error;
  final int processingMs;
  final int segmentCount;
  final int doneCount;
  final int speakerCount;
}
