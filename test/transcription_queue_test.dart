import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/asr/asr_engine.dart';
import 'package:rexorder/asr/vad_segmenter.dart';
import 'package:rexorder/data/database.dart' hide Recording;
import 'package:rexorder/domain/recording.dart';
import 'package:rexorder/domain/recording_repository.dart';
import 'package:rexorder/domain/transcript_segment.dart';
import 'package:rexorder/models/model_catalog.dart';
import 'package:rexorder/models/model_import_client.dart';
import 'package:rexorder/processing/transcription_queue.dart';
import 'package:rexorder/processing/transcription_worker.dart';

void main() {
  test('resume skips segments that already have text', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('resume');
    await fixture.repository.replaceTranscriptSegments(recording.id, const [
      TranscriptSegmentDraft(
        index: 0,
        startMs: 0,
        endMs: 500,
        text: 'already saved',
        lang: 'en',
      ),
      TranscriptSegmentDraft(index: 1, startMs: 500, endMs: 1000),
    ]);
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
      modelId: 'whisper-small',
      languageHint: LanguageHint.en,
    );

    final processor = _FakeProcessor()..failSegmentation = true;
    final queue = fixture.queue(processor);
    await queue.processQueue();

    final segments = await fixture.repository.listTranscriptSegments(
      recording.id,
    );
    expect(processor.segmentCalls, 0);
    expect(processor.transcribedPaths, [recording.fileName]);
    expect(segments.map((segment) => segment.text), [
      'already saved',
      'recognized',
    ]);
    expect(
      (await fixture.repository.getRecording(
        recording.id,
      ))!.transcriptionStatus,
      TranscriptionStatus.done,
    );
  });

  test('re-transcribe clears prior segments before VAD and decoding', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('reset');
    await fixture.repository.replaceTranscriptSegments(recording.id, const [
      TranscriptSegmentDraft(
        index: 0,
        startMs: 0,
        endMs: 300,
        text: 'old text',
        lang: 'en',
      ),
    ]);
    final processor = _FakeProcessor()
      ..ranges = [const SpeechSampleRange(160, 320)];
    final queue = fixture.queue(processor);
    await queue.enqueue(
      recording.id,
      modelId: 'whisper-small',
      language: LanguageHint.ja,
      retranscribe: true,
    );
    await queue.processQueue();

    final segments = await fixture.repository.listTranscriptSegments(
      recording.id,
    );
    expect(processor.segmentCalls, 1);
    expect(segments, hasLength(1));
    expect(segments.single.startMs, 10);
    expect(segments.single.endMs, 20);
    expect(segments.single.text, 'recognized');
  });

  test('failed job records its error and queue continues', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final first = await fixture.recording('first');
    final second = await fixture.recording('second');
    for (final recording in [first, second]) {
      await fixture.repository.updateTranscription(
        id: recording.id,
        status: TranscriptionStatus.queued,
        modelId: 'whisper-small',
      );
    }
    final processor = _FakeProcessor()..failedPaths.add('first.wav');
    final queue = fixture.queue(processor);
    await queue.processQueue();

    final failed = (await fixture.repository.getRecording(first.id))!;
    final completed = (await fixture.repository.getRecording(second.id))!;
    expect(failed.transcriptionStatus, TranscriptionStatus.failed);
    expect(failed.transcriptionError, contains('synthetic failure'));
    expect(completed.transcriptionStatus, TranscriptionStatus.done);
  });

  test('startup moves running jobs back to queued', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('interrupted');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.running,
    );

    await fixture.repository.requeueRunningTranscriptions();

    expect(
      (await fixture.repository.getRecording(
        recording.id,
      ))!.transcriptionStatus,
      TranscriptionStatus.queued,
    );
  });
}

class _Fixture {
  _Fixture(
    this.directory,
    this.database,
    this.repository,
    this.modelsDirectory,
  );

  final Directory directory;
  final AppDatabase database;
  final RecordingRepository repository;
  final Directory modelsDirectory;

  static Future<_Fixture> create() async {
    final directory = await Directory.systemTemp.createTemp('rexorder-queue-');
    final recordings = Directory('${directory.path}/recordings')
      ..createSync(recursive: true);
    final models = Directory('${directory.path}/models');
    Directory('${models.path}/silero-vad').createSync(recursive: true);
    File('${models.path}/silero-vad/silero_vad.onnx').writeAsBytesSync([1]);
    for (final file in modelCatalog.firstWhere((model) => model.isAsr).files) {
      if (file.startsWith('test_wavs/')) continue;
      File('${models.path}/whisper-small/$file')
        ..createSync(recursive: true)
        ..writeAsBytesSync([1]);
    }
    final database = AppDatabase.memory();
    var now = DateTime(2026, 1, 1);
    final fixture = _Fixture(
      directory,
      database,
      RecordingRepository(
        database,
        recordings,
        now: () {
          final value = now;
          now = value.add(const Duration(seconds: 1));
          return value;
        },
      ),
      models,
    );
    return fixture;
  }

  Future<Recording> recording(String id) async {
    final recording = await repository.createRecording(id: id);
    await repository.markReady(id, 1000);
    await File('${directory.path}/recordings/$id.wav').writeAsBytes([1]);
    return recording;
  }

  TranscriptionQueue queue(_FakeProcessor processor) => TranscriptionQueue(
    repository: repository,
    recordingsDirectory: Directory('${directory.path}/recordings'),
    modelsDirectory: modelsDirectory,
    modelClient: _FakeModelClient(),
    processor: processor,
    startService: (_) async {},
    updateService: (_, _, _) async {},
    stopService: () async {},
  );

  Future<void> dispose() async {
    await database.close();
    await directory.delete(recursive: true);
  }
}

class _FakeModelClient implements ModelImportClient {
  @override
  Stream<ModelImportProgress> get progress => const Stream.empty();

  @override
  Future<bool> delete(String modelId) async => true;

  @override
  Future<String> importModel(String uri, CatalogModel model) async => '';

  @override
  Future<Map<String, List<String>>> listInstalled() async => {
    'silero-vad': ['silero_vad.onnx'],
    'whisper-small': modelCatalog[1].files,
  };

  @override
  Future<String?> pickDocument() async => null;
}

class _FakeProcessor implements TranscriptionProcessor {
  final failedPaths = <String>{};
  final transcribedPaths = <String>[];
  List<SpeechSampleRange> ranges = [const SpeechSampleRange(0, 160)];
  int segmentCalls = 0;
  bool failSegmentation = false;

  @override
  Future<void> closeModel() async {}

  @override
  Future<void> openModel({
    required CatalogModel model,
    required String language,
  }) async {}

  @override
  Future<List<SpeechSampleRange>> segment(
    File wavFile,
    String vadModelPath,
  ) async {
    segmentCalls++;
    if (failSegmentation) throw StateError('Unexpected VAD run.');
    return ranges;
  }

  @override
  Future<AsrTranscript> transcribe({
    required File wavFile,
    required int startSample,
    required int endSample,
  }) async {
    transcribedPaths.add(wavFile.path.split('/').last);
    if (failedPaths.contains(wavFile.path.split('/').last)) {
      throw StateError('synthetic failure');
    }
    return const AsrTranscript(text: 'recognized', language: 'ja');
  }
}
