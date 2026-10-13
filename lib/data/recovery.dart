import 'dart:io';

import 'package:path/path.dart' as p;

import '../audio/audio_math.dart';
import '../audio/wav_writer.dart';
import '../domain/recording.dart';
import '../domain/recording_repository.dart';

Future<void> recoverOrphanedRecordings({
  required Directory recordingsDirectory,
  required RecordingRepository repository,
}) async {
  if (await recordingsDirectory.exists()) {
    await for (final entity in recordingsDirectory.list()) {
      if (entity is! File || !entity.path.endsWith('.pcm')) continue;
      final id = p.basenameWithoutExtension(entity.path);
      final wav = File(p.join(recordingsDirectory.path, '$id.wav'));
      final createdAt = await entity.lastModified();
      if (await entity.length() == 0) {
        await entity.delete();
        if (await repository.getRecording(id) != null) {
          await repository.delete(id);
        } else if (await wav.exists()) {
          await wav.delete();
        }
        continue;
      }
      final duration = durationFromPcmBytes(await entity.length());
      await wrapPcmToWav(entity, wav);
      await entity.delete();
      await repository.recoverRecording(
        id: id,
        durationMs: duration.inMilliseconds,
        createdAt: createdAt,
      );
    }
  }

  for (final recording in await repository.listRecordings()) {
    if (recording.status != RecordingStatus.recording) continue;
    final pcm = File(p.join(recordingsDirectory.path, '${recording.id}.pcm'));
    if (await pcm.exists()) continue;
    final wav = File(p.join(recordingsDirectory.path, recording.fileName));
    if (await wav.exists()) {
      final wavLength = await wav.length();
      final pcmLength = wavLength > 44 ? wavLength - 44 : 0;
      await repository.recoverRecording(
        id: recording.id,
        durationMs: durationFromPcmBytes(pcmLength).inMilliseconds,
        createdAt: recording.createdAt,
      );
    } else {
      await repository.delete(recording.id);
    }
  }
}
