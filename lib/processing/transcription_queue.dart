import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../asr/speaker_split.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/recording.dart';
import '../domain/recording_repository.dart';
import '../domain/transcript_segment.dart';
import '../domain/transcription_run.dart';
import '../models/model_catalog.dart';
import '../models/model_import_client.dart';
import 'power_channel.dart';
import 'processing_service_channel.dart';
import 'transcription_worker.dart';

class TranscriptionQueue {
  TranscriptionQueue({
    required this.repository,
    required this.recordingsDirectory,
    required this.modelsDirectory,
    ModelImportClient? modelClient,
    this._processor,
    Future<void> Function(String)? startService,
    Future<void> Function(String, int, int, String)? updateService,
    Future<void> Function()? stopService,
    Future<bool> Function()? isCharging,
    Stream<bool>? chargingChanges,
    Future<bool> Function()? chargingOnly,
  }) : _modelClient = modelClient ?? const MethodChannelModelImportClient(),
       _startService = startService ?? ProcessingServiceChannel.start,
       _updateService = updateService ?? ProcessingServiceChannel.update,
       _stopService = stopService ?? ProcessingServiceChannel.stop,
       _isCharging = isCharging ?? PowerChannel.isCharging,
       _chargingChanges = chargingChanges ?? PowerChannel.chargingChanges,
       _chargingOnly = chargingOnly ?? TranscriptionPreferences.chargingOnly {
    _chargingSubscription = _chargingChanges.listen((charging) {
      if (!charging) return;
      waitingForCharger.value = false;
      unawaited(processQueue());
    });
  }

  final RecordingRepository repository;
  final Directory recordingsDirectory;
  final Directory modelsDirectory;
  final ModelImportClient _modelClient;
  TranscriptionProcessor? _processor;
  TranscriptionWorker? _worker;
  final Future<void> Function(String) _startService;
  final Future<void> Function(String, int, int, String) _updateService;
  final Future<void> Function() _stopService;
  final Future<bool> Function() _isCharging;
  final Stream<bool> _chargingChanges;
  final Future<bool> Function() _chargingOnly;
  late final StreamSubscription<bool> _chargingSubscription;
  final ValueNotifier<String?> stage = ValueNotifier(null);
  final ValueNotifier<bool> waitingForCharger = ValueNotifier(false);
  Future<void>? _processFuture;

  Future<void> recoverRunningJobs() =>
      repository.requeueRunningTranscriptions();

  Future<void> chargingPreferenceChanged() async {
    if (!await _chargingOnly()) waitingForCharger.value = false;
    await processQueue();
  }

  Future<void> enqueue(
    String recordingId, {
    String? modelId,
    LanguageHint language = LanguageHint.auto,
    int? speakerCount,
    bool retranscribe = false,
  }) async {
    await repository.createTranscriptionRun(
      recordingId: recordingId,
      modelId: modelId,
      languageHint: language,
      speakerCountHint: speakerCount,
    );
    unawaited(processQueue());
  }

  Future<void> processQueue() {
    return _processFuture ??= _runQueue().whenComplete(() {
      _processFuture = null;
    });
  }

  Future<void> _runQueue() async {
    while (true) {
      final queued = await repository.listQueuedTranscriptions();
      if (queued.isEmpty) {
        waitingForCharger.value = false;
        return;
      }
      if (await _shouldWaitForCharger()) {
        await _stopServiceBestEffort();
        return;
      }
      final installed = await _modelClient.listInstalled();
      final vad = modelById('silero-vad')!;
      final vadFiles = installed[vad.id] ?? const <String>[];
      final installedAsr = modelCatalog
          .where(
            (model) =>
                model.isAsr &&
                model.files.every(
                  (file) => installed[model.id]?.contains(file) ?? false,
                ),
          )
          .toList();
      final preferredAsr = preferredInstalledAsr(
        installedAsr.map((model) => model.id),
      );
      if (!vad.files.every(vadFiles.contains) || preferredAsr == null) return;
      final diarizationInstalled =
          [
            modelById('pyannote-segmentation')!,
            modelById('campplus-zh-en')!,
          ].every(
            (model) => model.files.every(
              (file) => installed[model.id]?.contains(file) ?? false,
            ),
          );
      final job = queued.first;
      final recording = job.recording;
      final run = job.run;
      final requestedModel = modelById(run.asrModelId ?? '');
      final model =
          requestedModel != null &&
              installedAsr.any((item) => item.id == requestedModel.id)
          ? requestedModel
          : preferredAsr;
      await _processRecording(
        recording,
        run,
        model,
        diarizationInstalled: diarizationInstalled,
      );
      if (waitingForCharger.value) return;
    }
  }

