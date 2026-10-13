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
  IntColumn get speakerCountHint => integer().nullable()();

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

class SpeakerNames extends Table {
  TextColumn get recordingId => text()();
  IntColumn get speaker => integer()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {recordingId, speaker};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (recording_id) REFERENCES recordings (id) ON DELETE CASCADE',
  ];
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordingId => text()();
  IntColumn get positionMs => integer()();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (recording_id) REFERENCES recordings (id) ON DELETE CASCADE',
  ];
}

@DriftDatabase(
  tables: [Recordings, TranscriptSegments, SpeakerNames, Bookmarks],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open(File file) : super(NativeDatabase.createInBackground(file));

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

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
      if (from < 3) {
        await migrator.addColumn(recordings, recordings.speakerCountHint);
        await migrator.createTable(speakerNames);
      }
      if (from < 4) {
        await migrator.createTable(bookmarks);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
