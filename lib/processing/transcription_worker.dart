import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart';

import '../asr/asr_engine.dart';
import '../asr/diarizer.dart';
import '../asr/streaming_wav_reader.dart';
import '../asr/vad_segmenter.dart';
import '../models/model_catalog.dart';
import '../voiceprint/voiceprint_math.dart';

class SpeakerTimeRange {
  const SpeakerTimeRange(this.startMs, this.endMs);

  final int startMs;
  final int endMs;
}

class SpeakerEmbeddingResult {
  const SpeakerEmbeddingResult({
    required this.speaker,
    required this.embedding,
    required this.speechMs,
  });

  final int speaker;
  final Float32List embedding;
  final int speechMs;
}

abstract interface class TranscriptionProcessor {
  Future<List<SpeechSampleRange>> segment(File wavFile, String vadModelPath);
  Future<List<SpeakerTurn>> diarize(
    File wavFile, {
    required String segmentationModelPath,
    required String embeddingModelPath,
    required int? speakerCountHint,
    required void Function(int done, int total) onProgress,
  });
  Future<List<SpeakerEmbeddingResult>> embedSpeakers(
    File wavFile,
    Map<int, List<SpeakerTimeRange>> ranges,
    String embeddingModelPath,
  );
  Future<void> openModel({
    required CatalogModel model,
    required String language,
  });
  Future<AsrTranscript> transcribe({
    required File wavFile,
    required int startSample,
    required int endSample,
  });
  Future<void> closeModel();
}

class TranscriptionWorker implements TranscriptionProcessor {
  TranscriptionWorker._(this._responses);

  final ReceivePort _responses;
  final Map<int, Completer<Object?>> _pending = {};
  final Map<int, void Function(int, int)> _progressCallbacks = {};
  Isolate? _isolate;
  SendPort? _commands;
  int _nextRequestId = 0;
  bool _isClosed = false;

  static Future<TranscriptionWorker> spawn({
    required Directory modelsDirectory,
  }) async {
    final responses = ReceivePort();
    final worker = TranscriptionWorker._(responses);
    final ready = Completer<void>();
    responses.listen((message) {
      if (message is SendPort) {
        worker._commands = message;
        if (!ready.isCompleted) ready.complete();
        return;
      }
      final response = message as Map<Object?, Object?>;
      final id = response['id']! as int;
      final progress = response['progress'];
      if (progress != null) {
        final values = progress as List<Object?>;
        try {
          worker._progressCallbacks[id]?.call(
            values[0]! as int,
            values[1]! as int,
          );
        } catch (_) {}
        return;
      }
      final completer = worker._pending.remove(id);
      worker._progressCallbacks.remove(id);
      if (completer == null || completer.isCompleted) return;
      if (response['error'] != null) {
        completer.completeError(
          StateError(response['error'] as String),
          StackTrace.current,
        );
      } else {
        completer.complete(response['result']);
      }
    });
    worker._isolate = await Isolate.spawn(_transcriptionWorkerMain, [
      responses.sendPort,
      modelsDirectory.path,
    ], debugName: 'rexorder-transcription');
    await ready.future;
    return worker;
  }

  Future<Object?> _request(
    String action, {
    Map<String, Object?> data = const {},
    void Function(int, int)? onProgress,
  }) {
    if (_isClosed) throw StateError('Transcription worker is closed.');
    final id = _nextRequestId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;
    if (onProgress != null) _progressCallbacks[id] = onProgress;
    _commands!.send({'id': id, 'action': action, ...data});
    return completer.future;
  }

  @override
  Future<List<SpeechSampleRange>> segment(
    File wavFile,
    String vadModelPath,
  ) async {
    final value =
        await _request(
              'segment',
              data: {'wavPath': wavFile.path, 'vadModelPath': vadModelPath},
            )
            as List<Object?>;
    return value.map((range) {
      final entry = range as Map<Object?, Object?>;
      return SpeechSampleRange(entry['start']! as int, entry['end']! as int);
    }).toList();
  }

