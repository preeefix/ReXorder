import 'dart:io';

import 'package:path/path.dart' as p;

import '../audio/audio_math.dart';
import '../audio/wav_writer.dart';
import '../domain/recording.dart';
import '../domain/recording_repository.dart';
import 'recording_storage.dart';

Future<void> recoverOrphanedRecordings({
  required RecordingRepository repository,
  RecordingStorage? recordingStorage,
  Directory? recordingsDirectory,
}) async {
  final storage =
      recordingStorage ??
      (recordingsDirectory == null
          ? repository.recordingStorage
          : RecordingStorage(
              internalDirectory: recordingsDirectory,
              volumeLoader: () async => const [],
            ));
  final locations = [
    StorageLocation.internal,
    if (storage.sdAvailable) StorageLocation.sd,
  ];
  for (final location in locations) {
    final directory = storage.dirFor(location);
    if (!await directory.exists()) continue;
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      if (entity.path.endsWith('.partial')) {
        await entity.delete();
        continue;
      }
      if (!entity.path.endsWith('.pcm')) continue;
      final id = p.basenameWithoutExtension(entity.path);
      final wav = File(p.join(directory.path, '$id.wav'));
      final createdAt = await entity.lastModified();
      if (await entity.length() == 0) {
        await entity.delete();
        if (await repository.getRecording(id) != null) {
          await repository.delete(id);
        }
        if (await wav.exists()) await wav.delete();
        continue;
      }
      final duration = durationFromPcmBytes(await entity.length());
      await wrapPcmToWav(entity, wav);
      await entity.delete();
      await repository.recoverRecording(
        id: id,
        durationMs: duration.inMilliseconds,
        createdAt: createdAt,
        storage: location,
      );
    }
  }

  for (final recording in await repository.listRecordings()) {
    if (recording.status != RecordingStatus.recording ||
        !storage.isAvailable(recording)) {
      continue;
    }
    final directory = storage.dirFor(recording.storage);
    final pcm = File(p.join(directory.path, '${recording.id}.pcm'));
    if (await pcm.exists()) continue;
    final wav = storage.fileFor(recording);
    if (await wav.exists()) {
      final wavLength = await wav.length();
      final pcmLength = wavLength > 44 ? wavLength - 44 : 0;
      await repository.recoverRecording(
        id: recording.id,
        durationMs: durationFromPcmBytes(pcmLength).inMilliseconds,
        createdAt: recording.createdAt,
        storage: recording.storage,
      );
    } else {
      await repository.delete(recording.id);
    }
  }
}
