import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/voiceprint/voiceprint_math.dart';

void main() {
  test('normalizes vectors and preserves float32 little-endian storage', () {
    final normalized = normalizeEmbedding([3, 4]);
    expect(normalized[0], closeTo(0.6, 1e-6));
    expect(normalized[1], closeTo(0.8, 1e-6));
    final decoded = decodeEmbedding(encodeEmbedding(normalized));
    expect(decoded[0], closeTo(0.6, 1e-6));
    expect(decoded[1], closeTo(0.8, 1e-6));
  });

  test('computes a duration-weighted normalized mean', () {
    final mean = weightedMeanEmbedding([
      const WeightedEmbedding([1, 0], 3000),
      const WeightedEmbedding([0, 1], 1000),
    ]);
    expect(mean[0], closeTo(0.948683, 1e-5));
    expect(mean[1], closeTo(0.316228, 1e-5));
  });

  test('computes cosine similarity', () {
    expect(cosineSimilarity([1, 0], [1, 0]), closeTo(1, 1e-10));
    expect(cosineSimilarity([1, 0], [0, 1]), closeTo(0, 1e-10));
  });
}
