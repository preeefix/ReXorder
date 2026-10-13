import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/audio/audio_math.dart';

void main() {
  test('derives elapsed duration from PCM byte count', () {
    expect(durationFromPcmBytes(64000), const Duration(seconds: 2));
    expect(
      durationFromPcmBytes(64000, channels: 2),
      const Duration(seconds: 1),
    );
  });
}
