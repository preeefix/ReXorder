import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/models/model_catalog.dart';
import 'package:rexorder/models/model_import_client.dart';
import 'package:rexorder/models/model_manager.dart';

void main() {
  test(
    'model import state handles progress, success, and archive failure',
    () async {
      final client = _FakeModelImportClient();
      final container = ProviderContainer(
        overrides: [modelImportClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);
      container.listen(modelManagerProvider, (previous, next) {});
      final controller = container.read(modelManagerProvider.notifier);
      await controller.refresh();

      final import = controller.importModel(modelCatalog.first);
      expect(
        container.read(modelManagerProvider).phase,
        ModelImportPhase.picking,
      );
      await Future<void>.delayed(Duration.zero);
      client.progressController.add(
        const ModelImportProgress(
          modelId: 'silero-vad',
          bytesRead: 512,
          totalBytes: 1024,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(modelManagerProvider).phase,
        ModelImportPhase.importing,
      );
      expect(container.read(modelManagerProvider).bytesRead, 512);
      client.importCompleter.complete('/models/silero-vad');
      await import;
      expect(
        container.read(modelManagerProvider).phase,
        ModelImportPhase.success,
      );
      expect(
        container.read(modelManagerProvider).installedModelIds,
        contains('silero-vad'),
      );
      expect(container.read(modelManagerProvider).hasDiarization, isFalse);

      client.shouldFail = true;
      await controller.importModel(modelCatalog[1]);
      expect(
        container.read(modelManagerProvider).phase,
        ModelImportPhase.failure,
      );
      expect(
        container.read(modelManagerProvider).message,
        contains('not a valid Whisper Small archive'),
      );
      client.installed['pyannote-segmentation'] = modelById(
        'pyannote-segmentation',
      )!.files;
      client.installed['campplus-zh-en'] = modelById('campplus-zh-en')!.files;
      await controller.refresh();
      expect(container.read(modelManagerProvider).hasDiarization, isTrue);
    },
  );
}

class _FakeModelImportClient implements ModelImportClient {
  final StreamController<ModelImportProgress> progressController =
      StreamController<ModelImportProgress>.broadcast();
  final Completer<String> importCompleter = Completer<String>();
  bool shouldFail = false;
  Map<String, List<String>> installed = {};

  @override
  Stream<ModelImportProgress> get progress => progressController.stream;

  @override
  Future<String?> pickDocument() async => 'content://models/selected';

  @override
  Future<String> importModel(String uri, CatalogModel model) async {
    if (shouldFail) {
      throw StateError(
        'The selected file is not a valid ${model.displayName} archive: '
        'The archive is missing required files.',
      );
    }
    final result = await importCompleter.future;
    installed[model.id] = model.files;
    return result;
  }

  @override
  Future<Map<String, List<String>>> listInstalled() async => installed;

  @override
  Future<bool> delete(String modelId) async {
    installed.remove(modelId);
    return true;
  }
}
