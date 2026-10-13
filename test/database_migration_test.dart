import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/data/database.dart';
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
      expect(await database.select(database.transcriptSegments).get(), isEmpty);
    },
  );
}
