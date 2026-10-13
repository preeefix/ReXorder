import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/asr/streaming_wav_reader.dart';

void main() {
  test('PCM16 samples convert to normalized float32', () {
    final data = ByteData(6)
      ..setInt16(0, -32768, Endian.little)
      ..setInt16(2, 0, Endian.little)
      ..setInt16(4, 32767, Endian.little);

    expect(pcm16ToFloat32(data.buffer.asUint8List()), [
      -1.0,
      0.0,
      32767 / 32768,
    ]);
  });

  test(
    'streaming WAV reader skips header and preserves final partial window',
    () async {
      final directory = await Directory.systemTemp.createTemp('rexorder-wav-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/sample.wav');
      final samples = List<int>.generate(1025, (index) => index - 512);
      final pcm = ByteData(samples.length * 2);
      for (var index = 0; index < samples.length; index++) {
        pcm.setInt16(index * 2, samples[index], Endian.little);
      }
      await file.writeAsBytes([
        ...List<int>.filled(44, 0x7f),
        ...pcm.buffer.asUint8List(),
      ]);

      final windows = await StreamingWavReader(file).windows().toList();
      expect(windows.map((window) => window.length), [512, 512, 1]);
      expect(windows.first.first, -512 / 32768);
      expect(windows.last.single, 512 / 32768);
      expect(await StreamingWavReader(file).sampleCount, 1025);
    },
  );
}
