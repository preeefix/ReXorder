import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rexorder/asr/asr_engine.dart';
import 'package:rexorder/asr/diarizer.dart';
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
  test('charging-only preference defaults off and persists', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await TranscriptionPreferences.chargingOnly(), isFalse);
    await TranscriptionPreferences.setChargingOnly(true);
    expect(await TranscriptionPreferences.chargingOnly(), isTrue);
  });

  test('preferred installed ASR follows the recommendation order', () {
    expect(defaultAsrPreference, [
      'sense-voice',
      'whisper-turbo',
      'whisper-small',
    ]);
    expect(
      preferredInstalledAsr(['whisper-small', 'whisper-turbo'])?.id,
      'whisper-turbo',
    );
    expect(
      preferredInstalledAsr(['whisper-small', 'sense-voice'])?.id,
      'sense-voice',
    );
    expect(preferredInstalledAsr(['silero-vad']), isNull);
  });

  test('queue defaults to SenseVoice when no model was requested', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('sensevoice-default');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
    );
    final processor = _FakeProcessor();
    final queue = fixture.queue(
      processor,
      installedModels: _installedWhisperAndSenseVoice(),
    );

    await queue.processQueue();

    expect(processor.openedModelIds, ['sense-voice']);
    expect(
      (await fixture.repository.getRecording(recording.id))!.asrModelId,
      'sense-voice',
    );
  });

  test('queue honors an installed explicitly requested model', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('requested-whisper');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
      modelId: 'whisper-small',
    );
    final processor = _FakeProcessor();
    final queue = fixture.queue(
      processor,
      installedModels: _installedWhisperAndSenseVoice(),
    );

    await queue.processQueue();

    expect(processor.openedModelIds, ['whisper-small']);
    expect(
      (await fixture.repository.getRecording(recording.id))!.asrModelId,
      'whisper-small',
    );
  });

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
    await fixture.repository.setSpeakerName(
      recordingId: recording.id,
      speaker: 0,
      name: 'Alice',
    );
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

  test('re-transcribe preserves prior runs and switches on success', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('reset');
    await fixture.repository.setSpeakerName(
      recordingId: recording.id,
      speaker: 0,
      name: 'Alice',
    );
    await fixture.repository.replaceTranscriptSegments(recording.id, const [
      TranscriptSegmentDraft(
        index: 0,
        startMs: 0,
        endMs: 300,
        text: 'old text',
        lang: 'en',
      ),
    ]);
    final previousRunId = (await fixture.repository.getRecording(
      recording.id,
    ))!.activeRunId!;
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
    expect(processor.diarizeCalls, 0);
    expect(segments, hasLength(1));
    expect(segments.single.startMs, 10);
    expect(segments.single.endMs, 20);
    expect(segments.single.text, 'recognized');
    expect(await fixture.repository.speakerNames(recording.id), isEmpty);
    final runs = await fixture.repository.watchRuns(recording.id).first;
    expect(runs, hasLength(2));
    expect(runs.first.id, isNot(previousRunId));
    expect(runs.first.status, TranscriptionStatus.done);
    expect(runs.last.id, previousRunId);
    expect(
      (await fixture.repository.listRunSegments(previousRunId)).single.text,
      'old text',
    );
  });

  test('failed re-transcription keeps the previous active run', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('failed-retranscription');
    await fixture.repository.replaceTranscriptSegments(recording.id, const [
      TranscriptSegmentDraft(
        index: 0,
        startMs: 0,
        endMs: 300,
        text: 'last good transcript',
        lang: 'en',
      ),
    ]);
    final previousRunId = (await fixture.repository.getRecording(
      recording.id,
    ))!.activeRunId!;
    final processor = _FakeProcessor()..failedPaths.add(recording.fileName);
    final queue = fixture.queue(processor);

    await queue.enqueue(recording.id, modelId: 'whisper-small');
    await queue.processQueue();

    final updated = (await fixture.repository.getRecording(recording.id))!;
    expect(updated.activeRunId, previousRunId);
    expect(
      (await fixture.repository.listTranscriptSegments(
        recording.id,
      )).single.text,
      'last good transcript',
    );
    expect(
      (await fixture.repository.watchRuns(recording.id).first).first.status,
      TranscriptionStatus.failed,
    );
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

  test('service failures do not fail transcription', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('service-failure');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
      modelId: 'whisper-small',
    );
    final queue = fixture.queue(
      _FakeProcessor(),
      startService: (_) async => throw StateError('service start failed'),
      updateService: (_, _, _, _) async =>
          throw StateError('service update failed'),
      stopService: () async => throw StateError('service stop failed'),
    );

    await queue.processQueue();

    final completed = (await fixture.repository.getRecording(recording.id))!;
    final segments = await fixture.repository.listTranscriptSegments(
      recording.id,
    );
    expect(completed.transcriptionStatus, TranscriptionStatus.done);
    expect(segments.single.text, 'recognized');
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

  test('automatic speaker detection assigns speaker IDs', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('diarization-auto');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
    );
    final processor = _FakeProcessor()
      ..turns = [const SpeakerTurn(startSample: 0, endSample: 160, speaker: 5)];
    final queue = fixture.queue(
      processor,
      installedModels: _installedWithDiarization(),
    );

    await queue.processQueue();

    final segments = await fixture.repository.listTranscriptSegments(
      recording.id,
    );
    expect(processor.diarizeCalls, 1);
    expect(processor.speakerCountHints, [null]);
    expect(segments.single.speaker, 0);
  });

  test('speaker count one skips diarization', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('diarization-single');
    final processor = _FakeProcessor();
    final queue = fixture.queue(
      processor,
      installedModels: _installedWithDiarization(),
    );

    await queue.enqueue(recording.id, speakerCount: 1);
    await queue.processQueue();

    expect(processor.diarizeCalls, 0);
    expect(
      (await fixture.repository.getRecording(recording.id))!.speakerCountHint,
      1,
    );
    expect(
      (await fixture.repository.listTranscriptSegments(
        recording.id,
      )).single.speaker,
      isNull,
    );
  });

  test('missing speaker models skip diarization', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('diarization-missing-models');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
    );
    final processor = _FakeProcessor();
    final queue = fixture.queue(processor);

    await queue.processQueue();

    expect(processor.diarizeCalls, 0);
    expect(
      (await fixture.repository.listTranscriptSegments(
        recording.id,
      )).single.speaker,
      isNull,
    );
  });

  test('persisted segments resume without diarization', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('diarization-resume');
    await fixture.repository.replaceTranscriptSegments(recording.id, const [
      TranscriptSegmentDraft(index: 0, startMs: 0, endMs: 10, speaker: 0),
    ]);
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
    );
    final processor = _FakeProcessor()..failDiarization = true;
    final queue = fixture.queue(
      processor,
      installedModels: _installedWithDiarization(),
    );

    await queue.processQueue();

    expect(processor.segmentCalls, 0);
    expect(processor.diarizeCalls, 0);
    expect(
      (await fixture.repository.getRecording(
        recording.id,
      ))!.transcriptionStatus,
      TranscriptionStatus.done,
    );
  });

  test('diarization failure marks the transcription failed', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('diarization-failure');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
    );
    final processor = _FakeProcessor()..failDiarization = true;
    final queue = fixture.queue(
      processor,
      installedModels: _installedWithDiarization(),
    );

    await queue.processQueue();

    expect(processor.diarizeCalls, 1);
    expect(
      (await fixture.repository.getRecording(
        recording.id,
      ))!.transcriptionStatus,
      TranscriptionStatus.failed,
    );
  });

  test('charging-only queue waits before processing while unplugged', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('charging-wait');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
      modelId: 'whisper-small',
    );
    final processor = _FakeProcessor();
    final queue = fixture.queue(
      processor,
      isCharging: () async => false,
      chargingOnly: () async => true,
    );

    await queue.processQueue();

    expect(processor.transcribeCalls, 0);
    expect(queue.waitingForCharger.value, isTrue);
    expect(
      (await fixture.repository.getRecording(
        recording.id,
      ))!.transcriptionStatus,
      TranscriptionStatus.queued,
    );
  });

  test('charging event resumes a waiting transcription', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('charging-resume');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
      modelId: 'whisper-small',
    );
    var charging = false;
    final changes = StreamController<bool>.broadcast();
    addTearDown(changes.close);
    final processor = _FakeProcessor();
    final queue = fixture.queue(
      processor,
      isCharging: () async => charging,
      chargingChanges: changes.stream,
      chargingOnly: () async => true,
    );
    await queue.processQueue();
    expect(queue.waitingForCharger.value, isTrue);

    final transcribed = Completer<void>();
    processor.onTranscribe = (_) => transcribed.complete();
    charging = true;
    changes.add(true);
    await transcribed.future.timeout(const Duration(seconds: 2));
    await queue.processQueue();

    expect(queue.waitingForCharger.value, isFalse);
    expect(processor.transcribeCalls, 1);
    expect(
      (await fixture.repository.getRecording(
        recording.id,
      ))!.transcriptionStatus,
      TranscriptionStatus.done,
    );
  });

  test(
    'unplug pauses after one segment and replug resumes without loss',
    () async {
      final fixture = await _Fixture.create();
      addTearDown(fixture.dispose);
      final recording = await fixture.recording('charging-mid-job');
      await fixture.repository.updateTranscription(
        id: recording.id,
        status: TranscriptionStatus.queued,
        modelId: 'whisper-small',
      );
      var charging = true;
      final changes = StreamController<bool>.broadcast();
      addTearDown(changes.close);
      final processor = _FakeProcessor()
        ..ranges = const [
          SpeechSampleRange(0, 160),
          SpeechSampleRange(160, 320),
          SpeechSampleRange(320, 480),
        ]
        ..onTranscribe = (calls) {
          if (calls == 1) {
            charging = false;
            changes.add(false);
          }
        };
      final queue = fixture.queue(
        processor,
        isCharging: () async => charging,
        chargingChanges: changes.stream,
        chargingOnly: () async => true,
      );

      await queue.processQueue();

      expect(processor.transcribeCalls, 1);
      expect(queue.waitingForCharger.value, isTrue);
      final pausedRunId = (await fixture.repository.getRecording(
        recording.id,
      ))!.activeRunId;
      expect(pausedRunId, isNull);
      final runBeforeResume =
          (await fixture.repository.watchRuns(recording.id).first).single;
      expect(runBeforeResume.status, TranscriptionStatus.queued);
      expect(runBeforeResume.processingMs, greaterThanOrEqualTo(0));
      final pausedSegments = await fixture.repository.listRunSegments(
        runBeforeResume.id,
      );
      expect(pausedSegments, hasLength(3));
      expect(pausedSegments.map((segment) => segment.text), [
        'recognized',
        null,
        null,
      ]);
      expect(
        (await fixture.repository.getRecording(
          recording.id,
        ))!.transcriptionStatus,
        TranscriptionStatus.queued,
      );

      charging = true;
      changes.add(true);
      await queue.processQueue();

      final completedSegments = await fixture.repository.listTranscriptSegments(
        recording.id,
      );
      expect(completedSegments, hasLength(3));
      expect(completedSegments.map((segment) => segment.text), [
        'recognized',
        'recognized',
        'recognized',
      ]);
      expect(processor.segmentCalls, 1);
      expect(processor.transcribeCalls, 3);
      expect(queue.waitingForCharger.value, isFalse);
      final completedRuns = await fixture.repository
          .watchRuns(recording.id)
          .first;
      expect(completedRuns, hasLength(1));
      expect(completedRuns.single.id, runBeforeResume.id);
      expect(completedRuns.single.status, TranscriptionStatus.done);
      expect(
        (await fixture.repository.getRecording(recording.id))!.activeRunId,
        runBeforeResume.id,
      );
    },
  );

  test('preference off ignores charger state', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('charging-disabled');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
      modelId: 'whisper-small',
    );
    final processor = _FakeProcessor();
    final queue = fixture.queue(
      processor,
      isCharging: () async => false,
      chargingOnly: () async => false,
    );

    await queue.processQueue();

    expect(processor.transcribeCalls, 1);
    expect(queue.waitingForCharger.value, isFalse);
    expect(
      (await fixture.repository.getRecording(
        recording.id,
      ))!.transcriptionStatus,
      TranscriptionStatus.done,
    );
  });

  test('turning charging-only off resumes a waiting job', () async {
    final fixture = await _Fixture.create();
    addTearDown(fixture.dispose);
    final recording = await fixture.recording('charging-setting-disabled');
    await fixture.repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.queued,
      modelId: 'whisper-small',
    );
    var chargingOnly = true;
    final processor = _FakeProcessor();
    final queue = fixture.queue(
      processor,
      isCharging: () async => false,
      chargingOnly: () async => chargingOnly,
    );

    await queue.processQueue();
    expect(queue.waitingForCharger.value, isTrue);

    chargingOnly = false;
    await queue.chargingPreferenceChanged();

    expect(queue.waitingForCharger.value, isFalse);
    expect(processor.transcribeCalls, 1);
    expect(
      (await fixture.repository.getRecording(
        recording.id,
      ))!.transcriptionStatus,
      TranscriptionStatus.done,
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
  final _queues = <TranscriptionQueue>[];

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

  TranscriptionQueue queue(
    _FakeProcessor processor, {
    Future<void> Function(String)? startService,
    Future<void> Function(String, int, int, String)? updateService,
    Future<void> Function()? stopService,
    Map<String, List<String>>? installedModels,
    Future<bool> Function()? isCharging,
    Stream<bool>? chargingChanges,
    Future<bool> Function()? chargingOnly,
  }) {
    final queue = TranscriptionQueue(
      repository: repository,
      recordingsDirectory: Directory('${directory.path}/recordings'),
      modelsDirectory: modelsDirectory,
      modelClient: _FakeModelClient(
        installed:
            installedModels ??
            {
              'silero-vad': ['silero_vad.onnx'],
              'whisper-small': modelById('whisper-small')!.files,
            },
      ),
      processor: processor,
      startService: startService ?? (_) async {},
      updateService: updateService ?? (_, _, _, _) async {},
      stopService: stopService ?? () async {},
      isCharging: isCharging ?? () async => false,
      chargingChanges: chargingChanges ?? const Stream.empty(),
      chargingOnly: chargingOnly ?? () async => false,
    );
    _queues.add(queue);
    return queue;
  }

  Future<void> dispose() async {
    for (final queue in _queues) {
      await queue.dispose();
    }
    await database.close();
    await directory.delete(recursive: true);
  }
}

class _FakeModelClient implements ModelImportClient {
  _FakeModelClient({required this.installed});

  final Map<String, List<String>> installed;

  @override
  Stream<ModelImportProgress> get progress => const Stream.empty();

  @override
  Future<bool> delete(String modelId) async => true;

  @override
  Future<String> importModel(String uri, CatalogModel model) async => '';

  @override
  Future<Map<String, List<String>>> listInstalled() async => installed;

  @override
  Future<String?> pickDocument() async => null;
}

class _FakeProcessor implements TranscriptionProcessor {
  final failedPaths = <String>{};
  final transcribedPaths = <String>[];
  final openedModelIds = <String>[];
  List<SpeechSampleRange> ranges = [const SpeechSampleRange(0, 160)];
  int segmentCalls = 0;
  int transcribeCalls = 0;
  void Function(int call)? onTranscribe;
  bool failSegmentation = false;
  bool failDiarization = false;
  int diarizeCalls = 0;
  List<int?> speakerCountHints = [];
  List<SpeakerTurn> turns = [];

  @override
  Future<void> closeModel() async {}

  @override
  Future<void> openModel({
    required CatalogModel model,
    required String language,
  }) async {
    openedModelIds.add(model.id);
  }

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
  Future<List<SpeakerTurn>> diarize(
    File wavFile, {
    required String segmentationModelPath,
    required String embeddingModelPath,
    required int? speakerCountHint,
    required void Function(int done, int total) onProgress,
  }) async {
    diarizeCalls++;
    speakerCountHints.add(speakerCountHint);
    if (failDiarization) throw StateError('synthetic diarization failure');
    onProgress(1, 1);
    return turns;
  }

  @override
  Future<AsrTranscript> transcribe({
    required File wavFile,
    required int startSample,
    required int endSample,
  }) async {
    transcribeCalls++;
    onTranscribe?.call(transcribeCalls);
    transcribedPaths.add(wavFile.path.split('/').last);
    if (failedPaths.contains(wavFile.path.split('/').last)) {
      throw StateError('synthetic failure');
    }
    return const AsrTranscript(text: 'recognized', language: 'ja');
  }
}

Map<String, List<String>> _installedWhisperAndSenseVoice() => {
  'silero-vad': ['silero_vad.onnx'],
  'whisper-small': modelById('whisper-small')!.files,
  'sense-voice': modelById('sense-voice')!.files,
};

Map<String, List<String>> _installedWithDiarization() => {
  'silero-vad': ['silero_vad.onnx'],
  'whisper-small': modelById('whisper-small')!.files,
  'pyannote-segmentation': modelById('pyannote-segmentation')!.files,
  'campplus-zh-en': modelById('campplus-zh-en')!.files,
};
