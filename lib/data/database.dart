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

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Recordings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open(File file) : super(NativeDatabase.createInBackground(file));

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 1) {
        await migrator.createTable(recordings);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
