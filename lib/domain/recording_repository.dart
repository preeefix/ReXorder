import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../data/database.dart' as db;
import 'recording.dart';
import 'transcript_segment.dart';

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
  );

  Future<void> updateTranscription({
    required String id,
    required TranscriptionStatus status,
    String? modelId,
    LanguageHint? languageHint,
    int? speakerCountHint,
    String? error,
  }) async {
    await (_database.update(
      _database.recordings,
    )..where((row) => row.id.equals(id))).write(
      db.RecordingsCompanion(
        transcriptionStatus: drift.Value(status),
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

  Future<List<Recording>> listQueuedTranscriptions() async {
    final rows =
        await (_database.select(_database.recordings)
              ..where(
                (row) => row.transcriptionStatus.equals(
                  TranscriptionStatus.queued.name,
                ),
              )
              ..orderBy([(row) => drift.OrderingTerm.asc(row.createdAt)]))
            .get();
    return rows.map(_toDomain).toList();
  }

  Future<void> requeueRunningTranscriptions() async {
    await (_database.update(_database.recordings)..where(
          (row) =>
              row.transcriptionStatus.equals(TranscriptionStatus.running.name),
        ))
        .write(
          const db.RecordingsCompanion(
            transcriptionStatus: drift.Value(TranscriptionStatus.queued),
          ),
        );
  }

  Stream<List<TranscriptSegment>> watchTranscriptSegments(String recordingId) {
    return (_database.select(_database.transcriptSegments)
          ..where((row) => row.recordingId.equals(recordingId))
          ..orderBy([(row) => drift.OrderingTerm.asc(row.idx)]))
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => TranscriptSegment(
                  id: row.id,
                  recordingId: row.recordingId,
                  index: row.idx,
                  startMs: row.startMs,
                  endMs: row.endMs,
                  text: row.content,
                  lang: row.lang,
                  speaker: row.speaker,
                ),
              )
              .toList(),
        );
  }

  Stream<Map<int, String>> watchSpeakerNames(String recordingId) =>
      (_database.select(_database.speakerNames)
            ..where((row) => row.recordingId.equals(recordingId)))
          .watch()
          .map((rows) => {for (final row in rows) row.speaker: row.name});

  Future<Map<int, String>> speakerNames(String recordingId) async {
    final rows = await (_database.select(
      _database.speakerNames,
    )..where((row) => row.recordingId.equals(recordingId))).get();
    return {for (final row in rows) row.speaker: row.name};
  }

  Future<void> setSpeakerName({
    required String recordingId,
    required int speaker,
    required String name,
  }) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      await (_database.delete(_database.speakerNames)..where(
            (row) =>
                row.recordingId.equals(recordingId) &
                row.speaker.equals(speaker),
          ))
          .go();
      return;
    }
    await _database
        .into(_database.speakerNames)
        .insertOnConflictUpdate(
          db.SpeakerNamesCompanion.insert(
            recordingId: recordingId,
            speaker: speaker,
            name: normalized,
          ),
        );
  }

  Future<void> clearSpeakerNames(String recordingId) async {
    await (_database.delete(
      _database.speakerNames,
    )..where((row) => row.recordingId.equals(recordingId))).go();
  }

  Future<List<TranscriptSegment>> listTranscriptSegments(
    String recordingId,
  ) async {
    final rows =
        await (_database.select(_database.transcriptSegments)
              ..where((row) => row.recordingId.equals(recordingId))
              ..orderBy([(row) => drift.OrderingTerm.asc(row.idx)]))
            .get();
    return rows
        .map(
          (row) => TranscriptSegment(
            id: row.id,
            recordingId: row.recordingId,
            index: row.idx,
            startMs: row.startMs,
            endMs: row.endMs,
            text: row.content,
            lang: row.lang,
            speaker: row.speaker,
          ),
        )
        .toList();
  }

  Future<void> replaceTranscriptSegments(
    String recordingId,
    List<TranscriptSegmentDraft> segments,
  ) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.transcriptSegments,
      )..where((row) => row.recordingId.equals(recordingId))).go();
      for (final segment in segments) {
        await _database
            .into(_database.transcriptSegments)
            .insert(
              db.TranscriptSegmentsCompanion.insert(
                recordingId: recordingId,
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
    await (_database.delete(
      _database.transcriptSegments,
    )..where((row) => row.recordingId.equals(recordingId))).go();
  }
}
