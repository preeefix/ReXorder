import 'dart:io';

import '../domain/recording.dart';
import '../domain/recording_repository.dart';
import 'recording_storage.dart';

typedef RecordingFileCopy = Future<void> Function(File source, File partial);
typedef RecordingMoveProgress =
    void Function(int current, int total, String title);

class RecordingMoveResult {
  const RecordingMoveResult({
    required this.movedCount,
    required this.skippedTitles,
  });

  final int movedCount;
  final List<String> skippedTitles;
}

class RecordingMover {
  RecordingMover({
    required this.repository,
    required this.storage,
    RecordingFileCopy? copyFile,
  }) : _copyFile = copyFile ?? _copy;

  final RecordingRepository repository;
  final RecordingStorage storage;
  final RecordingFileCopy _copyFile;

  Future<RecordingMoveResult> moveAll(
    StorageLocation destination, {
    String? currentlyRecordingId,
    RecordingMoveProgress? onProgress,
  }) async {
    if (destination == StorageLocation.sd && !storage.sdAvailable) {
      throw StateError('SD card is not available.');
    }
    final recordings = await repository.listRecordings();
    final eligible = <Recording>[];
    final skipped = <String>[];
    for (final recording in recordings) {
      if (recording.storage == destination) continue;
      if (recording.id == currentlyRecordingId ||
          recording.status == RecordingStatus.recording ||
          recording.transcriptionStatus == TranscriptionStatus.running) {
        skipped.add(recording.title);
        continue;
      }
      if (!storage.isAvailable(recording)) {
        skipped.add(recording.title);
        continue;
      }
      eligible.add(recording);
    }

    var requiredBytes = 0;
    for (final recording in eligible) {
      requiredBytes += await storage.fileFor(recording).length();
    }
    final freeBytes = storage.freeBytesFor(destination);
    if (freeBytes == null) {
      throw StateError('Unable to determine destination free space.');
    }
    if (requiredBytes > freeBytes) {
      throw StateError('Not enough free space at the destination.');
    }

    final destinationDirectory = storage.dirFor(destination);
    await destinationDirectory.create(recursive: true);
    var movedCount = 0;
    for (var index = 0; index < eligible.length; index++) {
      final recording = eligible[index];
      onProgress?.call(index + 1, eligible.length, recording.title);
      await _moveOne(recording, destination, destinationDirectory);
      movedCount++;
    }
    return RecordingMoveResult(
      movedCount: movedCount,
      skippedTitles: List.unmodifiable(skipped),
    );
  }

  Future<void> _moveOne(
    Recording recording,
    StorageLocation destination,
    Directory destinationDirectory,
  ) async {
    final source = storage.fileFor(recording);
    final destinationFile = File(
      '${destinationDirectory.path}${Platform.pathSeparator}${recording.fileName}',
    );
    final partial = File('${destinationFile.path}.partial');
    if (await destinationFile.exists()) {
      if (!await source.exists()) {
        throw StateError('Destination already exists for ${recording.title}.');
      }
      await destinationFile.delete();
    }

    var destinationCreated = false;
    var databaseUpdated = false;
    try {
      if (await partial.exists()) await partial.delete();
      final sourceSize = await source.length();
      await _copyFile(source, partial);
      if (await partial.length() != sourceSize) {
        throw StateError('Copied file size does not match the source.');
      }
      await partial.rename(destinationFile.path);
      destinationCreated = true;
      await repository.setStorageLocation(recording.id, destination);
      databaseUpdated = true;
      await source.delete();
    } catch (_) {
      if (databaseUpdated) {
        try {
          await repository.setStorageLocation(recording.id, recording.storage);
        } catch (_) {}
      }
      if (destinationCreated && await destinationFile.exists()) {
        try {
          await destinationFile.delete();
        } catch (_) {}
      }
      if (await partial.exists()) {
        try {
          await partial.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  static Future<void> _copy(File source, File partial) async {
    await source.copy(partial.path);
  }
}
