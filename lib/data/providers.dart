import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'recording_storage.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('AppDatabase must be overridden'),
);

final recordingsDirectoryProvider = Provider<Directory>(
  (ref) => throw UnimplementedError('Recordings directory must be overridden'),
);

final modelsDirectoryProvider = Provider<Directory>(
  (ref) => throw UnimplementedError('Models directory must be overridden'),
);

final recordingStorageProvider = Provider<RecordingStorage>(
  (ref) => throw UnimplementedError('Recording storage must be overridden'),
);