  Future<void> _processRecording(
    Recording recording,
    TranscriptionRun run,
    CatalogModel model, {
    required bool diarizationInstalled,
  }) async {
    if (await _shouldWaitForCharger()) {
      await _stopServiceBestEffort();
      return;
    }
    final wavFile = File(p.join(recordingsDirectory.path, recording.fileName));
    final vadFile = File(
      p.join(modelsDirectory.path, 'silero-vad', 'silero_vad.onnx'),
    );
    if (!await wavFile.exists() || !await vadFile.exists()) {
      await repository.updateTranscription(
        id: recording.id,
        status: TranscriptionStatus.failed,
        runId: run.id,
        modelId: model.id,
        languageHint: run.languageHint,
        speakerCountHint: run.speakerCountHint,
        error: 'Recording or VAD model file is missing.',
      );
      return;
    }
    await repository.updateTranscription(
      id: recording.id,
      status: TranscriptionStatus.running,
      runId: run.id,
      modelId: model.id,
      languageHint: run.languageHint,
      speakerCountHint: run.speakerCountHint,
    );
    final stopwatch = Stopwatch()..start();
    try {
      await _startServiceBestEffort(recording.title);
      if (_processor == null) {
        _worker = await TranscriptionWorker.spawn(
          modelsDirectory: modelsDirectory,
        );
        _processor = _worker;
      }
      final processor = _processor!;
      var segments = await repository.listRunSegments(run.id);
      var diarized = run.diarized;
      if (segments.isEmpty) {
        final ranges = await processor.segment(wavFile, vadFile.path);
        List<TranscriptSegmentDraft> drafts;
        if (diarizationInstalled && run.speakerCountHint != 1) {
          final segmentation = modelById('pyannote-segmentation')!;
          final embedding = modelById('campplus-zh-en')!;
          stage.value = 'speakers';
          final turns = await processor.diarize(
            wavFile,
            segmentationModelPath: p.join(
              modelsDirectory.path,
              segmentation.id,
              segmentation.files.single,
            ),
            embeddingModelPath: p.join(
              modelsDirectory.path,
              embedding.id,
              embedding.files.single,
            ),
            speakerCountHint: run.speakerCountHint,
            onProgress: (done, total) => unawaited(
              _updateServiceBestEffort(
                recording.title,
                done,
                total,
                'speakers',
              ),
            ),
          );
          final pieces = splitBySpeaker(ranges, turns);
          diarized = pieces.any((piece) => piece.speaker != null);
          drafts = [
            for (var index = 0; index < pieces.length; index++)
              _speakerDraft(index, pieces[index]),
          ];
        } else {
          drafts = [
            for (var index = 0; index < ranges.length; index++)
              TranscriptSegmentDraft(
                index: index,
                startMs: ranges[index].startSample * 1000 ~/ 16000,
                endMs: ranges[index].endSample * 1000 ~/ 16000,
              ),
          ];
        }
        await repository.replaceTranscriptSegments(
          recording.id,
          drafts,
          runId: run.id,
        );
        segments = await repository.listRunSegments(run.id);
      }
      stage.value = 'transcribing';
      await processor.openModel(model: model, language: run.languageHint.name);
      var completed = segments.where((segment) => segment.text != null).length;
      await _updateServiceBestEffort(
        recording.title,
        completed,
        segments.length,
        'transcribing',
      );
      for (final segment in segments) {
        if (segment.text != null) continue;
        if (await _shouldWaitForCharger()) {
          await processor.closeModel();
          stopwatch.stop();
          await repository.updateTranscription(
            id: recording.id,
            status: TranscriptionStatus.queued,
            runId: run.id,
            modelId: model.id,
            languageHint: run.languageHint,
            speakerCountHint: run.speakerCountHint,
            processingMsDelta: stopwatch.elapsedMilliseconds,
            diarized: diarized,
          );
          return;
        }
        final result = await processor.transcribe(
          wavFile: wavFile,
          startSample: segment.startMs * 16000 ~/ 1000,
          endSample: segment.endMs * 16000 ~/ 1000,
        );
        await repository.updateTranscriptSegment(
          id: segment.id,
          text: result.text,
          lang: result.language,
        );
        completed++;
        await _updateServiceBestEffort(
          recording.title,
          completed,
          segments.length,
          'transcribing',
        );
      }
      await processor.closeModel();
      stopwatch.stop();
      await repository.updateTranscription(
        id: recording.id,
        status: TranscriptionStatus.done,
        runId: run.id,
        modelId: model.id,
        languageHint: run.languageHint,
        speakerCountHint: run.speakerCountHint,
        processingMsDelta: stopwatch.elapsedMilliseconds,
        diarized: diarized,
      );
    } catch (error) {
      stopwatch.stop();
      try {
        await _processor?.closeModel();
      } catch (_) {
        // Preserve the transcription error while releasing the recognizer.
      }
      await repository.updateTranscription(
        id: recording.id,
        status: TranscriptionStatus.failed,
        runId: run.id,
        modelId: model.id,
        languageHint: run.languageHint,
        error: error.toString(),
        speakerCountHint: run.speakerCountHint,
        processingMsDelta: stopwatch.elapsedMilliseconds,
      );
    } finally {
      stage.value = null;
      await _stopServiceBestEffort();
    }
  }

