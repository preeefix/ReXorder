import 'dart:io';
import 'dart:typed_data';

Float32List pcm16ToFloat32(Uint8List bytes) {
  if (bytes.length.isOdd) {
    throw const FormatException('PCM16 input must contain complete samples.');
  }
  final data = ByteData.sublistView(bytes);
  final samples = Float32List(bytes.length ~/ 2);
  for (var index = 0; index < samples.length; index++) {
    samples[index] = data.getInt16(index * 2, Endian.little) / 32768.0;
  }
  return samples;
}

class StreamingWavReader {
  const StreamingWavReader(this.file, {this.headerBytes = 44});

  final File file;
  final int headerBytes;

  Future<int> get sampleCount async {
    final dataLength = await file.length() - headerBytes;
    if (dataLength < 0 || dataLength.isOdd) {
      throw const FormatException('Invalid PCM16 WAV data length.');
    }
    return dataLength ~/ 2;
  }

  Stream<Float32List> windows({int windowSamples = 512}) async* {
    final handle = await file.open();
    try {
      final length = await handle.length();
      if (length < headerBytes || (length - headerBytes).isOdd) {
        throw const FormatException('Invalid PCM16 WAV file.');
      }
      await handle.setPosition(headerBytes);
      final windowBytes = windowSamples * 2;
      while (true) {
        final bytes = await handle.read(windowBytes);
        if (bytes.isEmpty) return;
        yield pcm16ToFloat32(bytes);
      }
    } finally {
      await handle.close();
    }
  }

  Future<Float32List> readSamples(int startSample, int endSample) async {
    if (startSample < 0 || endSample < startSample) {
      throw RangeError('Invalid sample range.');
    }
    final sampleTotal = await sampleCount;
    if (endSample > sampleTotal) {
      throw RangeError('Sample range exceeds the WAV data.');
    }
    final handle = await file.open();
    try {
      await handle.setPosition(headerBytes + startSample * 2);
      final bytes = await handle.read((endSample - startSample) * 2);
      if (bytes.length != (endSample - startSample) * 2) {
        throw const FormatException('Unexpected end of WAV data.');
      }
      return pcm16ToFloat32(bytes);
    } finally {
      await handle.close();
    }
  }
}
