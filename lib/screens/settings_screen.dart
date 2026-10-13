import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/recording.dart';
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
    if (!mounted) return;
    setState(() {
      _autoTranscribe = auto;
      _chargingOnly = chargingOnly;
      _language = LanguageHint.values.firstWhere(
        (value) => value.name == language,
        orElse: () => LanguageHint.auto,
      );
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
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
}
