import 'dart:io';
import 'dart:typed_data';

class WavWriter {
  const WavWriter();

  Uint8List header({
    required int dataLength,
    required int sampleRate,
    required int channels,
    required int bitsPerSample,
  }) {
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;
    final header = ByteData(44);
    void writeString(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        header.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    header.setUint32(4, 36 + dataLength, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    writeString(36, 'data');
    header.setUint32(40, dataLength, Endian.little);
    return header.buffer.asUint8List();
  }
}

Future<void> wrapPcmToWav(
  File pcm,
  File wav, {
  int sampleRate = 16000,
  int channels = 1,
  int bitsPerSample = 16,
}) async {
  final dataLength = await pcm.length();
  final output = wav.openWrite(mode: FileMode.write);
  try {
    output.add(
      const WavWriter().header(
        dataLength: dataLength,
        sampleRate: sampleRate,
        channels: channels,
        bitsPerSample: bitsPerSample,
      ),
    );
    await output.addStream(pcm.openRead());
    await output.flush();
  } finally {
    await output.close();
  }
}
