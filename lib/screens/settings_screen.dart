import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart' show recordingRepositoryProvider;
import '../domain/recording.dart';
import '../data/providers.dart';
import '../data/recording_mover.dart';
import '../data/recording_storage.dart';
import '../processing/transcription_queue.dart';
import '../theme/theme_mode_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoTranscribe = true;
  bool _chargingOnly = false;
  LanguageHint _language = LanguageHint.auto;
  StorageLocation _recordingStorage = StorageLocation.internal;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final auto = await TranscriptionPreferences.autoTranscribe();
    final chargingOnly = await TranscriptionPreferences.chargingOnly();
    final language = await TranscriptionPreferences.defaultLanguage();
    final recordingStorage = await RecordingStoragePreferences.getLocation();
    if (!mounted) return;
    setState(() {
      _autoTranscribe = auto;
      _chargingOnly = chargingOnly;
      _language = LanguageHint.values.firstWhere(
        (value) => value.name == language,
        orElse: () => LanguageHint.auto,
      );
      _recordingStorage = recordingStorage;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final recordingStorage = ref.watch(recordingStorageProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.model_training_outlined),
            title: const Text('Models'),
            subtitle: const Text('Import and manage local models'),
            onTap: () => context.push('/settings/models'),
          ),
          ListTile(
            leading: const Icon(Icons.speed_outlined),
            title: const Text('Benchmark'),
            subtitle: const Text('Compare installed models'),
            onTap: () => context.push('/settings/benchmark'),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('People'),
            subtitle: const Text('Manage voiceprints and speaker identities'),
            onTap: () => context.push('/settings/people'),
          ),
          const Divider(),
          ListenableBuilder(
            listenable: recordingStorage,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioGroup<StorageLocation>(
                  groupValue: _recordingStorage,
                  onChanged: (value) {
                    if (!_loaded || value == null) return;
                    unawaited(_setRecordingStorage(value));
                  },
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.storage_outlined),
                        title: Text('Storage location'),
                        subtitle: Text('Where new recordings are saved'),
                      ),
                      RadioListTile<StorageLocation>(
                        title: const Text('Internal'),
                        subtitle: Text(
                          '${_formatBytes(recordingStorage.freeBytesFor(StorageLocation.internal))} free',
                        ),
                        value: StorageLocation.internal,
                        enabled: _loaded,
                      ),
                      RadioListTile<StorageLocation>(
                        title: const Text('SD card'),
                        subtitle: Text(
                          !recordingStorage.hasSdCard
                              ? 'No SD card detected'
                              : !recordingStorage.sdAvailable
                              ? 'SD card not available'
                              : '${_formatBytes(recordingStorage.freeBytesFor(StorageLocation.sd))} free',
                        ),
                        value: StorageLocation.sd,
                        enabled: _loaded && recordingStorage.sdAvailable,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loaded ? _chooseMoveTarget : null,
                      icon: const Icon(Icons.drive_file_move_outline),
                      label: const Text('Move recordings…'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Transcribe after recording'),
            value: _autoTranscribe,
            onChanged: !_loaded
                ? null
                : (value) async {
                    setState(() => _autoTranscribe = value);
                    await TranscriptionPreferences.setAutoTranscribe(value);
                  },
          ),
          SwitchListTile(
            title: const Text('Only transcribe while charging'),
            value: _chargingOnly,
            onChanged: !_loaded
                ? null
                : (value) async {
                    setState(() => _chargingOnly = value);
                    await TranscriptionPreferences.setChargingOnly(value);
                    await ref
                        .read(transcriptionQueueProvider)
                        .chargingPreferenceChanged();
                  },
          ),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (value) {
                if (value == null) return;
                unawaited(
                  ref.read(themeModeProvider.notifier).setThemeMode(value),
                );
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Default language'),
            trailing: DropdownButton<LanguageHint>(
              value: _language,
              onChanged: !_loaded
                  ? null
                  : (value) async {
                      if (value == null) return;
                      setState(() => _language = value);
                      await TranscriptionPreferences.setDefaultLanguage(
                        value.name,
                      );
                    },
              items: const [
                DropdownMenuItem(value: LanguageHint.auto, child: Text('Auto')),
                DropdownMenuItem(
                  value: LanguageHint.en,
                  child: Text('English'),
                ),
                DropdownMenuItem(value: LanguageHint.ja, child: Text('日本語')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setRecordingStorage(StorageLocation location) async {
    setState(() => _recordingStorage = location);
    await RecordingStoragePreferences.setLocation(location);
  }

  Future<void> _chooseMoveTarget() async {
    final storage = ref.read(recordingStorageProvider);
    final destination = await showModalBottomSheet<StorageLocation>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Move all to internal storage'),
              onTap: () => Navigator.pop(context, StorageLocation.internal),
            ),
            ListTile(
              leading: const Icon(Icons.sd_storage),
              title: const Text('Move all to SD card'),
              subtitle: storage.sdAvailable
                  ? null
                  : Text(
                      storage.hasSdCard
                          ? 'SD card not available'
                          : 'No SD card detected',
                    ),
              enabled: storage.sdAvailable,
              onTap: storage.sdAvailable
                  ? () => Navigator.pop(context, StorageLocation.sd)
                  : null,
            ),
          ],
        ),
      ),
    );
    if (destination == null) return;
    await _moveRecordings(destination);
  }

  Future<void> _moveRecordings(StorageLocation destination) async {
    final progress = ValueNotifier<(int, int, String)?>(null);
    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Moving recordings'),
        content: ValueListenableBuilder<(int, int, String)?>(
          valueListenable: progress,
          builder: (context, value, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: value == null || value.$2 == 0
                    ? null
                    : value.$1 / value.$2,
              ),
              const SizedBox(height: 12),
              Text(
                value == null
                    ? 'Preparing…'
                    : '${value.$1}/${value.$2} · ${value.$3}',
              ),
            ],
          ),
        ),
      ),
    );
    try {
      final result =
          await RecordingMover(
            repository: ref.read(recordingRepositoryProvider),
            storage: ref.read(recordingStorageProvider),
          ).moveAll(
            destination,
            onProgress: (current, total, title) {
              progress.value = (current, total, title);
            },
          );
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      await dialogFuture;
      if (!mounted) return;
      final skipped = result.skippedTitles;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            skipped.isEmpty
                ? 'Moved ${result.movedCount} recordings.'
                : 'Moved ${result.movedCount}; skipped ${skipped.join(', ')}.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      await dialogFuture;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to move recordings: $error')),
        );
      }
    } finally {
      progress.dispose();
    }
  }
}

String _formatBytes(int? bytes) {
  if (bytes == null) return 'Free space unavailable';
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024).toStringAsFixed(0)} KB';
}