  @override
  Future<List<SpeakerTurn>> diarize(
    File wavFile, {
    required String segmentationModelPath,
    required String embeddingModelPath,
    required int? speakerCountHint,
    required void Function(int done, int total) onProgress,
  }) async {
    final value =
        await _request(
              'diarize',
              data: {
                'wavPath': wavFile.path,
                'segmentationModelPath': segmentationModelPath,
                'embeddingModelPath': embeddingModelPath,
                'speakerCountHint': speakerCountHint,
              },
              onProgress: onProgress,
            )
            as List<Object?>;
    return value.map((entry) {
      final item = entry as Map<Object?, Object?>;
      return SpeakerTurn(
        startSample: item['start']! as int,
        endSample: item['end']! as int,
        speaker: item['speaker']! as int,
      );
    }).toList();
  }

  @override
  Future<List<SpeakerEmbeddingResult>> embedSpeakers(
    File wavFile,
    Map<int, List<SpeakerTimeRange>> ranges,
    String embeddingModelPath,
  ) async {
    final value =
        await _request(
              'embedSpeakers',
              data: {
                'wavPath': wavFile.path,
                'embeddingModelPath': embeddingModelPath,
                'ranges': {
                  for (final entry in ranges.entries)
                    entry.key: [
                      for (final range in entry.value)
                        {'startMs': range.startMs, 'endMs': range.endMs},
                    ],
                },
              },
            )
            as List<Object?>;
    return [
      for (final item in value)
        SpeakerEmbeddingResult(
          speaker: (item as Map<Object?, Object?>)['speaker']! as int,
          embedding: Float32List.fromList(
            ((item)['embedding']! as List<Object?>).cast<double>(),
          ),
          speechMs: (item)['speechMs']! as int,
        ),
    ];
  }

  @override
  Future<void> openModel({
    required CatalogModel model,
    required String language,
  }) async {
    await _request(
      'openModel',
      data: {'modelId': model.id, 'language': language},
    );
  }

  @override
  Future<AsrTranscript> transcribe({
    required File wavFile,
    required int startSample,
    required int endSample,
  }) async {
    final value =
        await _request(
              'transcribe',
              data: {
                'wavPath': wavFile.path,
                'startSample': startSample,
                'endSample': endSample,
              },
            )
            as Map<Object?, Object?>;
    return AsrTranscript(
      text: value['text']! as String,
      language: value['language']! as String,
    );
  }

  @override
  Future<void> closeModel() async {
    await _request('closeModel');
  }

  Future<void> close() async {
    if (_isClosed) return;
    try {
      await _request('stop');
    } finally {
      _isClosed = true;
      _responses.close();
      _isolate?.kill(priority: Isolate.immediate);
      for (final completer in _pending.values) {
        if (!completer.isCompleted) {
          completer.completeError(StateError('Transcription worker stopped.'));
        }
      }
      _pending.clear();
    }
  }
}

void _transcriptionWorkerMain(List<Object?> arguments) {
  final replyPort = arguments[0]! as SendPort;
  final modelsDirectory = Directory(arguments[1]! as String);
  final requests = ReceivePort();
  replyPort.send(requests.sendPort);
  AsrEngine? engine;
  var requestTail = Future<void>.value();

  Future<void> handle(Map<Object?, Object?> request) async {
    final id = request['id'];
    try {
      final result = switch (request['action']) {
        'segment' => await _segmentAudio(
          request['wavPath']! as String,
          request['vadModelPath']! as String,
        ),
        'diarize' => await _diarizeAudio(
          request,
          (done, total) => replyPort.send({
            'id': id,
            'progress': [done, total],
          }),
        ),
        'embedSpeakers' => await _embedSpeakers(request),
        'openModel' => _openModel(
          modelsDirectory,
          request,
          engine,
          (value) => engine = value,
        ),
        'transcribe' => await _transcribe(
          engine!,
          request['wavPath']! as String,
          request['startSample']! as int,
          request['endSample']! as int,
        ),
        'closeModel' => _closeModel(engine, (value) => engine = value),
        'stop' => _closeModel(engine, (value) => engine = value),
        _ => throw ArgumentError('Unknown transcription worker action.'),
      };
      replyPort.send({'id': id, 'result': result});
      if (request['action'] == 'stop') requests.close();
    } catch (error) {
      replyPort.send({'id': id, 'error': error.toString()});
    }
  }

  requests.listen((message) {
    requestTail = requestTail.then(
      (_) => handle(message as Map<Object?, Object?>),
    );
  });
}

