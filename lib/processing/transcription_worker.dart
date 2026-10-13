import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import '../asr/asr_engine.dart';
import '../asr/vad_segmenter.dart';
import '../models/model_catalog.dart';

abstract interface class TranscriptionProcessor {
  Future<List<SpeechSampleRange>> segment(File wavFile, String vadModelPath);
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
      final completer = worker._pending.remove(response['id']);
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
    String action, [
    Map<String, Object?> data = const {},
  ]) {
    if (_isClosed) throw StateError('Transcription worker is closed.');
    final id = _nextRequestId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;
    _commands!.send({'id': id, 'action': action, ...data});
    return completer.future;
  }

  @override
  Future<List<SpeechSampleRange>> segment(
    File wavFile,
    String vadModelPath,
  ) async {
    final value =
        await _request('segment', {
              'wavPath': wavFile.path,
              'vadModelPath': vadModelPath,
            })
            as List<Object?>;
    return value.map((range) {
      final entry = range as Map<Object?, Object?>;
      return SpeechSampleRange(entry['start']! as int, entry['end']! as int);
    }).toList();
  }

  @override
  Future<void> openModel({
    required CatalogModel model,
    required String language,
  }) async {
    await _request('openModel', {'modelId': model.id, 'language': language});
  }

  @override
  Future<AsrTranscript> transcribe({
    required File wavFile,
    required int startSample,
    required int endSample,
  }) async {
    final value =
        await _request('transcribe', {
              'wavPath': wavFile.path,
              'startSample': startSample,
              'endSample': endSample,
            })
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
