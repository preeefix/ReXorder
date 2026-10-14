import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/app.dart' show recordingsProvider;
import 'package:rexorder/data/database.dart' hide Recording;
import 'package:rexorder/data/recording_storage.dart';
import 'package:rexorder/data/providers.dart';
import 'package:rexorder/domain/recording.dart';
import 'package:rexorder/domain/recording_repository.dart';
import 'package:rexorder/l10n/generated/app_localizations.dart';
import 'package:rexorder/models/model_manager.dart';
import 'package:rexorder/processing/transcription_queue.dart';
import 'package:rexorder/screens/library_screen.dart';

void main() {
  testWidgets('Library shows the empty state and then recordings', (
    tester,
  ) async {
    final recordings = StreamController<List<Recording>>.broadcast();
    final database = AppDatabase.memory();
    final recordingsDirectory = Directory.systemTemp;
    final recordingStorage = RecordingStorage(
      internalDirectory: recordingsDirectory,
      volumeLoader: () async => const [],
    );
    final queue = TranscriptionQueue(
      repository: RecordingRepository(
        database,
        recordingsDirectory,
        recordingStorage: recordingStorage,
      ),
      modelsDirectory: Directory.systemTemp,
      isCharging: () async => false,
      chargingChanges: const Stream.empty(),
      chargingOnly: () async => false,
    );
    addTearDown(() async {
      await queue.dispose();
      recordingStorage.dispose();
      await database.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordingsProvider.overrideWith((ref) => recordings.stream),
          transcriptionQueueProvider.overrideWithValue(queue),
          recordingStorageProvider.overrideWithValue(recordingStorage),
          modelManagerProvider.overrideWith(_StaticModelManagerController.new),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );
    await tester.pump();
    recordings.add([]);
    await tester.pump();
    expect(find.text('Your recordings will appear here'), findsOneWidget);

    recordings.add([
      Recording(
        id: 'first',
        title: 'Morning notes',
        createdAt: DateTime(2026, 1, 2, 9),
        durationMs: 12500,
        fileName: 'first.wav',
        sampleRate: 16000,
        status: RecordingStatus.ready,
      ),
    ]);
    await tester.pump();
    expect(find.text('Morning notes'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await recordings.close();
  });
}

class _StaticModelManagerController extends ModelManagerController {
  @override
  ModelManagerState build() => const ModelManagerState(isLoading: false);
}
