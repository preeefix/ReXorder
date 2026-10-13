import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../data/database.dart' as db;
import 'bookmark.dart';
import 'recording.dart';
import 'search_hit.dart';
import 'transcript_segment.dart';
import 'transcription_run.dart';

class RecordingRepository {
  RecordingRepository(
    this._database,
    this.recordingsDirectory, {
    Uuid? uuid,
    DateTime Function()? now,
  }) : _uuid = uuid ?? const Uuid(),
       _now = now ?? DateTime.now;

  final db.AppDatabase _database;
  final Directory recordingsDirectory;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<List<Recording>> listRecordings() async {
    final rows = await (_database.select(
      _database.recordings,
    )..orderBy([(row) => drift.OrderingTerm.desc(row.createdAt)])).get();
    return rows.map(_toDomain).toList();
  }

  Stream<List<Recording>> watchRecordings() {
    return (_database.select(_database.recordings)
          ..orderBy([(row) => drift.OrderingTerm.desc(row.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  Stream<Recording?> watchRecording(String id) {
    return (_database.select(_database.recordings)
          ..where((recording) => recording.id.equals(id)))
        .watch()
        .map((rows) => rows.isEmpty ? null : _toDomain(rows.single));
  }

  Future<Recording?> getRecording(String id) async {
    final row = await (_database.select(
      _database.recordings,
    )..where((recording) => recording.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<List<SearchHit>> search(String query, {int limit = 200}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || limit <= 0) return [];
    final escaped = trimmed
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final pattern = '%$escaped%';
    final rows = await _database
        .customSelect(
          r'''
          SELECT r.id AS recording_id,
                 r.title AS recording_title,
                 r.created_at AS created_at,
                 s.start_ms AS segment_start_ms,
                 s.text AS hit_text
          FROM recordings r
          JOIN transcript_segments s
            ON s.recording_id = r.id AND s.run_id = r.active_run_id
          WHERE s.text LIKE ? ESCAPE '\'
          UNION ALL
          SELECT r.id AS recording_id,
                 r.title AS recording_title,
                 r.created_at AS created_at,
                 NULL AS segment_start_ms,
                 NULL AS hit_text
          FROM recordings r
          WHERE r.title LIKE ? ESCAPE '\'
            AND NOT EXISTS (
              SELECT 1
              FROM transcript_segments s
              WHERE s.recording_id = r.id
                AND s.run_id = r.active_run_id
                AND s.text LIKE ? ESCAPE '\'
            )
          ORDER BY created_at DESC, segment_start_ms ASC
          LIMIT ?
          ''',
          variables: [
            drift.Variable.withString(pattern),
            drift.Variable.withString(pattern),
            drift.Variable.withString(pattern),
            drift.Variable.withInt(limit),
          ],
          readsFrom: {_database.recordings, _database.transcriptSegments},
        )
        .get();
    return rows
        .map(
          (row) => SearchHit(
            recordingId: row.read<String>('recording_id'),
            recordingTitle: row.read<String>('recording_title'),
            createdAt: row.read<DateTime>('created_at'),
            segmentStartMs: row.readNullable<int>('segment_start_ms'),
            text: row.readNullable<String>('hit_text'),
          ),
        )
        .toList();
  }

  Future<Recording> createRecording({String? id, String? title}) async {
    final createdAt = _now();
    final recordingId = id ?? _uuid.v4();
    final row = db.RecordingsCompanion.insert(
      id: recordingId,
      title: title ?? DateFormat('yyyy-MM-dd HH:mm').format(createdAt),
      createdAt: createdAt,
      durationMs: 0,
      fileName: '$recordingId.wav',
      sampleRate: 16000,
      status: RecordingStatus.recording,
    );
    await _database.into(_database.recordings).insert(row);
    return (await getRecording(recordingId))!;
  }

  Future<Recording> recoverRecording({
    required String id,
    required int durationMs,
    required DateTime createdAt,
  }) async {
    final existing = await getRecording(id);
    if (existing == null) {
      final title =
          'Recovered recording ${DateFormat('yyyy-MM-dd HH:mm').format(createdAt)}';
      await _database
          .into(_database.recordings)
          .insert(
            db.RecordingsCompanion.insert(
              id: id,
              title: title,
              createdAt: createdAt,
              durationMs: durationMs,
              fileName: '$id.wav',
              sampleRate: 16000,
              status: RecordingStatus.ready,
            ),
          );
    } else {
      await (_database.update(
        _database.recordings,
      )..where((row) => row.id.equals(id))).write(
        db.RecordingsCompanion(
          durationMs: drift.Value(durationMs),
          status: const drift.Value(RecordingStatus.ready),
        ),
      );
    }
    return (await getRecording(id))!;
  }

  Future<void> markReady(String id, int durationMs) async {
    await (_database.update(
      _database.recordings,
    )..where((row) => row.id.equals(id))).write(
      db.RecordingsCompanion(
        durationMs: drift.Value(durationMs),
        status: const drift.Value(RecordingStatus.ready),
      ),
    );
  }

  Future<void> rename(String id, String title) async {
    await (_database.update(_database.recordings)
          ..where((row) => row.id.equals(id)))
        .write(db.RecordingsCompanion(title: drift.Value(title)));
  }

  Future<void> delete(String id) async {
    final recording = await getRecording(id);
    if (recording == null) return;
    final file = File(p.join(recordingsDirectory.path, recording.fileName));
    if (await file.exists()) await file.delete();
    await (_database.delete(
      _database.recordings,
    )..where((row) => row.id.equals(id))).go();
  }

  Recording _toDomain(db.Recording row) => Recording(
    id: row.id,
    title: row.title,
    createdAt: row.createdAt,
    durationMs: row.durationMs,
    fileName: row.fileName,
    sampleRate: row.sampleRate,
    status: row.status,
    transcriptionStatus: row.transcriptionStatus,
    languageHint: row.languageHint,
    asrModelId: row.asrModelId,
    transcriptionError: row.transcriptionError,
    speakerCountHint: row.speakerCountHint,
    activeRunId: row.activeRunId,
  );

  Future<TranscriptionRun> createTranscriptionRun({
    required String recordingId,
    String? modelId,
    LanguageHint languageHint = LanguageHint.auto,
    int? speakerCountHint,
    TranscriptionStatus status = TranscriptionStatus.queued,
    bool activate = false,
  }) async {
    final createdAt = _now();
    final runId = _uuid.v4();
    await _database
        .into(_database.transcriptionRuns)
        .insert(
          db.TranscriptionRunsCompanion.insert(
            id: runId,
            recordingId: recordingId,
            createdAt: createdAt,
            completedAt: drift.Value(
              status == TranscriptionStatus.done ||
                      status == TranscriptionStatus.failed
                  ? createdAt
                  : null,
            ),
            asrModelId: drift.Value(modelId),
            languageHint: languageHint,
            speakerCountHint: drift.Value(speakerCountHint),
            status: status,
          ),
        );
    await (_database.update(
      _database.recordings,
    )..where((row) => row.id.equals(recordingId))).write(
      db.RecordingsCompanion(
        activeRunId: activate ? drift.Value(runId) : const drift.Value.absent(),
        transcriptionStatus: drift.Value(status),
        asrModelId: drift.Value(modelId),
        languageHint: drift.Value(languageHint),
        speakerCountHint: drift.Value(speakerCountHint),
        transcriptionError: const drift.Value(null),
      ),
    );
    return (await getRun(runId))!;
  }

  Future<void> updateTranscription({
    required String id,
    required TranscriptionStatus status,
    String? modelId,
    LanguageHint? languageHint,
    int? speakerCountHint,
    String? error,
    String? runId,
    int processingMsDelta = 0,
    bool? diarized,
  }) async {
    final recording = await getRecording(id);
    if (recording == null) return;
    var targetRunId = runId;
    if (targetRunId == null) {
      final inProgress =
          await (_database.select(_database.transcriptionRuns)
                ..where(
                  (row) =>
                      row.recordingId.equals(id) &
                      (row.status.equals(TranscriptionStatus.queued.name) |
                          row.status.equals(TranscriptionStatus.running.name)),
                )
                ..orderBy([(row) => drift.OrderingTerm.desc(row.createdAt)])
                ..limit(1))
              .getSingleOrNull();
      targetRunId = inProgress?.id ?? recording.activeRunId;
    }
    if (targetRunId == null) {
      final created = await createTranscriptionRun(
        recordingId: id,
        modelId: modelId,
        languageHint: languageHint ?? recording.languageHint,
        speakerCountHint: speakerCountHint,
        status: status,
      );
      targetRunId = created.id;
    }
    final run = await getRun(targetRunId);
    if (run == null) return;
    final completedAt =
        status == TranscriptionStatus.done ||
            status == TranscriptionStatus.failed
        ? drift.Value(_now())
        : const drift.Value<DateTime?>.absent();
    await (_database.update(
      _database.transcriptionRuns,
    )..where((row) => row.id.equals(targetRunId!))).write(
      db.TranscriptionRunsCompanion(
        status: drift.Value(status),
        completedAt: completedAt,
        asrModelId: modelId == null
            ? const drift.Value.absent()
            : drift.Value(modelId),
        languageHint: languageHint == null
            ? const drift.Value.absent()
            : drift.Value(languageHint),
        speakerCountHint: drift.Value(speakerCountHint),
        error: drift.Value(error),
        processingMs: drift.Value(run.processingMs + processingMsDelta),
        diarized: diarized == null
            ? const drift.Value.absent()
            : drift.Value(diarized),
      ),
    );
    await (_database.update(
      _database.recordings,
    )..where((row) => row.id.equals(id))).write(
      db.RecordingsCompanion(
        transcriptionStatus: drift.Value(status),
        activeRunId: status == TranscriptionStatus.done
            ? drift.Value(targetRunId)
            : const drift.Value.absent(),
        asrModelId: modelId == null
            ? const drift.Value.absent()
            : drift.Value(modelId),
        languageHint: languageHint == null
            ? const drift.Value.absent()
            : drift.Value(languageHint),
        speakerCountHint: drift.Value(speakerCountHint),
        transcriptionError: drift.Value(error),
      ),
    );
  }

  Future<List<TranscriptionJob>> listQueuedTranscriptions() async {
    final runs =
        await (_database.select(_database.transcriptionRuns)
              ..where(
                (row) => row.status.equals(TranscriptionStatus.queued.name),
              )
              ..orderBy([(row) => drift.OrderingTerm.desc(row.createdAt)]))
            .get();
    final jobs = <TranscriptionJob>[];
    for (final run in runs) {
      final recording = await getRecording(run.recordingId);
      if (recording == null) continue;
      jobs.add(TranscriptionJob(recording: recording, run: _toRun(run)));
    }
    return jobs;
  }

  Future<void> requeueRunningTranscriptions() async {
    final running =
        await (_database.select(_database.transcriptionRuns)..where(
              (row) => row.status.equals(TranscriptionStatus.running.name),
            ))
            .get();
    for (final run in running) {
      await (_database.update(
        _database.transcriptionRuns,
      )..where((row) => row.id.equals(run.id))).write(
        const db.TranscriptionRunsCompanion(
          status: drift.Value(TranscriptionStatus.queued),
        ),
      );
      await (_database.update(
        _database.recordings,
      )..where((row) => row.id.equals(run.recordingId))).write(
        const db.RecordingsCompanion(
          transcriptionStatus: drift.Value(TranscriptionStatus.queued),
        ),
      );
    }
  }

  Future<TranscriptionRun?> getRun(String runId) async {
    final row = await (_database.select(
      _database.transcriptionRuns,
    )..where((run) => run.id.equals(runId))).getSingleOrNull();
    return row == null ? null : _toRun(row);
  }

  Stream<List<TranscriptionRun>> watchRuns(String recordingId) => _database
      .customSelect(
        '''
        SELECT r.id AS run_id, r.recording_id, r.created_at, r.completed_at,
               r.asr_model_id, r.language_hint, r.speaker_count_hint,
               r.diarized, r.status, r.error, r.processing_ms,
               COUNT(s.id) AS segment_count,
               COALESCE(SUM(CASE WHEN s.text IS NOT NULL THEN 1 ELSE 0 END), 0)
                 AS done_count
        FROM transcription_runs r
        LEFT JOIN transcript_segments s ON s.run_id = r.id
        WHERE r.recording_id = ?
        GROUP BY r.id
        ORDER BY r.created_at DESC
        ''',
        variables: [drift.Variable.withString(recordingId)],
        readsFrom: {_database.transcriptionRuns, _database.transcriptSegments},
      )
      .watch()
      .map(
        (rows) => rows
            .map(
              (row) => TranscriptionRun(
                id: row.read<String>('run_id'),
                recordingId: row.read<String>('recording_id'),
                createdAt: row.read<DateTime>('created_at'),
                completedAt: row.readNullable<DateTime>('completed_at'),
                asrModelId: row.readNullable<String>('asr_model_id'),
                languageHint: LanguageHint.values.byName(
                  row.read<String>('language_hint'),
                ),
                speakerCountHint: row.readNullable<int>('speaker_count_hint'),
                diarized: row.read<bool>('diarized'),
                status: TranscriptionStatus.values.byName(
                  row.read<String>('status'),
                ),
                error: row.readNullable<String>('error'),
                processingMs: row.read<int>('processing_ms'),
                segmentCount: row.read<int>('segment_count'),
                doneCount: row.read<int>('done_count'),
              ),
            )
            .toList(),
      );

  Future<void> setActiveRun(String recordingId, String runId) async {
    final run = await getRun(runId);
    if (run == null ||
        run.recordingId != recordingId ||
        run.status != TranscriptionStatus.done) {
      throw StateError(
        'Only a completed run for this recording can be active.',
      );
    }
    await (_database.update(
      _database.recordings,
    )..where((row) => row.id.equals(recordingId))).write(
      db.RecordingsCompanion(
        activeRunId: drift.Value(run.id),
        transcriptionStatus: drift.Value(run.status),
        asrModelId: drift.Value(run.asrModelId),
        languageHint: drift.Value(run.languageHint),
        speakerCountHint: drift.Value(run.speakerCountHint),
        transcriptionError: drift.Value(run.error),
      ),
    );
  }

  Future<void> deleteRun(String runId) async {
    final run = await getRun(runId);
    if (run == null) return;
    final recording = await getRecording(run.recordingId);
    if (recording?.activeRunId == runId ||
        run.status == TranscriptionStatus.queued ||
        run.status == TranscriptionStatus.running) {
      throw StateError('The active or in-progress run cannot be deleted.');
    }
    await _database.transaction(() async {
      await (_database.delete(
        _database.transcriptSegments,
      )..where((segment) => segment.runId.equals(runId))).go();
      await (_database.delete(
        _database.speakerNames,
      )..where((speaker) => speaker.runId.equals(runId))).go();
      await (_database.delete(
        _database.transcriptionRuns,
      )..where((row) => row.id.equals(runId))).go();
    });
  }

  Stream<List<TranscriptSegment>> watchTranscriptSegments(String recordingId) {
    return _database
        .customSelect(
          '''
          SELECT s.id, s.recording_id, s.run_id, s.idx, s.start_ms, s.end_ms,
                 s.text, s.lang, s.speaker
          FROM transcript_segments s
          JOIN recordings r ON r.active_run_id = s.run_id
          WHERE r.id = ?
          ORDER BY s.idx
          ''',
          variables: [drift.Variable.withString(recordingId)],
          readsFrom: {_database.recordings, _database.transcriptSegments},
        )
        .watch()
        .map((rows) => rows.map(_segmentFromRow).toList());
  }

  Stream<List<TranscriptSegment>> watchRunSegments(String runId) => _database
      .customSelect(
        '''
        SELECT id, recording_id, run_id, idx, start_ms, end_ms, text, lang,
               speaker
        FROM transcript_segments
        WHERE run_id = ?
        ORDER BY idx
        ''',
        variables: [drift.Variable.withString(runId)],
        readsFrom: {_database.transcriptSegments},
      )
      .watch()
      .map((rows) => rows.map(_segmentFromRow).toList());

  List<TranscriptSegment> _segmentsFromRows(List<drift.QueryRow> rows) =>
      rows.map(_segmentFromRow).toList();

  TranscriptSegment _segmentFromRow(drift.QueryRow row) => TranscriptSegment(
    id: row.read<int>('id'),
    recordingId: row.read<String>('recording_id'),
    runId: row.readNullable<String>('run_id'),
    index: row.read<int>('idx'),
    startMs: row.read<int>('start_ms'),
    endMs: row.read<int>('end_ms'),
    text: row.readNullable<String>('text'),
    lang: row.readNullable<String>('lang'),
    speaker: row.readNullable<int>('speaker'),
  );

  TranscriptionRun _toRun(db.TranscriptionRun row) => TranscriptionRun(
    id: row.id,
    recordingId: row.recordingId,
    createdAt: row.createdAt,
    completedAt: row.completedAt,
    asrModelId: row.asrModelId,
    languageHint: row.languageHint,
    speakerCountHint: row.speakerCountHint,
    diarized: row.diarized,
    status: row.status,
    error: row.error,
    processingMs: row.processingMs,
  );

  Stream<Map<int, String>> watchSpeakerNames(String recordingId) => _database
      .customSelect(
        '''
            SELECT sn.speaker, sn.name
            FROM speaker_names sn
            JOIN recordings r ON r.active_run_id = sn.run_id
            WHERE r.id = ?
            ''',
        variables: [drift.Variable.withString(recordingId)],
        readsFrom: {_database.recordings, _database.speakerNames},
      )
      .watch()
      .map(
        (rows) => {
          for (final row in rows)
            row.read<int>('speaker'): row.read<String>('name'),
        },
      );

  Future<Map<int, String>> speakerNames(String recordingId) async {
    final rows = await _database
        .customSelect(
          '''
          SELECT sn.speaker, sn.name
          FROM speaker_names sn
          JOIN recordings r ON r.active_run_id = sn.run_id
          WHERE r.id = ?
          ''',
          variables: [drift.Variable.withString(recordingId)],
          readsFrom: {_database.recordings, _database.speakerNames},
        )
        .get();
    return {
      for (final row in rows)
        row.read<int>('speaker'): row.read<String>('name'),
    };
  }

  Future<void> setSpeakerName({
    required String recordingId,
    required int speaker,
    required String name,
  }) async {
    final runId =
        (await getRecording(recordingId))?.activeRunId ??
        (await createTranscriptionRun(
          recordingId: recordingId,
          status: TranscriptionStatus.done,
          activate: true,
        )).id;
    final normalized = name.trim();
    if (normalized.isEmpty) {
      await (_database.delete(_database.speakerNames)..where(
            (row) => row.runId.equals(runId) & row.speaker.equals(speaker),
          ))
          .go();
      return;
    }
    await _database
        .into(_database.speakerNames)
        .insertOnConflictUpdate(
          db.SpeakerNamesCompanion.insert(
            recordingId: recordingId,
            runId: runId,
            speaker: speaker,
            name: normalized,
          ),
        );
  }

  Future<void> clearSpeakerNames(String recordingId) async {
    final runId = (await getRecording(recordingId))?.activeRunId;
    if (runId == null) return;
    await (_database.delete(
      _database.speakerNames,
    )..where((row) => row.runId.equals(runId))).go();
  }

  Future<Bookmark> addBookmark(
    String recordingId,
    int positionMs, {
    String? label,
  }) async {
    final normalized = label?.trim();
    final id = await _database
        .into(_database.bookmarks)
        .insert(
          db.BookmarksCompanion.insert(
            recordingId: recordingId,
            positionMs: positionMs,
            label: drift.Value(
              normalized == null || normalized.isEmpty ? null : normalized,
            ),
            createdAt: _now(),
          ),
        );
    final row = await (_database.select(
      _database.bookmarks,
    )..where((bookmark) => bookmark.id.equals(id))).getSingle();
    return _toBookmark(row);
  }

  Stream<List<Bookmark>> watchBookmarks(String recordingId) =>
      (_database.select(_database.bookmarks)
            ..where((row) => row.recordingId.equals(recordingId))
            ..orderBy([
              (row) => drift.OrderingTerm.asc(row.positionMs),
              (row) => drift.OrderingTerm.asc(row.id),
            ]))
          .watch()
          .map((rows) => rows.map(_toBookmark).toList());

  Future<void> renameBookmark(int id, String? label) async {
    final normalized = label?.trim();
    await (_database.update(
      _database.bookmarks,
    )..where((row) => row.id.equals(id))).write(
      db.BookmarksCompanion(
        label: drift.Value(
          normalized == null || normalized.isEmpty ? null : normalized,
        ),
      ),
    );
  }

  Future<void> deleteBookmark(int id) async {
    await (_database.delete(
      _database.bookmarks,
    )..where((row) => row.id.equals(id))).go();
  }

  Bookmark _toBookmark(db.Bookmark row) => Bookmark(
    id: row.id,
    recordingId: row.recordingId,
    positionMs: row.positionMs,
    label: row.label,
    createdAt: row.createdAt,
  );

  Future<List<TranscriptSegment>> listTranscriptSegments(
    String recordingId,
  ) async {
    final runId = (await getRecording(recordingId))?.activeRunId;
    if (runId == null) return [];
    return listRunSegments(runId);
  }

  Future<List<TranscriptSegment>> listRunSegments(String runId) async {
    final rows = await _database
        .customSelect(
          '''
          SELECT id, recording_id, run_id, idx, start_ms, end_ms, text, lang,
                 speaker
          FROM transcript_segments
          WHERE run_id = ?
          ORDER BY idx
          ''',
          variables: [drift.Variable.withString(runId)],
          readsFrom: {_database.transcriptSegments},
        )
        .get();
    return _segmentsFromRows(rows);
  }

  Future<void> replaceTranscriptSegments(
    String recordingId,
    List<TranscriptSegmentDraft> segments, {
    String? runId,
  }) async {
    final targetRunId =
        runId ??
        (await getRecording(recordingId))?.activeRunId ??
        (await createTranscriptionRun(
          recordingId: recordingId,
          status: TranscriptionStatus.done,
          activate: true,
        )).id;
    await _database.transaction(() async {
      await (_database.delete(
        _database.transcriptSegments,
      )..where((row) => row.runId.equals(targetRunId))).go();
      for (final segment in segments) {
        await _database
            .into(_database.transcriptSegments)
            .insert(
              db.TranscriptSegmentsCompanion.insert(
                recordingId: recordingId,
                runId: drift.Value(targetRunId),
                idx: segment.index,
                startMs: segment.startMs,
                endMs: segment.endMs,
                content: drift.Value(segment.text),
                lang: drift.Value(segment.lang),
                speaker: drift.Value(segment.speaker),
              ),
            );
      }
    });
  }

  Future<void> updateTranscriptSegment({
    required int id,
    required String text,
    required String lang,
  }) async {
    await (_database.update(
      _database.transcriptSegments,
    )..where((row) => row.id.equals(id))).write(
      db.TranscriptSegmentsCompanion(
        content: drift.Value(text),
        lang: drift.Value(lang),
      ),
    );
  }

  Future<void> deleteTranscriptSegments(String recordingId) async {
    final runId = (await getRecording(recordingId))?.activeRunId;
    if (runId == null) return;
    await (_database.delete(
      _database.transcriptSegments,
    )..where((row) => row.runId.equals(runId))).go();
  }
}