Future<List<Map<String, Object>>> _embedSpeakers(
  Map<Object?, Object?> request,
) async {
  initBindings();
  final extractor = SpeakerEmbeddingExtractor(
    config: SpeakerEmbeddingExtractorConfig(
      model: request['embeddingModelPath']! as String,
      numThreads: 1,
      debug: false,
      provider: 'cpu',
    ),
  );
  final reader = StreamingWavReader(File(request['wavPath']! as String));
  final input = request['ranges']! as Map<Object?, Object?>;
  final output = <Map<String, Object>>[];
  try {
    for (final entry in input.entries) {
      final speaker = entry.key! as int;
      final speakerRanges =
          (entry.value! as List<Object?>)
              .map((raw) {
                final range = raw as Map<Object?, Object?>;
                return SpeakerTimeRange(
                  range['startMs']! as int,
                  range['endMs']! as int,
                );
              })
              .where((range) => range.endMs - range.startMs >= 1500)
              .toList()
            ..sort(
              (left, right) => (right.endMs - right.startMs).compareTo(
                left.endMs - left.startMs,
              ),
            );
      final segments = <WeightedEmbedding>[];
      var speechMs = 0;
      for (final range in speakerRanges) {
        final remaining = 30000 - speechMs;
        if (remaining <= 0) break;
        final duration = (range.endMs - range.startMs)
            .clamp(0, remaining)
            .toInt();
        final startSample = range.startMs * 16000 ~/ 1000;
        final endSample = (range.startMs + duration) * 16000 ~/ 1000;
        if (endSample <= startSample) continue;
        final samples = await reader.readSamples(startSample, endSample);
        final stream = extractor.createStream();
        try {
          stream.acceptWaveform(samples: samples, sampleRate: 16000);
          stream.inputFinished();
          if (!extractor.isReady(stream)) continue;
          final embedding = extractor.compute(stream);
          if (embedding.isEmpty) continue;
          segments.add(
            WeightedEmbedding(normalizeEmbedding(embedding), duration),
          );
          speechMs += duration;
        } finally {
          stream.free();
        }
      }
      if (segments.isEmpty) continue;
      final embedding = weightedMeanEmbedding(segments);
      output.add({
        'speaker': speaker,
        'embedding': embedding,
        'speechMs': speechMs,
      });
    }
    return output;
  } finally {
    extractor.free();
  }
}

Future<List<Map<String, int>>> _diarizeAudio(
  Map<Object?, Object?> request,
  void Function(int done, int total) onProgress,
) async {
  final diarizer = Diarizer(
    segmentationModelPath: request['segmentationModelPath']! as String,
    embeddingModelPath: request['embeddingModelPath']! as String,
    speakerCountHint: request['speakerCountHint'] as int?,
  );
  try {
    final turns = await diarizer.diarize(
      File(request['wavPath']! as String),
      onProgress: onProgress,
    );
    return turns
        .map(
          (turn) => {
            'start': turn.startSample,
            'end': turn.endSample,
            'speaker': turn.speaker,
          },
        )
        .toList();
  } finally {
    diarizer.dispose();
  }
}

Future<List<Map<String, int>>> _segmentAudio(
  String wavPath,
  String vadModelPath,
) async {
  final segmenter = VadSegmenter(modelPath: vadModelPath);
  try {
    final ranges = await segmenter.segment(File(wavPath));
    return ranges
        .map((range) => {'start': range.startSample, 'end': range.endSample})
        .toList();
  } finally {
    segmenter.dispose();
  }
}

Object? _openModel(
  Directory modelsDirectory,
  Map<Object?, Object?> request,
  AsrEngine? current,
  void Function(AsrEngine?) setEngine,
) {
  current?.dispose();
  final model = modelById(request['modelId']! as String);
  if (model == null || !model.isAsr) {
    throw ArgumentError('Unknown ASR model.');
  }
  final directory = Directory(p.join(modelsDirectory.path, model.id));
  setEngine(
    AsrEngine(
      model: model,
      modelDirectory: directory,
      language: request['language']! as String,
    ),
  );
  return null;
}

Future<Map<String, String>> _transcribe(
  AsrEngine engine,
  String wavPath,
  int startSample,
  int endSample,
) async {
  final result = await engine.transcribeRangeAsync(
    wavFile: File(wavPath),
    startSample: startSample,
    endSample: endSample,
  );
  return {'text': result.text, 'language': result.language};
}

Object? _closeModel(AsrEngine? engine, void Function(AsrEngine?) setEngine) {
  engine?.dispose();
  setEngine(null);
  return null;
}
