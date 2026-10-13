import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../data/database.dart' as db;
import 'recording.dart';

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
  );
}
