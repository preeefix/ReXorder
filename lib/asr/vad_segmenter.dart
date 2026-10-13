import 'dart:io';

import 'package:sherpa_onnx/sherpa_onnx.dart';

import 'streaming_wav_reader.dart';

class SpeechSampleRange {
  const SpeechSampleRange(this.startSample, this.endSample);

  final int startSample;
  final int endSample;
}

class VadSegmenter {
  factory VadSegmenter({required String modelPath, int numThreads = 4}) {
    initBindings();
    return VadSegmenter._(modelPath: modelPath, numThreads: numThreads);
  }

  VadSegmenter._({required String modelPath, required int numThreads})
    : _detector = VoiceActivityDetector(
        config: VadModelConfig(
          sileroVad: SileroVadModelConfig(
            model: modelPath,
            threshold: 0.5,
            minSilenceDuration: 0.4,
            minSpeechDuration: 0.25,
            windowSize: 512,
            maxSpeechDuration: 20,
          ),
          sampleRate: 16000,
          numThreads: numThreads,
          provider: 'cpu',
          debug: false,
        ),
        bufferSizeInSeconds: 30,
      );

  final VoiceActivityDetector _detector;

  Future<List<SpeechSampleRange>> segment(File wavFile) async {
    final ranges = <SpeechSampleRange>[];
    void drain() {
      while (!_detector.isEmpty()) {
        final segment = _detector.front();
        ranges.add(
          SpeechSampleRange(
            segment.start,
            segment.start + segment.samples.length,
          ),
        );
        _detector.pop();
      }
    }

    await for (final window in StreamingWavReader(wavFile).windows()) {
      _detector.acceptWaveform(window);
      drain();
    }
    _detector.flush();
    drain();
    return ranges;
  }

  void dispose() => _detector.free();
}
