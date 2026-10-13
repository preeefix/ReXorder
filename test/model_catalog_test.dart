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
}
