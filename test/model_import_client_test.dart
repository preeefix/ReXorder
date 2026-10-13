import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/models/model_catalog.dart';
import 'package:rexorder/models/model_import_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('plain-file imports pass their display name and target files', () async {
    const channel = MethodChannel('rexorder/models');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'importModel');
      final arguments = call.arguments! as Map<Object?, Object?>;
      final model = modelById('campplus-zh-en')!;
      expect(arguments['displayName'], model.displayName);
      expect(arguments['files'], model.files);
      expect(arguments['targetFileName'], 'embedding.onnx');
      return '/models/campplus-zh-en';
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final directory = await const MethodChannelModelImportClient().importModel(
      'content://models/campplus.onnx',
      modelById('campplus-zh-en')!,
    );

    expect(directory, '/models/campplus-zh-en');
  });
}
