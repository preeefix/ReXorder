import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/data/database.dart';
import 'package:rexorder/domain/recording_repository.dart';
import 'package:rexorder/domain/transcript_segment.dart';

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
}
