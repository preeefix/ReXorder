import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../audio/audio_math.dart';
import '../audio/wav_writer.dart';
import '../data/providers.dart';
import '../domain/recording_repository.dart';
import '../domain/recording.dart';
import '../processing/transcription_queue.dart';
import 'recording_service_channel.dart';

enum RecorderPhase { idle, recording, paused, saving }

class RecorderState {
  const RecorderState({
    this.phase = RecorderPhase.idle,
    this.elapsed = Duration.zero,
    this.level = 0,
    this.savedRecordingId,
    this.error,
  });

  final RecorderPhase phase;
  final Duration elapsed;
  final double level;
  final String? savedRecordingId;
  final String? error;

  RecorderState copyWith({
    RecorderPhase? phase,
    Duration? elapsed,
    double? level,
    String? savedRecordingId,
    String? error,
    bool clearError = false,
  }) => RecorderState(
    phase: phase ?? this.phase,
    elapsed: elapsed ?? this.elapsed,
    level: level ?? this.level,
    savedRecordingId: savedRecordingId ?? this.savedRecordingId,
    error: clearError ? null : error ?? this.error,
  );
}

final recorderControllerProvider =
    NotifierProvider<RecorderController, RecorderState>(RecorderController.new);

class RecorderController extends Notifier<RecorderState> {
  static const sampleRate = 16000;
  static const channels = 1;
  static const bitsPerSample = 16;

  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _subscription;
  IOSink? _sink;
  File? _pcmFile;
  String? _recordingId;
  int _bytesWritten = 0;
  DateTime? _lastMeterUpdate;
  Future<void> _writeTail = Future<void>.value();
  Timer? _timer;

  RecordingRepository get _repository {
    final db = ref.read(appDatabaseProvider);
    return RecordingRepository(db, ref.read(recordingsDirectoryProvider));
  }

  @override
  RecorderState build() {
    ref.onDispose(() {
      _timer?.cancel();
      unawaited(_subscription?.cancel());
      unawaited(_recorder?.dispose());
      unawaited(RecordingServiceChannel.stop());
    });
    return const RecorderState();
  }

  Future<void> start() async {
    if (state.phase != RecorderPhase.idle) return;
    state = const RecorderState();
    try {
      final microphone = await Permission.microphone.request();
      if (!microphone.isGranted) {
        throw StateError('Microphone permission is required to record.');
      }
      await Permission.notification.request();
      await RecordingServiceChannel.start();

      final id = const Uuid().v4();
      final directory = ref.read(recordingsDirectoryProvider);
      _recordingId = id;
      _pcmFile = File(p.join(directory.path, '$id.pcm'));
      await _repository.createRecording(id: id);
      _sink = _pcmFile!.openWrite(mode: FileMode.writeOnlyAppend);
      _bytesWritten = 0;
      _recorder = AudioRecorder();
      final audioStream = await _recorder!.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: sampleRate,
          numChannels: channels,
        ),
      );
      _subscription = audioStream.listen(
        _onAudioChunk,
        onError: (Object error, StackTrace stackTrace) {
          state = state.copyWith(error: error.toString());
        },
      );
      _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (state.phase == RecorderPhase.recording) {
          state = state.copyWith(elapsed: durationFromPcmBytes(_bytesWritten));
        }
      });
      state = const RecorderState(phase: RecorderPhase.recording);
    } catch (error) {
      await _cleanupFailedStart();
      state = state.copyWith(error: error.toString());
    }
  }

  void _onAudioChunk(Uint8List bytes) {
    final now = DateTime.now();
    if (_lastMeterUpdate == null ||
        now.difference(_lastMeterUpdate!) >= const Duration(milliseconds: 50)) {
      _lastMeterUpdate = now;
      state = state.copyWith(level: pcmLevel(bytes));
    }
    final sink = _sink;
    if (sink == null) return;
    _writeTail = _writeTail.then((_) async {
      sink.add(bytes);
      await sink.flush();
      _bytesWritten += bytes.length;
      if (state.phase == RecorderPhase.recording) {
        state = state.copyWith(elapsed: durationFromPcmBytes(_bytesWritten));
      }
    });
  }

  Future<void> pause() async {
    if (state.phase != RecorderPhase.recording) return;
    await _recorder?.pause();
    state = state.copyWith(phase: RecorderPhase.paused, level: 0);
  }

  Future<void> resume() async {
    if (state.phase != RecorderPhase.paused) return;
    await _recorder?.resume();
    state = state.copyWith(phase: RecorderPhase.recording);
  }

  Future<int?> addBookmark() async {
    final recordingId = _recordingId;
    if (recordingId == null ||
        (state.phase != RecorderPhase.recording &&
            state.phase != RecorderPhase.paused)) {
      return null;
    }
    await _writeTail;
    final positionMs = durationFromPcmBytes(_bytesWritten).inMilliseconds;
    await _repository.addBookmark(recordingId, positionMs);
    return positionMs;
  }

  Future<String?> stop() async {
    if (_recordingId == null || _recorder == null) return null;
    state = state.copyWith(phase: RecorderPhase.saving);
    _timer?.cancel();
    final id = _recordingId!;
    try {
      await _recorder!.stop();
      await _subscription?.cancel();
      await _writeTail;
      await _sink?.flush();
      await _sink?.close();
      final pcmFile = _pcmFile!;
      final wavFile = File(
        p.join(ref.read(recordingsDirectoryProvider).path, '$id.wav'),
      );
      await wrapPcmToWav(pcmFile, wavFile);
      await pcmFile.delete();
      await _repository.markReady(
        id,
        durationFromPcmBytes(_bytesWritten).inMilliseconds,
      );
      await RecordingServiceChannel.stop();
      await _recorder!.dispose();
      _reset();
      state = RecorderState(savedRecordingId: id);
      if (await TranscriptionPreferences.autoTranscribe()) {
        final language = await TranscriptionPreferences.defaultLanguage();
        await ref
            .read(transcriptionQueueProvider)
            .enqueue(
              id,
              language: LanguageHint.values.firstWhere(
                (value) => value.name == language,
                orElse: () => LanguageHint.auto,
              ),
            );
      }
      return id;
    } catch (error) {
      state = state.copyWith(error: error.toString());
      return null;
    }
  }

  Future<void> _cleanupFailedStart() async {
    _timer?.cancel();
    try {
      await _subscription?.cancel();
      await _sink?.close();
      if (_recorder != null) {
        await _recorder!.cancel();
        await _recorder!.dispose();
      }
      await RecordingServiceChannel.stop();
    } catch (_) {
      // Preserve the original startup error.
    }
    _reset();
  }

  void _reset() {
    _recordingId = null;
    _pcmFile = null;
    _sink = null;
    _subscription = null;
    _recorder = null;
    _bytesWritten = 0;
    _writeTail = Future<void>.value();
  }
}
