import 'package:freezed_annotation/freezed_annotation.dart';

part 'recording.freezed.dart';

enum RecordingStatus { recording, ready }

enum TranscriptionStatus { none, queued, running, done, failed }

enum LanguageHint { auto, en, ja }

@freezed
abstract class Recording with _$Recording {
  const factory Recording({
    required String id,
    required String title,
    required DateTime createdAt,
    required int durationMs,
    required String fileName,
    required int sampleRate,
    required RecordingStatus status,
    @Default(TranscriptionStatus.none) TranscriptionStatus transcriptionStatus,
    @Default(LanguageHint.auto) LanguageHint languageHint,
    String? asrModelId,
    String? transcriptionError,
    int? speakerCountHint,
  }) = _Recording;
}
