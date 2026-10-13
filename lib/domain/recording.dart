import 'package:freezed_annotation/freezed_annotation.dart';

part 'recording.freezed.dart';

enum RecordingStatus { recording, ready }

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
  }) = _Recording;
}
