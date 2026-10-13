import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/audio/wav_writer.dart';

void main() {
  test('wraps PCM in a valid 16 kHz mono 16-bit WAV header', () async {
    final directory = await Directory.systemTemp.createTemp('rexorder-wav-');
    addTearDown(() => directory.delete(recursive: true));
    final pcm = File('${directory.path}/audio.pcm')
      ..writeAsBytesSync([1, 2, 3, 4]);
    final wav = File('${directory.path}/audio.wav');

    await wrapPcmToWav(pcm, wav);

    final output = await wav.readAsBytes();
    final header = ByteData.sublistView(output);
    expect(output.length, 48);
    expect(String.fromCharCodes(output.sublist(0, 4)), 'RIFF');
    expect(header.getUint32(4, Endian.little), 40);
    expect(String.fromCharCodes(output.sublist(8, 12)), 'WAVE');
    expect(String.fromCharCodes(output.sublist(12, 16)), 'fmt ');
    expect(header.getUint32(16, Endian.little), 16);
    expect(header.getUint16(20, Endian.little), 1);
    expect(header.getUint16(22, Endian.little), 1);
    expect(header.getUint32(24, Endian.little), 16000);
    expect(header.getUint32(28, Endian.little), 32000);
    expect(header.getUint16(32, Endian.little), 2);
    expect(header.getUint16(34, Endian.little), 16);
    expect(String.fromCharCodes(output.sublist(36, 40)), 'data');
    expect(header.getUint32(40, Endian.little), 4);
  });

  test('wraps empty PCM with a zero-length data chunk', () async {
    final directory = await Directory.systemTemp.createTemp('rexorder-wav-');
    addTearDown(() => directory.delete(recursive: true));
    final pcm = File('${directory.path}/empty.pcm')..writeAsBytesSync([]);
    final wav = File('${directory.path}/empty.wav');

    await wrapPcmToWav(pcm, wav);

    final output = await wav.readAsBytes();
    final header = ByteData.sublistView(output);
    expect(output.length, 44);
    expect(header.getUint32(4, Endian.little), 36);
    expect(header.getUint32(40, Endian.little), 0);
  });

  test('streams multi-chunk PCM data unchanged after the WAV header', () async {
    final directory = await Directory.systemTemp.createTemp('rexorder-wav-');
    addTearDown(() => directory.delete(recursive: true));
    final pcmBytes = Uint8List.fromList(
      List<int>.generate(1024 * 1024, (index) => index & 0xff),
    );
    final pcm = File('${directory.path}/multi-chunk.pcm')
      ..writeAsBytesSync(pcmBytes);
    final wav = File('${directory.path}/multi-chunk.wav');

    await wrapPcmToWav(pcm, wav);

    final output = await wav.readAsBytes();
    expect(output.length, pcmBytes.length + 44);
    expect(output.sublist(44), pcmBytes);
  });
}
