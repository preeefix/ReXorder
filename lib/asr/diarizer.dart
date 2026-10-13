import 'dart:io';

import 'package:sherpa_onnx/sherpa_onnx.dart';

import 'streaming_wav_reader.dart';

class SpeakerTurn {
  const SpeakerTurn({
    required this.startSample,
    required this.endSample,
    required this.speaker,
  });

  final int startSample;
  final int endSample;
  final int speaker;
}

class Diarizer {
  factory Diarizer({
    required String segmentationModelPath,
    required String embeddingModelPath,
    int? speakerCountHint,
    int numThreads = 4,
  }) {
    initBindings();
    return Diarizer._(
      OfflineSpeakerDiarization(
        OfflineSpeakerDiarizationConfig(
          segmentation: OfflineSpeakerSegmentationModelConfig(
            pyannote: OfflineSpeakerSegmentationPyannoteModelConfig(
              model: segmentationModelPath,
            ),
            numThreads: numThreads,
            debug: false,
          ),
          embedding: SpeakerEmbeddingExtractorConfig(
            model: embeddingModelPath,
            numThreads: numThreads,
            debug: false,
          ),
          clustering: FastClusteringConfig(
            numClusters: speakerCountHint ?? -1,
            threshold: 0.5,
          ),
          minDurationOn: 0.2,
          minDurationOff: 0.5,
        ),
      ),
    );
  }

  Diarizer._(this._diarization);

  final OfflineSpeakerDiarization _diarization;

  Future<List<SpeakerTurn>> diarize(
    File wavFile, {
    required void Function(int done, int total) onProgress,
  }) async {
    final reader = StreamingWavReader(wavFile);
    final samples = await reader.readSamples(0, await reader.sampleCount);
    return _diarization
        .processWithCallback(
          samples: samples,
          callback: (done, total) {
            onProgress(done, total);
            return 0;
          },
        )
        .map(
          (turn) => SpeakerTurn(
            startSample: (turn.start * _diarization.sampleRate).round(),
            endSample: (turn.end * _diarization.sampleRate).round(),
            speaker: turn.speaker,
          ),
        )
        .toList();
  }

  void dispose() => _diarization.free();
}
