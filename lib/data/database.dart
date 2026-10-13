import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

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
  TextColumn get activeRunId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TranscriptSegments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordingId => text()();
  TextColumn get runId => text().nullable()();
  IntColumn get idx => integer()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  TextColumn get content => text().nullable().named('text')();
  TextColumn get lang => text().nullable()();
  IntColumn get speaker => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {runId, idx},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (recording_id) REFERENCES recordings (id) ON DELETE CASCADE',
    'FOREIGN KEY (run_id) REFERENCES transcription_runs (id) ON DELETE CASCADE',
  ];
}

class TranscriptionRuns extends Table {
  TextColumn get id => text()();
  TextColumn get recordingId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get asrModelId => text().nullable()();
  TextColumn get languageHint => textEnum<LanguageHint>()();
  IntColumn get speakerCountHint => integer().nullable()();
  BoolColumn get diarized => boolean().withDefault(const Constant(false))();
  TextColumn get status => textEnum<TranscriptionStatus>()();
  TextColumn get error => text().nullable()();
  IntColumn get processingMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (recording_id) REFERENCES recordings (id) ON DELETE CASCADE',
  ];
}

class SpeakerNames extends Table {
  TextColumn get recordingId => text()();
  TextColumn get runId => text()();
  IntColumn get speaker => integer()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {runId, speaker};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (recording_id) REFERENCES recordings (id) ON DELETE CASCADE',
    'FOREIGN KEY (run_id) REFERENCES transcription_runs (id) ON DELETE CASCADE',
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
  tables: [
    Recordings,
    TranscriptionRuns,
    TranscriptSegments,
    SpeakerNames,
    Bookmarks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open(File file) : super(NativeDatabase.createInBackground(file));

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 5;

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
      if (from < 5) {
        await migrator.addColumn(recordings, recordings.activeRunId);
        await migrator.createTable(transcriptionRuns);

        final segmentRows = await customSelect('''
          SELECT recording_id,
                 COUNT(*) AS segment_count,
                 MAX(CASE WHEN speaker IS NOT NULL THEN 1 ELSE 0 END) AS diarized
          FROM transcript_segments
          GROUP BY recording_id
        ''').get();
        final segmentCounts = {
          for (final row in segmentRows)
            row.read<String>('recording_id'): (
              row.read<int>('segment_count'),
              row.read<int>('diarized') != 0,
            ),
        };
        final speakerRows = await customSelect(
          'SELECT DISTINCT recording_id FROM speaker_names',
        ).get();
        final recordingsWithNames = {
          for (final row in speakerRows) row.read<String>('recording_id'),
        };
        final uuid = const Uuid();
        final oldRecordings = await select(recordings).get();
        for (final recording in oldRecordings) {
          final hasSegments = (segmentCounts[recording.id]?.$1 ?? 0) > 0;
          if (!hasSegments &&
              recording.transcriptionStatus == TranscriptionStatus.none &&
              !recordingsWithNames.contains(recording.id)) {
            continue;
          }
          final runId = uuid.v4();
          final status = recording.transcriptionStatus;
          final completedAt =
              status == TranscriptionStatus.done ||
                  status == TranscriptionStatus.failed
              ? recording.createdAt
              : null;
          await into(transcriptionRuns).insert(
            TranscriptionRunsCompanion.insert(
              id: runId,
              recordingId: recording.id,
              createdAt: recording.createdAt,
              completedAt: Value(completedAt),
              asrModelId: Value(recording.asrModelId),
              languageHint: recording.languageHint,
              speakerCountHint: Value(recording.speakerCountHint),
              diarized: Value(segmentCounts[recording.id]?.$2 ?? false),
              status: status,
              error: Value(recording.transcriptionError),
            ),
          );
          await (update(recordings)
                ..where((row) => row.id.equals(recording.id)))
              .write(RecordingsCompanion(activeRunId: Value(runId)));
        }

        await migrator.alterTable(
          TableMigration(
            transcriptSegments,
            newColumns: [transcriptSegments.runId],
            columnTransformer: {
              transcriptSegments.runId: CustomExpression(
                '(SELECT active_run_id FROM recordings '
                'WHERE recordings.id = transcript_segments.recording_id)',
              ),
            },
          ),
        );
        await migrator.alterTable(
          TableMigration(
            speakerNames,
            newColumns: [speakerNames.runId],
            columnTransformer: {
              speakerNames.runId: CustomExpression(
                '(SELECT active_run_id FROM recordings '
                'WHERE recordings.id = speaker_names.recording_id)',
              ),
            },
          ),
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
