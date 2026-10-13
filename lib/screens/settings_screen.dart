import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/recording.dart';
import '../processing/transcription_queue.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoTranscribe = true;
  LanguageHint _language = LanguageHint.auto;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final auto = await TranscriptionPreferences.autoTranscribe();
    final language = await TranscriptionPreferences.defaultLanguage();
    if (!mounted) return;
    setState(() {
      _autoTranscribe = auto;
      _language = LanguageHint.values.firstWhere(
        (value) => value.name == language,
        orElse: () => LanguageHint.auto,
      );
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
              DropdownMenuItem(value: LanguageHint.en, child: Text('English')),
              DropdownMenuItem(value: LanguageHint.ja, child: Text('日本語')),
            ],
          ),
        ),
      ],
    ),
  );
}
