import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/data/database.dart' hide Recording;
import 'package:rexorder/data/recording_mover.dart';
import 'package:rexorder/data/recording_storage.dart';
import 'package:rexorder/domain/recording.dart';
import 'package:rexorder/domain/recording_repository.dart';

void main() {
  test('moves a recording and updates storage after a verified copy', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.createRecording('move-success');

    final result = await fixture.mover.moveAll(StorageLocation.sd);

    final moved = (await fixture.repository.getRecording(recording.id))!;
    final destination = fixture.storage.fileFor(moved);
    expect(result.movedCount, 1);
    expect(moved.storage, StorageLocation.sd);
    expect(await destination.readAsBytes(), [1, 2, 3]);
    expect(await fixture.internalFile(recording).exists(), isFalse);
  });

  test('replaces a stale destination and completes the move', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.createRecording('stale-destination');
    final destination = File(
      '${fixture.sdRecordings.path}/${recording.fileName}',
    );
    await destination.parent.create(recursive: true);
    await destination.writeAsBytes([9, 9]);

    final result = await fixture.mover.moveAll(StorageLocation.sd);

    final moved = (await fixture.repository.getRecording(recording.id))!;
    expect(result.movedCount, 1);
    expect(moved.storage, StorageLocation.sd);
    expect(await destination.readAsBytes(), [1, 2, 3]);
    expect(await fixture.internalFile(recording).exists(), isFalse);
  });

  test('replaces a stale partial and completes the move', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.createRecording('stale-partial');
    final partial = File(
      '${fixture.sdRecordings.path}/${recording.fileName}.partial',
    );
    await partial.parent.create(recursive: true);
    await partial.writeAsBytes([9, 9]);

    final result = await fixture.mover.moveAll(StorageLocation.sd);

    final moved = (await fixture.repository.getRecording(recording.id))!;
    final destination = fixture.storage.fileFor(moved);
    expect(result.movedCount, 1);
    expect(moved.storage, StorageLocation.sd);
    expect(await destination.readAsBytes(), [1, 2, 3]);
    expect(await partial.exists(), isFalse);
    expect(await fixture.internalFile(recording).exists(), isFalse);
  });

  test('copy failure preserves the source and database location', () async {
    final fixture = await _Fixture.create(
      copyFile: (source, partial) async {
        await partial.writeAsBytes([9]);
        throw const FileSystemException('copy failed');
      },
    );
    addTearDown(fixture.dispose);
    final recording = await fixture.createRecording('copy-failure');
    final source = fixture.internalFile(recording);

    await expectLater(
      fixture.mover.moveAll(StorageLocation.sd),
      throwsA(isA<FileSystemException>()),
    );

    expect(await source.readAsBytes(), [1, 2, 3]);
    expect(
      (await fixture.repository.getRecording(recording.id))!.storage,
      StorageLocation.internal,
    );
    expect(
      await File(
        '${fixture.sdRecordings.path}/${recording.fileName}.partial',
      ).exists(),
      isFalse,
    );
  });

  test('size mismatch removes the partial and preserves the source', () async {
    final fixture = await _Fixture.create(
      copyFile: (_, partial) async {
        await partial.writeAsBytes([1]);
      },
    );
    addTearDown(fixture.dispose);
    final recording = await fixture.createRecording('size-mismatch');
    final source = fixture.internalFile(recording);

    await expectLater(
      fixture.mover.moveAll(StorageLocation.sd),
      throwsA(isA<StateError>()),
    );

    expect(await source.readAsBytes(), [1, 2, 3]);
    expect(
      (await fixture.repository.getRecording(recording.id))!.storage,
      StorageLocation.internal,
    );
    expect(
      await File(
        '${fixture.sdRecordings.path}/${recording.fileName}.partial',
      ).exists(),
      isFalse,
    );
  });

  test(
    'skips a current recording and one with running transcription',
    () async {
      final fixture = await _Fixture.create();
      addTearDown(fixture.dispose);
      final recording = await fixture.repository.createRecording(
        id: 'recording-now',
      );
      final transcribing = await fixture.repository.createRecording(
        id: 'transcribing-now',
      );
      await fixture.repository.createTranscriptionRun(
        recordingId: transcribing.id,
        status: TranscriptionStatus.running,
      );

      final result = await fixture.mover.moveAll(
        StorageLocation.sd,
        currentlyRecordingId: recording.id,
      );

      expect(result.movedCount, 0);
      expect(result.skippedTitles, contains(recording.title));
      expect(result.skippedTitles, contains(transcribing.title));
      expect(
        (await fixture.repository.getRecording(recording.id))!.storage,
        StorageLocation.internal,
      );
      expect(
        (await fixture.repository.getRecording(transcribing.id))!.storage,
        StorageLocation.internal,
      );
    },
  );
}

class _Fixture {
  _Fixture({
    required this.directory,
    required this.database,
    required this.storage,
    required this.repository,
    required this.mover,
  });

  final Directory directory;
  final AppDatabase database;
  final RecordingStorage storage;
  final RecordingRepository repository;
  final RecordingMover mover;

  Directory get internalRecordings => storage.internalDirectory;
  Directory get sdRecordings => storage.dirFor(StorageLocation.sd);

  static Future<_Fixture> create({RecordingFileCopy? copyFile}) async {
    final directory = await Directory.systemTemp.createTemp('rexorder-mover-');
    final internal = Directory('${directory.path}/internal/recordings')
      ..createSync(recursive: true);
    final storage = RecordingStorage(
      internalDirectory: internal,
      volumeLoader: () async => [
        StorageVolume(
          path: '${directory.path}/primary/files',
          removable: false,
          mounted: true,
          description: 'Internal',
          freeBytes: 1000000,
          totalBytes: 2000000,
        ),
        StorageVolume(
          path: '${directory.path}/sd/files',
          removable: true,
          mounted: true,
          description: 'SD',
          freeBytes: 1000000,
          totalBytes: 2000000,
        ),
      ],
    );
    await storage.refresh();
    final database = AppDatabase.memory();
    final repository = RecordingRepository(
      database,
      internal,
      recordingStorage: storage,
    );
    final mover = RecordingMover(
      repository: repository,
      storage: storage,
      copyFile: copyFile,
    );
    return _Fixture(
      directory: directory,
      database: database,
      storage: storage,
      repository: repository,
      mover: mover,
    );
  }

  Future<Recording> createRecording(String id) async {
    final recording = await repository.createRecording(id: id);
    await repository.markReady(id, 1000);
    final file = storage.fileFor(recording);
    await file.parent.create(recursive: true);
    await file.writeAsBytes([1, 2, 3]);
    return recording;
  }

  File internalFile(Recording recording) =>
      File('${internalRecordings.path}/${recording.fileName}');

  Future<void> dispose() async {
    storage.dispose();
    await database.close();
    await directory.delete(recursive: true);
  }
}
