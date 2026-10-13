import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/data/database.dart';
import 'package:rexorder/domain/recording.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test(
    'migrates v1 recordings to v2 with default transcription values',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rexorder-migration-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/v1.sqlite');
      final connection = sqlite.sqlite3.open(file.path);
      connection.execute('''
      CREATE TABLE recordings (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        duration_ms INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        sample_rate INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');
      connection.execute('''
      INSERT INTO recordings
        (id, title, created_at, duration_ms, file_name, sample_rate, status)
      VALUES ('legacy', 'Legacy note', 1767261600000, 1500, 'legacy.wav', 16000, 'ready')
    ''');
      connection.execute('PRAGMA user_version = 1');
      connection.close();

      final database = AppDatabase.open(file);
      addTearDown(database.close);
      final recording = await (database.select(
        database.recordings,
      )..where((row) => row.id.equals('legacy'))).getSingle();

      expect(recording.title, 'Legacy note');
      expect(recording.durationMs, 1500);
      expect(recording.transcriptionStatus.name, 'none');
      expect(recording.languageHint.name, 'auto');
      expect(recording.asrModelId, isNull);
      expect(recording.transcriptionError, isNull);
      expect(recording.speakerCountHint, isNull);
      expect(await database.select(database.transcriptSegments).get(), isEmpty);
    },
  );

  test('migrates v2 speaker data to v3', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rexorder-migration-v2-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/v2.sqlite');
    final connection = sqlite.sqlite3.open(file.path);
    connection.execute('''
      CREATE TABLE recordings (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        duration_ms INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        sample_rate INTEGER NOT NULL,
        status TEXT NOT NULL,
        transcription_status TEXT NOT NULL DEFAULT 'none',
        language_hint TEXT NOT NULL DEFAULT 'auto',
        asr_model_id TEXT,
        transcription_error TEXT
      )
    ''');
    connection.execute('''
      CREATE TABLE transcript_segments (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        recording_id TEXT NOT NULL,
        idx INTEGER NOT NULL,
        start_ms INTEGER NOT NULL,
        end_ms INTEGER NOT NULL,
        text TEXT,
        lang TEXT,
        speaker INTEGER,
        FOREIGN KEY (recording_id) REFERENCES recordings (id)
          ON DELETE CASCADE,
        UNIQUE (recording_id, idx)
      )
    ''');
    connection.execute('''
      INSERT INTO recordings
        (id, title, created_at, duration_ms, file_name, sample_rate, status)
      VALUES ('legacy-v2', 'Legacy v2', 1767261600000, 1500, 'legacy.wav', 16000, 'ready')
    ''');
    connection.execute('''
      INSERT INTO transcript_segments
        (recording_id, idx, start_ms, end_ms, text, speaker)
      VALUES ('legacy-v2', 0, 0, 800, 'kept', 2)
    ''');
    connection.execute('PRAGMA user_version = 2');
    connection.close();

    final database = AppDatabase.open(file);
    addTearDown(database.close);
    final recording = await database.select(database.recordings).getSingle();
    final segment = await database
        .select(database.transcriptSegments)
        .getSingle();

    expect(recording.speakerCountHint, isNull);
    expect(segment.speaker, 2);
    expect(await database.select(database.speakerNames).get(), isEmpty);
  });

  test(
    'migrates v3 rows to v4 bookmarks without losing existing data',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rexorder-migration-v3-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/v3.sqlite');
      final connection = sqlite.sqlite3.open(file.path);
      connection.execute('''
      CREATE TABLE recordings (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        duration_ms INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        sample_rate INTEGER NOT NULL,
        status TEXT NOT NULL,
        transcription_status TEXT NOT NULL DEFAULT 'none',
        language_hint TEXT NOT NULL DEFAULT 'auto',
        asr_model_id TEXT,
        transcription_error TEXT,
        speaker_count_hint INTEGER
      )
    ''');
      connection.execute('''
      CREATE TABLE transcript_segments (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        recording_id TEXT NOT NULL,
        idx INTEGER NOT NULL,
        start_ms INTEGER NOT NULL,
        end_ms INTEGER NOT NULL,
        text TEXT,
        lang TEXT,
        speaker INTEGER,
        FOREIGN KEY (recording_id) REFERENCES recordings (id)
          ON DELETE CASCADE,
        UNIQUE (recording_id, idx)
      )
    ''');
      connection.execute('''
      CREATE TABLE speaker_names (
        recording_id TEXT NOT NULL,
        speaker INTEGER NOT NULL,
        name TEXT NOT NULL,
        PRIMARY KEY (recording_id, speaker),
        FOREIGN KEY (recording_id) REFERENCES recordings (id)
          ON DELETE CASCADE
      )
    ''');
      connection.execute('''
      INSERT INTO recordings
        (id, title, created_at, duration_ms, file_name, sample_rate, status,
         speaker_count_hint)
      VALUES ('legacy-v3', 'Legacy v3', 1767261600000, 1500, 'legacy.wav',
              16000, 'ready', 3)
    ''');
      connection.execute('''
      INSERT INTO transcript_segments
        (recording_id, idx, start_ms, end_ms, text, speaker)
      VALUES ('legacy-v3', 0, 0, 800, 'preserved transcript', 2)
    ''');
      connection.execute('''
      INSERT INTO speaker_names (recording_id, speaker, name)
      VALUES ('legacy-v3', 2, 'Alice')
    ''');
      connection.execute('PRAGMA user_version = 3');
      connection.close();

      final database = AppDatabase.open(file);
      addTearDown(database.close);
      final recording = await database.select(database.recordings).getSingle();
      final segment = await database
          .select(database.transcriptSegments)
          .getSingle();
      final speakerName = await database
          .select(database.speakerNames)
          .getSingle();

      expect(recording.title, 'Legacy v3');
      expect(recording.speakerCountHint, 3);
      expect(segment.content, 'preserved transcript');
      expect(speakerName.name, 'Alice');
      expect(await database.select(database.bookmarks).get(), isEmpty);
    },
  );

  test(
    'migrates v4 transcripts and statuses into transcription runs',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rexorder-migration-v4-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/v4.sqlite');
      final connection = sqlite.sqlite3.open(file.path);
      connection.execute('''
      CREATE TABLE recordings (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        duration_ms INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        sample_rate INTEGER NOT NULL,
        status TEXT NOT NULL,
        transcription_status TEXT NOT NULL DEFAULT 'none',
        language_hint TEXT NOT NULL DEFAULT 'auto',
        asr_model_id TEXT,
        transcription_error TEXT,
        speaker_count_hint INTEGER
      )
    ''');
      connection.execute('''
      CREATE TABLE transcript_segments (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        recording_id TEXT NOT NULL,
        idx INTEGER NOT NULL,
        start_ms INTEGER NOT NULL,
        end_ms INTEGER NOT NULL,
        text TEXT,
        lang TEXT,
        speaker INTEGER,
        FOREIGN KEY (recording_id) REFERENCES recordings (id)
          ON DELETE CASCADE,
        UNIQUE (recording_id, idx)
      )
    ''');
      connection.execute('''
      CREATE TABLE speaker_names (
        recording_id TEXT NOT NULL,
        speaker INTEGER NOT NULL,
        name TEXT NOT NULL,
        PRIMARY KEY (recording_id, speaker),
        FOREIGN KEY (recording_id) REFERENCES recordings (id)
          ON DELETE CASCADE
      )
    ''');
      connection.execute('''
      CREATE TABLE bookmarks (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        recording_id TEXT NOT NULL,
        position_ms INTEGER NOT NULL,
        label TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (recording_id) REFERENCES recordings (id)
          ON DELETE CASCADE
      )
    ''');
      connection.execute('''
      INSERT INTO recordings
        (id, title, created_at, duration_ms, file_name, sample_rate, status,
         transcription_status, language_hint, asr_model_id, speaker_count_hint)
      VALUES
        ('with-transcript', 'Transcript', 1767261600000, 1500, 'one.wav',
         16000, 'ready', 'done', 'ja', 'sense-voice', 2),
        ('queued-without-segments', 'Queued', 1767261660000, 2500, 'two.wav',
         16000, 'ready', 'queued', 'en', 'whisper-small', NULL)
    ''');
      connection.execute('''
      INSERT INTO transcript_segments
        (recording_id, idx, start_ms, end_ms, text, lang, speaker)
      VALUES ('with-transcript', 0, 0, 800, 'preserved v4 transcript', 'ja', 1)
    ''');
      connection.execute('''
      INSERT INTO speaker_names (recording_id, speaker, name)
      VALUES ('with-transcript', 1, 'Alice')
    ''');
      connection.execute('PRAGMA user_version = 4');
      connection.close();

      final database = AppDatabase.open(file);
      addTearDown(database.close);
      final recordings = {
        for (final row in await database.select(database.recordings).get())
          row.id: row,
      };
      final runs = await database.select(database.transcriptionRuns).get();
      final segments = await database.select(database.transcriptSegments).get();
      final speakerNames = await database.select(database.speakerNames).get();
      final byRecording = {for (final run in runs) run.recordingId: run};

      expect(runs, hasLength(2));
      expect(recordings['with-transcript']!.activeRunId, isNotNull);
      expect(
        byRecording['with-transcript']!.createdAt,
        recordings['with-transcript']!.createdAt,
      );
      expect(byRecording['with-transcript']!.status, TranscriptionStatus.done);
      expect(byRecording['with-transcript']!.diarized, isTrue);
      expect(segments.single.runId, byRecording['with-transcript']!.id);
      expect(speakerNames.single.runId, byRecording['with-transcript']!.id);
      expect(speakerNames.single.name, 'Alice');
      expect(
        recordings['queued-without-segments']!.activeRunId,
        byRecording['queued-without-segments']!.id,
      );
      expect(
        byRecording['queued-without-segments']!.status,
        TranscriptionStatus.queued,
      );
      expect(
        await (database.select(database.transcriptSegments)..where(
              (row) => row.recordingId.equals('queued-without-segments'),
            ))
            .get(),
        isEmpty,
      );
    },
  );
}
