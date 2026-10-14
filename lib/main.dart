import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/providers.dart';
import 'data/recovery.dart';
import 'data/recording_storage.dart';
import 'domain/recording_repository.dart';
import 'processing/transcription_queue.dart';
import 'theme/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialThemeMode = await loadThemeMode();
  final supportDirectory = await getApplicationSupportDirectory();
  final recordingsDirectory = Directory(
    p.join(supportDirectory.path, 'recordings'),
  );
  final modelsDirectory = Directory(p.join(supportDirectory.path, 'models'));
  await recordingsDirectory.create(recursive: true);
  final recordingStorage = RecordingStorage(
    internalDirectory: recordingsDirectory,
  );
  await recordingStorage.refresh();
  final database = AppDatabase.open(
    File(p.join(supportDirectory.path, 'rexorder.sqlite')),
  );
  final repository = RecordingRepository(
    database,
    recordingsDirectory,
    recordingStorage: recordingStorage,
  );
  await recoverOrphanedRecordings(
    recordingStorage: recordingStorage,
    repository: repository,
  );
  await repository.requeueRunningTranscriptions();
  final transcriptionQueue = TranscriptionQueue(
    repository: repository,
    modelsDirectory: modelsDirectory,
  );
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        recordingsDirectoryProvider.overrideWithValue(recordingsDirectory),
        recordingStorageProvider.overrideWithValue(recordingStorage),
        modelsDirectoryProvider.overrideWithValue(modelsDirectory),
        transcriptionQueueProvider.overrideWithValue(transcriptionQueue),
        themeModeProvider.overrideWith(
          () => ThemeModeController(initialThemeMode),
        ),
      ],
      child: const ReXorderApp(),
    ),
  );
  unawaited(transcriptionQueue.processQueue());
}