  TranscriptSegmentDraft _speakerDraft(int index, SpeakerPiece piece) =>
      TranscriptSegmentDraft(
        index: index,
        startMs: piece.startSample * 1000 ~/ 16000,
        endMs: piece.endSample * 1000 ~/ 16000,
        speaker: piece.speaker,
      );

  Future<bool> _shouldWaitForCharger() async {
    if (!await _chargingOnly()) {
      waitingForCharger.value = false;
      return false;
    }
    final waiting = !await _isCharging();
    waitingForCharger.value = waiting;
    return waiting;
  }

  Future<void> _startServiceBestEffort(String title) async {
    try {
      await _startService(title);
    } catch (_) {}
  }

  Future<void> _updateServiceBestEffort(
    String title,
    int progress,
    int max,
    String stage,
  ) async {
    try {
      await _updateService(title, progress, max, stage);
    } catch (_) {}
  }

  Future<void> _stopServiceBestEffort() async {
    try {
      await _stopService();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _chargingSubscription.cancel();
    await _worker?.close();
    _worker = null;
    _processor = null;
    stage.dispose();
    waitingForCharger.dispose();
  }
}

final transcriptionQueueProvider = Provider<TranscriptionQueue>(
  (ref) => throw UnimplementedError('TranscriptionQueue must be overridden'),
);

class TranscriptionPreferences {
  static const _autoKey = 'autoTranscribe';
  static const _languageKey = 'defaultLanguage';
  static const _chargingOnlyKey = 'chargingOnly';

  static Future<bool> autoTranscribe() async =>
      (await SharedPreferences.getInstance()).getBool(_autoKey) ?? true;

  static Future<String> defaultLanguage() async =>
      (await SharedPreferences.getInstance()).getString(_languageKey) ?? 'auto';

  static Future<bool> chargingOnly() async =>
      (await SharedPreferences.getInstance()).getBool(_chargingOnlyKey) ??
      false;

  static Future<void> setAutoTranscribe(bool value) async {
    await (await SharedPreferences.getInstance()).setBool(_autoKey, value);
  }

  static Future<void> setDefaultLanguage(String value) async {
    await (await SharedPreferences.getInstance()).setString(
      _languageKey,
      value,
    );
  }

  static Future<void> setChargingOnly(bool value) async {
    await (await SharedPreferences.getInstance()).setBool(
      _chargingOnlyKey,
      value,
    );
  }
}
