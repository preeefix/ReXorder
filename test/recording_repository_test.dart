import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/data/database.dart';
import 'package:rexorder/domain/recording.dart';
import 'package:rexorder/domain/recording_repository.dart';
import 'package:rexorder/domain/transcript_segment.dart';
import 'package:rexorder/export/transcript_export.dart';
import 'package:rexorder/voiceprint/voiceprint_types.dart';

void main() {
  test(
    'inserts, lists newest first, renames, and deletes recordings',
    () async {
      final directory = await Directory.systemTemp.createTemp('rexorder-repo-');
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase.memory();
      addTearDown(database.close);
      var currentTime = DateTime(2026, 1, 1, 10);
      final repository = RecordingRepository(
        database,
        directory,
        now: () => currentTime,
      );

      await repository.createRecording(id: 'older');
      currentTime = currentTime.add(const Duration(minutes: 1));
      await repository.createRecording(id: 'newer');

      final items = await repository.listRecordings();
      expect(items.map((item) => item.id), ['newer', 'older']);
      expect(items.first.fileName, 'newer.wav');
      expect(items.first.status.name, 'recording');

      await repository.rename('newer', 'Renamed note');
      expect((await repository.getRecording('newer'))!.title, 'Renamed note');
      final wav = File('${directory.path}/newer.wav')..writeAsBytesSync([1]);
      await repository.delete('newer');
      expect(await repository.getRecording('newer'), isNull);
      expect(await wav.exists(), isFalse);
      expect((await repository.listRecordings()).single.id, 'older');
    },
  );

  test('deleting a recording also deletes its transcript segments', () async {
    final directory = await Directory.systemTemp.createTemp('rexorder-repo-');
    addTearDown(() => directory.delete(recursive: true));
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final repository = RecordingRepository(database, directory);
    final recording = await repository.createRecording(id: 'with-transcript');
    await repository.replaceTranscriptSegments(recording.id, const [
      TranscriptSegmentDraft(index: 0, startMs: 0, endMs: 1000, text: 'hello'),
    ]);
    await repository.setSpeakerName(
      recordingId: recording.id,
      speaker: 0,
      name: 'Alice',
    );
    await repository.addBookmark(recording.id, 1200, label: 'opening');

    await repository.delete(recording.id);

    expect(await repository.listTranscriptSegments(recording.id), isEmpty);
    expect(await repository.speakerNames(recording.id), isEmpty);
    expect(await repository.watchBookmarks(recording.id).first, isEmpty);
  });

  test('speaker names can be set, watched, and cleared', () async {
    final directory = await Directory.systemTemp.createTemp('rexorder-repo-');
    addTearDown(() => directory.delete(recursive: true));
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final repository = RecordingRepository(database, directory);
    final recording = await repository.createRecording(id: 'speaker-names');
    final names = repository.watchSpeakerNames(recording.id);

    expect(await names.first, isEmpty);
    await repository.setSpeakerName(
      recordingId: recording.id,
      speaker: 0,
      name: '  Alice  ',
    );
    expect(await names.first, {0: 'Alice'});
    expect(await repository.speakerNames(recording.id), {0: 'Alice'});

    await repository.setSpeakerName(
      recordingId: recording.id,
      speaker: 0,
      name: '',
    );
    expect(await repository.speakerNames(recording.id), isEmpty);
  });

  test('search matches text and titles with literal SQL wildcards', () async {
    final directory = await Directory.systemTemp.createTemp('rexorder-search-');
    addTearDown(() => directory.delete(recursive: true));
    final database = AppDatabase.memory();
    addTearDown(database.close);
    var now = DateTime(2026, 1, 1);
    final repository = RecordingRepository(
      database,
      directory,
      now: () {
        final value = now;
        now = value.add(const Duration(minutes: 1));
        return value;
      },
    );
    final older = await repository.createRecording(
      id: 'older-search',
      title: 'Older meeting',
    );
    await repository.replaceTranscriptSegments(older.id, const [
      TranscriptSegmentDraft(
        index: 0,
        startMs: 2000,
        endMs: 3000,
        text: 'Hello from an older meeting',
      ),
      TranscriptSegmentDraft(
        index: 1,
        startMs: 1000,
        endMs: 2000,
        text: '弁当制の案内',
      ),
      TranscriptSegmentDraft(
        index: 2,
        startMs: 4000,
        endMs: 5000,
        text: '100% ready',
      ),
      TranscriptSegmentDraft(
        index: 3,
        startMs: 5000,
        endMs: 6000,
        text: 'under_score',
      ),
    ]);
    final newer = await repository.createRecording(
      id: 'newer-search',
      title: 'Recent notes',
    );
    await repository.replaceTranscriptSegments(newer.id, const [
      TranscriptSegmentDraft(
        index: 0,
        startMs: 3000,
        endMs: 4000,
        text: 'HELLO from newer notes',
      ),
      TranscriptSegmentDraft(
        index: 1,
        startMs: 1000,
        endMs: 2000,
        text: 'another hello',
      ),
    ]);
    final titleOnly = await repository.createRecording(
      id: 'title-only-search',
      title: 'Unique title needle',
    );

    final english = await repository.search('hello');
    expect(english.map((hit) => hit.recordingId), [
      'newer-search',
      'newer-search',
      'older-search',
    ]);
    expect(english.map((hit) => hit.segmentStartMs), [1000, 3000, 2000]);
    expect(english.first.createdAt, newer.createdAt);
    expect((await repository.search('弁当')).single.text, '弁当制の案内');
    final titleHits = await repository.search('title needle');
    expect(titleHits, hasLength(1));
    expect(titleHits.single.recordingId, titleOnly.id);
    expect(titleHits.single.segmentStartMs, isNull);
    expect(titleHits.single.text, isNull);
    expect((await repository.search('%')).single.text, '100% ready');
    expect((await repository.search('_')).single.text, 'under_score');
    expect(await repository.search(' \t\n '), isEmpty);
    expect(await repository.search('hello', limit: 1), hasLength(1));
  });

  test('bookmarks support ordered CRUD and clear empty labels', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rexorder-bookmarks-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final repository = RecordingRepository(database, directory);
    final recording = await repository.createRecording(id: 'bookmarks');
    final later = await repository.addBookmark(
      recording.id,
      2000,
      label: '  later  ',
    );
    final earlier = await repository.addBookmark(recording.id, 1000);
    final bookmarks = repository.watchBookmarks(recording.id);

    expect(await bookmarks.first, [earlier, later]);

    await repository.renameBookmark(earlier.id, ' renamed ');
    await repository.renameBookmark(later.id, '');
    final renamed = await bookmarks.first;
    expect(renamed.first.label, 'renamed');
    expect(renamed.last.label, isNull);

    await repository.deleteBookmark(earlier.id);
    expect(await bookmarks.first, [renamed.last]);
  });

  test(
    'transcript reads, search, and export use the active run only',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rexorder-run-history-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase.memory();
      addTearDown(database.close);
      final repository = RecordingRepository(database, directory);
      final recording = await repository.createRecording(
        id: 'run-history',
        title: 'Model comparison',
      );
      await repository.replaceTranscriptSegments(recording.id, const [
        TranscriptSegmentDraft(
          index: 0,
          startMs: 0,
          endMs: 1000,
          text: 'old transcript phrase',
        ),
      ]);
      final oldRunId = (await repository.getRecording(
        recording.id,
      ))!.activeRunId!;
      final newRun = await repository.createTranscriptionRun(
        recordingId: recording.id,
        modelId: 'whisper-small',
        status: TranscriptionStatus.done,
      );
      await repository.replaceTranscriptSegments(recording.id, const [
        TranscriptSegmentDraft(
          index: 0,
          startMs: 0,
          endMs: 1000,
          text: 'new transcript phrase',
        ),
      ], runId: newRun.id);

      expect(
        (await repository.search('old transcript')).single.text,
        'old transcript phrase',
      );
      expect(await repository.search('new transcript'), isEmpty);
      expect(
        (await repository.listTranscriptSegments(recording.id)).single.text,
        'old transcript phrase',
      );

      await repository.setActiveRun(recording.id, newRun.id);
      expect(await repository.search('old transcript'), isEmpty);
      expect(
        (await repository.search('new transcript')).single.text,
        'new transcript phrase',
      );
      expect(
        (await repository.listTranscriptSegments(recording.id)).single.text,
        'new transcript phrase',
      );
      final exported = exportTxt(
        (await repository.getRecording(recording.id))!,
        await repository.listTranscriptSegments(recording.id),
        await repository.speakerNames(recording.id),
      );
      expect(exported, contains('new transcript phrase'));
      expect(exported, isNot(contains('old transcript phrase')));
      expect(oldRunId, isNot(newRun.id));
    },
  );

  test('deleteRun protects active and in-progress runs', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rexorder-delete-run-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final repository = RecordingRepository(database, directory);
    final recording = await repository.createRecording(id: 'delete-run');
    await repository.replaceTranscriptSegments(recording.id, const [
      TranscriptSegmentDraft(
        index: 0,
        startMs: 0,
        endMs: 1000,
        text: 'active transcript',
      ),
    ]);
    final activeRunId = (await repository.getRecording(
      recording.id,
    ))!.activeRunId!;
    await expectLater(repository.deleteRun(activeRunId), throwsStateError);

    final queuedRun = await repository.createTranscriptionRun(
      recordingId: recording.id,
    );
    await expectLater(repository.deleteRun(queuedRun.id), throwsStateError);

    final runningRun = await repository.createTranscriptionRun(
      recordingId: recording.id,
      status: TranscriptionStatus.running,
    );
    await expectLater(repository.deleteRun(runningRun.id), throwsStateError);

    final failedRun = await repository.createTranscriptionRun(
      recordingId: recording.id,
      status: TranscriptionStatus.failed,
    );
    await repository.replaceTranscriptSegments(recording.id, const [
      TranscriptSegmentDraft(
        index: 0,
        startMs: 1000,
        endMs: 2000,
        text: 'failed run text',
        speaker: 0,
      ),
    ], runId: failedRun.id);
    await database
        .into(database.speakerNames)
        .insert(
          SpeakerNamesCompanion.insert(
            recordingId: recording.id,
            runId: failedRun.id,
            speaker: 0,
            name: 'Temporary',
          ),
        );
    await repository.saveRunSpeakerEmbeddings(failedRun.id, [
      SpeakerRunEmbedding(
        runId: failedRun.id,
        speaker: 0,
        embedding: Float32List.fromList([1, 0]),
        speechMs: 4000,
      ),
    ]);

    await repository.deleteRun(failedRun.id);

    expect(await repository.getRun(failedRun.id), isNull);
    expect(await repository.listRunSegments(failedRun.id), isEmpty);
    expect(
      await (database.select(
        database.speakerNames,
      )..where((row) => row.runId.equals(failedRun.id))).get(),
      isEmpty,
    );
    expect(await repository.listRunSpeakerEmbeddings(failedRun.id), isEmpty);
  });

  test(
    'voiceprint enrollment, confirmation, and person deletion semantics',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rexorder-person-voiceprints-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase.memory();
      addTearDown(database.close);
      final repository = RecordingRepository(database, directory);
      final recording = await repository.createRecording(
        id: 'voiceprint-person',
      );
      final run = await repository.createTranscriptionRun(
        recordingId: recording.id,
        status: TranscriptionStatus.done,
        activate: true,
      );
      await repository.replaceTranscriptSegments(recording.id, const [
        TranscriptSegmentDraft(
          index: 0,
          startMs: 0,
          endMs: 4000,
          text: 'speaker text',
          speaker: 0,
        ),
      ], runId: run.id);
      await repository.saveRunSpeakerEmbeddings(run.id, [
        SpeakerRunEmbedding(
          runId: run.id,
          speaker: 0,
          embedding: Float32List.fromList([1, 0]),
          speechMs: 4000,
        ),
      ]);

      final personId = await repository.createPerson('Alice');
      await repository.confirmSpeaker(
        recordingId: recording.id,
        runId: run.id,
        speaker: 0,
        personId: personId,
      );
      expect(
        await repository.speakerNameDetails(recording.id, 0),
        isA<SpeakerNameDetails>()
            .having((details) => details.name, 'name', 'Alice')
            .having((details) => details.source, 'source', 'confirmed')
            .having((details) => details.personId, 'personId', personId),
      );
      expect((await repository.listPeople()).single.voiceprintCount, 1);
      expect((await repository.listPeople()).single.activeRecordingCount, 1);

      await repository.renamePerson(personId, 'Alicia');
      expect(
        (await repository.speakerNameDetails(recording.id, 0))!.name,
        'Alicia',
      );
      await repository.deletePerson(personId);

      final retained = await repository.speakerNameDetails(recording.id, 0);
      expect(retained!.name, 'Alicia');
      expect(retained.source, 'confirmed');
      expect(retained.personId, isNull);
      expect(await repository.listPeople(), isEmpty);
      expect(await database.select(database.personVoiceprints).get(), isEmpty);
    },
  );

  test(
    'empty manual names block rematching and stale auto names are removed',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rexorder-voiceprint-overrides-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase.memory();
      addTearDown(database.close);
      final repository = RecordingRepository(database, directory);
      final recording = await repository.createRecording(
        id: 'voiceprint-overrides',
      );
      final run = await repository.createTranscriptionRun(
        recordingId: recording.id,
        status: TranscriptionStatus.done,
        activate: true,
      );
      final personId = await repository.createPerson('Alice');
      await repository.saveRunSpeakerEmbeddings(run.id, [
        SpeakerRunEmbedding(
          runId: run.id,
          speaker: 0,
          embedding: Float32List.fromList([1, 0]),
          speechMs: 4000,
        ),
      ]);
      await database
          .into(database.personVoiceprints)
          .insert(
            PersonVoiceprintsCompanion.insert(
              personId: personId,
              embedding: Uint8List.fromList([0, 0, 128, 63, 0, 0, 0, 0]),
              speechMs: 4000,
              createdAt: DateTime.utc(2026),
            ),
          );
      await database
          .into(database.speakerNames)
          .insert(
            SpeakerNamesCompanion.insert(
              recordingId: recording.id,
              runId: run.id,
              speaker: 0,
              name: 'Alice',
              personId: Value(personId),
              source: const Value('auto'),
              matchScore: const Value(1),
            ),
          );
      await repository.rematchAll();
      expect(
        (await repository.speakerNameDetails(recording.id, 0))!.source,
        'auto',
      );

      await repository.setSpeakerName(
        recordingId: recording.id,
        speaker: 0,
        name: '',
      );
      await repository.rematchAll();
      final rejected = await repository.speakerNameDetails(recording.id, 0);
      expect(rejected!.name, '');
      expect(rejected.source, 'manual');
      expect(await repository.speakerNames(recording.id), isEmpty);

      await repository.setSpeakerName(
        recordingId: recording.id,
        speaker: 0,
        name: 'Alice',
      );
      await database
          .into(database.speakerNames)
          .insertOnConflictUpdate(
            SpeakerNamesCompanion.insert(
              recordingId: recording.id,
              runId: run.id,
              speaker: 0,
              name: 'Alice',
              personId: Value(personId),
              source: const Value('auto'),
              matchScore: const Value(1),
            ),
          );
      await repository.saveRunSpeakerEmbeddings(run.id, const []);
      await repository.rematchAll();
      expect(await repository.speakerNameDetails(recording.id, 0), isNull);
    },
  );
}
