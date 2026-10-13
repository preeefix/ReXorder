import 'dart:math' as math;
import 'dart:typed_data';

class WeightedEmbedding {
  const WeightedEmbedding(this.embedding, this.weight);

  final List<double> embedding;
  final int weight;
}

Float32List normalizeEmbedding(List<double> embedding) {
  final norm = math.sqrt(
    embedding.fold<double>(0, (sum, value) => sum + value * value),
  );
  if (norm == 0 || !norm.isFinite) return Float32List(embedding.length);
  return Float32List.fromList([for (final value in embedding) value / norm]);
}

Float32List weightedMeanEmbedding(Iterable<WeightedEmbedding> embeddings) {
  final values = embeddings.where((item) => item.weight > 0).toList();
  if (values.isEmpty) return Float32List(0);
  final dimensions = values.first.embedding.length;
  if (values.any((item) => item.embedding.length != dimensions)) {
    throw ArgumentError('Embedding dimensions must match.');
  }
  final totalWeight = values.fold<int>(0, (sum, item) => sum + item.weight);
  final mean = List<double>.filled(dimensions, 0);
  for (final item in values) {
    for (var index = 0; index < dimensions; index++) {
      mean[index] += item.embedding[index] * item.weight / totalWeight;
    }
  }
  return normalizeEmbedding(mean);
}

double cosineSimilarity(List<double> left, List<double> right) {
  if (left.length != right.length) {
    throw ArgumentError('Embedding dimensions must match.');
  }
  var dot = 0.0;
  var leftNorm = 0.0;
  var rightNorm = 0.0;
  for (var index = 0; index < left.length; index++) {
    dot += left[index] * right[index];
    leftNorm += left[index] * left[index];
    rightNorm += right[index] * right[index];
  }
  if (leftNorm == 0 || rightNorm == 0) return 0;
  return dot / (math.sqrt(leftNorm) * math.sqrt(rightNorm));
}

Uint8List encodeEmbedding(List<double> embedding) {
  final data = ByteData(embedding.length * Float32List.bytesPerElement);
  for (var index = 0; index < embedding.length; index++) {
    data.setFloat32(
      index * Float32List.bytesPerElement,
      embedding[index],
      Endian.little,
    );
  }
  return data.buffer.asUint8List();
}

Float32List decodeEmbedding(Uint8List bytes) {
  if (bytes.length % Float32List.bytesPerElement != 0) {
    throw const FormatException('Invalid float32 embedding data.');
  }
  final data = ByteData.sublistView(bytes);
  return Float32List.fromList([
    for (var offset = 0; offset < bytes.length; offset += 4)
      data.getFloat32(offset, Endian.little),
  ]);
}
