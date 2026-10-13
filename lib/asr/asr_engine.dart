import 'dart:io';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart';

import '../models/model_catalog.dart';
import 'streaming_wav_reader.dart';

class AsrTranscript {
  const AsrTranscript({required this.text, required this.language});

  final String text;
  final String language;
}

AsrTranscript normalizeTranscriptLanguage(String text, String? language) {
  final tag = RegExp(r'<\|(en|ja)\|>').firstMatch(text)?.group(1);
  final normalizedLanguage = switch ((language ?? '').toLowerCase()) {
    'en' => 'en',
    'ja' => 'ja',
    _ => tag ?? 'other',
  };
  return AsrTranscript(
    text: text.replaceAll(RegExp(r'<\|[^|]+\|>'), '').trim(),
    language: normalizedLanguage,
  );
}

class AsrEngine {
  AsrEngine._(this._recognizer);

  final OfflineRecognizer _recognizer;

  factory AsrEngine({
    required CatalogModel model,
    required Directory modelDirectory,
    required String language,
    int numThreads = 4,
  }) {
    initBindings();
    final tokens = File('${modelDirectory.path}/tokens.txt').path;
    final offlineModel = switch (model.type) {
      ModelType.whisper => OfflineModelConfig(
        whisper: OfflineWhisperModelConfig(
          encoder: File('${modelDirectory.path}/encoder.int8.onnx').path,
          decoder: File('${modelDirectory.path}/decoder.int8.onnx').path,
          language: language == 'auto' ? '' : language,
          task: 'transcribe',
        ),
        tokens: tokens,
        modelType: 'whisper',
        numThreads: numThreads,
        debug: false,
      ),
      ModelType.sensevoice => OfflineModelConfig(
        senseVoice: OfflineSenseVoiceModelConfig(
          model: File('${modelDirectory.path}/model.int8.onnx').path,
          language: language,
          useInverseTextNormalization: true,
        ),
        tokens: tokens,
        numThreads: numThreads,
        debug: false,
      ),
      ModelType.vad ||
      ModelType.segmentation ||
      ModelType.embedding => throw ArgumentError.value(
        model.id,
        'model',
        'This model cannot be used for transcription.',
      ),
    };
    return AsrEngine._(
      OfflineRecognizer(OfflineRecognizerConfig(model: offlineModel)),
    );
  }

  AsrTranscript transcribe(Float32List samples, {int sampleRate = 16000}) {
    final stream = _recognizer.createStream();
    try {
      stream.acceptWaveform(samples: samples, sampleRate: sampleRate);
      _recognizer.decode(stream);
      final result = _recognizer.getResult(stream);
      return normalizeTranscriptLanguage(result.text, result.lang);
    } finally {
      stream.free();
    }
  }

  Future<AsrTranscript> transcribeRangeAsync({
    required File wavFile,
    required int startSample,
    required int endSample,
  }) async {
    final samples = await StreamingWavReader(
      wavFile,
    ).readSamples(startSample, endSample);
    return transcribe(samples);
  }

  void dispose() => _recognizer.free();
}
