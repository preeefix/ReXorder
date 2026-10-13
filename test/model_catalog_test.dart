import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/models/model_catalog.dart';

void main() {
  test('model catalog has unique ids and URLs with required files', () {
    final ids = modelCatalog.map((model) => model.id).toList();
    final urls = modelCatalog.map((model) => model.url).toList();
    expect(ids.toSet().length, ids.length);
    expect(urls.toSet().length, urls.length);
    for (final model in modelCatalog) {
      expect(model.sizeBytes, greaterThan(0));
      expect(model.files, isNotEmpty);
    }
  });

  test('speaker models use their expected import types and files', () {
    final segmentation = modelById('pyannote-segmentation')!;
    final embedding = modelById('campplus-zh-en')!;

    expect(segmentation.type, ModelType.segmentation);
    expect(segmentation.importKind, 'tar.bz2');
    expect(segmentation.files, ['model.onnx']);
    expect(segmentation.sizeBytes, 6958444);
    expect(embedding.type, ModelType.embedding);
    expect(embedding.importKind, 'file');
    expect(embedding.files, ['embedding.onnx']);
    expect(embedding.sizeBytes, 28281164);
  });
}
