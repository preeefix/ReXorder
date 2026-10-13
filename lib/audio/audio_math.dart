import 'dart:math' as math;
import 'dart:typed_data';

Duration durationFromPcmBytes(
  int byteCount, {
  int sampleRate = 16000,
  int channels = 1,
  int bitsPerSample = 16,
}) {
  final bytesPerSecond = sampleRate * channels * bitsPerSample ~/ 8;
  return Duration(
    microseconds: byteCount * Duration.microsecondsPerSecond ~/ bytesPerSecond,
  );
}

double pcmRmsDbfs(Uint8List bytes) {
  final sampleCount = bytes.length ~/ 2;
  if (sampleCount == 0) return -120;
  final data = ByteData.sublistView(bytes);
  var sumSquares = 0.0;
  for (var index = 0; index < sampleCount; index++) {
    final sample = data.getInt16(index * 2, Endian.little) / 32768.0;
    sumSquares += sample * sample;
  }
  final rms = math.sqrt(sumSquares / sampleCount);
  return rms == 0 ? -120 : 20 * math.log(rms) / math.ln10;
}

double pcmLevel(Uint8List bytes) =>
    ((pcmRmsDbfs(bytes) + 60) / 60).clamp(0.0, 1.0);
