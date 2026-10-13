import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:rexorder/data/database.dart';
import 'package:rexorder/data/recovery.dart';
import 'package:rexorder/domain/recording.dart';
import 'package:rexorder/domain/recording_repository.dart';

void main() {
  test('recovers an orphan PCM using its modification time', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rexorder-recovery-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final recordingsDirectory = Directory('${directory.path}/recordings')
      ..createSync();
    final repository = RecordingRepository(database, recordingsDirectory);
    final orphanPcm = File('${recordingsDirectory.path}/orphan.pcm')
      ..writeAsBytesSync(List<int>.filled(64000, 0));
    await orphanPcm.setLastModified(DateTime(2024, 1, 2, 3, 4));
    final modifiedAt = await orphanPcm.lastModified();

    await recoverOrphanedRecordings(
      recordingsDirectory: recordingsDirectory,
      repository: repository,
    );

    final orphan = await repository.getRecording('orphan');
    expect(orphan, isNotNull);
    expect(orphan!.createdAt, modifiedAt);
    expect(
      orphan.title,
      'Recovered recording ${DateFormat('yyyy-MM-dd HH:mm').format(modifiedAt)}',
    );
    expect(orphan.status, RecordingStatus.ready);
    expect(orphan.durationMs, 2000);
    expect(
      await File('${recordingsDirectory.path}/orphan.wav').exists(),
      isTrue,
    );
    expect(await orphanPcm.exists(), isFalse);
  });

  test(
    'updates an existing row and overwrites a partial WAV from its PCM',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rexorder-recovery-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase.memory();
      addTearDown(database.close);
      final recordingsDirectory = Directory('${directory.path}/recordings')
        ..createSync();
      final repository = RecordingRepository(database, recordingsDirectory);
      final pcmBytes = List<int>.generate(32000, (index) => index & 0xff);
      final pcm = File('${recordingsDirectory.path}/existing.pcm')
        ..writeAsBytesSync(pcmBytes);
      final wav = File('${recordingsDirectory.path}/existing.wav')
        ..writeAsBytesSync([1, 2, 3]);
      await repository.createRecording(id: 'existing');

      await recoverOrphanedRecordings(
        recordingsDirectory: recordingsDirectory,
        repository: repository,
      );

      final existing = await repository.getRecording('existing');
      final wavBytes = await wav.readAsBytes();
      expect(existing!.status, RecordingStatus.ready);
      expect(existing.durationMs, 1000);
      expect(wavBytes.length, pcmBytes.length + 44);
      expect(wavBytes.sublist(44), pcmBytes);
      expect(await pcm.exists(), isFalse);
    },
  );

  test(
    'marks a recording ready from an existing WAV when PCM is missing',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rexorder-recovery-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase.memory();
      addTearDown(database.close);
      final recordingsDirectory = Directory('${directory.path}/recordings')
        ..createSync();
      final repository = RecordingRepository(database, recordingsDirectory);
      await repository.createRecording(id: 'wav-only');
      final wav = File('${recordingsDirectory.path}/wav-only.wav')
        ..writeAsBytesSync(List<int>.filled(44 + 32000, 0));

      await recoverOrphanedRecordings(
        recordingsDirectory: recordingsDirectory,
        repository: repository,
      );

      final recovered = await repository.getRecording('wav-only');
      expect(recovered!.status, RecordingStatus.ready);
      expect(recovered.durationMs, 1000);
      expect(await wav.exists(), isTrue);
    },
  );

  test('deletes a recording row when neither PCM nor WAV exists', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rexorder-recovery-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final recordingsDirectory = Directory('${directory.path}/recordings');
    final repository = RecordingRepository(database, recordingsDirectory);
    await repository.createRecording(id: 'missing');

    await recoverOrphanedRecordings(
      recordingsDirectory: recordingsDirectory,
      repository: repository,
    );

    expect(await repository.getRecording('missing'), isNull);
  });

  test('deletes a zero-byte PCM and its recording row', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rexorder-recovery-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final recordingsDirectory = Directory('${directory.path}/recordings')
      ..createSync();
    final repository = RecordingRepository(database, recordingsDirectory);
    await repository.createRecording(id: 'empty');
    final pcm = File('${recordingsDirectory.path}/empty.pcm')
      ..writeAsBytesSync([]);

    await recoverOrphanedRecordings(
      recordingsDirectory: recordingsDirectory,
      repository: repository,
    );

    expect(await pcm.exists(), isFalse);
    expect(await repository.getRecording('empty'), isNull);
    expect(
      await File('${recordingsDirectory.path}/empty.wav').exists(),
      isFalse,
    );
  });
}
