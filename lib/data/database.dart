import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../domain/recording.dart';

part 'database.g.dart';

class Recordings extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get durationMs => integer()();
  TextColumn get fileName => text()();
  IntColumn get sampleRate => integer()();
  TextColumn get status => textEnum<RecordingStatus>()();
  TextColumn get transcriptionStatus =>
      textEnum<TranscriptionStatus>().withDefault(const Constant('none'))();
  TextColumn get languageHint =>
      textEnum<LanguageHint>().withDefault(const Constant('auto'))();
  TextColumn get asrModelId => text().nullable()();
  TextColumn get transcriptionError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TranscriptSegments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordingId => text()();
  IntColumn get idx => integer()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  TextColumn get content => text().nullable().named('text')();
  TextColumn get lang => text().nullable()();
  IntColumn get speaker => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {recordingId, idx},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (recording_id) REFERENCES recordings (id) ON DELETE CASCADE',
  ];
}

@DriftDatabase(tables: [Recordings, TranscriptSegments])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open(File file) : super(NativeDatabase.createInBackground(file));

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(recordings, recordings.transcriptionStatus);
        await migrator.addColumn(recordings, recordings.languageHint);
        await migrator.addColumn(recordings, recordings.asrModelId);
        await migrator.addColumn(recordings, recordings.transcriptionError);
        await migrator.createTable(transcriptSegments);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
