import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../asr/streaming_wav_reader.dart';
import '../data/providers.dart';
import '../models/model_catalog.dart';
import '../models/model_manager.dart';
import '../processing/transcription_worker.dart';

class BenchmarkResult {
  const BenchmarkResult({
    required this.model,
    required this.sample,
    required this.loadSeconds,
    required this.decodeSeconds,
    required this.audioSeconds,
    required this.text,
  });

  final String model;
  final String sample;
  final double loadSeconds;
  final double decodeSeconds;
  final double audioSeconds;
  final String text;

  double get realTimeFactor =>
      audioSeconds == 0 ? 0 : decodeSeconds / audioSeconds;
}

class BenchmarkScreen extends ConsumerStatefulWidget {
  const BenchmarkScreen({super.key});

  @override
  ConsumerState<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends ConsumerState<BenchmarkScreen> {
  bool _running = false;
  String? _error;
  List<BenchmarkResult> _results = const [];

  Future<void> _run() async {
    setState(() {
      _running = true;
      _error = null;
      _results = const [];
    });
    TranscriptionWorker? worker;
    try {
      final client = ref.read(modelImportClientProvider);
      final installed = await client.listInstalled();
      final modelsDirectory = ref.read(modelsDirectoryProvider);
      worker = await TranscriptionWorker.spawn(
        modelsDirectory: modelsDirectory,
      );
      final results = <BenchmarkResult>[];
      final models = modelCatalog.where(
        (model) =>
            model.isAsr &&
            model.files.every(
              (file) => installed[model.id]?.contains(file) ?? false,
            ),
      );
      final samples = <File>[];
      for (final model in models) {
        final modelDirectory = Directory(
          p.join(modelsDirectory.path, model.id),
        );
        final modelSamples = await modelDirectory
            .list(recursive: true)
            .where((entity) => entity is File && entity.path.endsWith('.wav'))
            .cast<File>()
            .toList();
        samples.addAll(modelSamples);
      }
      samples.sort((left, right) => left.path.compareTo(right.path));
      for (final model in models) {
        if (samples.isEmpty) break;
        final loadTimer = Stopwatch()..start();
        await worker.openModel(model: model, language: 'auto');
        loadTimer.stop();
        for (final sample in samples) {
          final sampleCount = await StreamingWavReader(sample).sampleCount;
          final audioSeconds = sampleCount / 16000;
          final timer = Stopwatch()..start();
          final transcript = await worker.transcribe(
            wavFile: sample,
            startSample: 0,
            endSample: sampleCount,
          );
          timer.stop();
          results.add(
            BenchmarkResult(
              model: model.displayName,
              sample:
                  '${p.basename(p.dirname(p.dirname(sample.path)))}:'
                  '${p.basename(sample.path)}',
              loadSeconds: loadTimer.elapsedMilliseconds / 1000,
              decodeSeconds: timer.elapsedMilliseconds / 1000,
              audioSeconds: audioSeconds,
              text: transcript.text,
            ),
          );
          if (mounted) setState(() => _results = List.of(results));
        }
        await worker.closeModel();
      }
      if (results.isEmpty) {
        setState(
          () => _error = 'Import an ASR model with test WAV samples first.',
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      await worker?.close();
      if (mounted) setState(() => _running = false);
    }
  }

  String get _plainText {
    final rows = <String>[
      'Model\tSample\tLoad s\tDecode s\tAudio s\tRTF\tTranscript',
      for (final result in _results)
        '${result.model}\t${result.sample}\t'
            '${result.loadSeconds.toStringAsFixed(2)}\t'
            '${result.decodeSeconds.toStringAsFixed(2)}\t'
            '${result.audioSeconds.toStringAsFixed(2)}\t'
            '${result.realTimeFactor.toStringAsFixed(3)}\t${result.text}',
    ];
    return rows.join('\n');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Benchmark'),
      actions: [
        IconButton(
          tooltip: 'Copy results',
          onPressed: _results.isEmpty
              ? null
              : () => Clipboard.setData(ClipboardData(text: _plainText)),
          icon: const Icon(Icons.copy),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Runs installed ASR models against imported test WAVs.'),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _running ? null : _run,
          icon: const Icon(Icons.play_arrow),
          label: Text(_running ? 'Benchmark running…' : 'Run benchmark'),
        ),
        if (_running) const LinearProgressIndicator(),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        for (final result in _results)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${result.model} · ${result.sample}'),
                  Text(
                    'Load ${result.loadSeconds.toStringAsFixed(2)}s · '
                    'Decode ${result.decodeSeconds.toStringAsFixed(2)}s · '
                    'Audio ${result.audioSeconds.toStringAsFixed(2)}s · '
                    'RTF ${result.realTimeFactor.toStringAsFixed(3)}',
                  ),
                  Text(result.text),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
