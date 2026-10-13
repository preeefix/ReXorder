import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/models/model_catalog.dart';

void main() {
  test('model catalog has unique ids and pinned SHA-256 checksums', () {
    final ids = modelCatalog.map((model) => model.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final model in modelCatalog) {
      expect(model.sha256, matches(RegExp(r'^[0-9a-fA-F]{64}$')));
      expect(model.sizeBytes, greaterThan(0));
      expect(model.files, isNotEmpty);
    }
  });
}
