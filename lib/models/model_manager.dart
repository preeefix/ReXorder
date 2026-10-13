import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model_catalog.dart';
import 'model_import_client.dart';

enum ModelImportPhase { idle, picking, importing, success, failure }

class ModelManagerState {
  const ModelManagerState({
    this.installedFiles = const {},
    this.isLoading = true,
    this.phase = ModelImportPhase.idle,
    this.currentModelId,
    this.bytesRead = 0,
    this.totalBytes = 0,
    this.message,
  });

  final Map<String, List<String>> installedFiles;
  final bool isLoading;
  final ModelImportPhase phase;
  final String? currentModelId;
  final int bytesRead;
  final int totalBytes;
  final String? message;

  Set<String> get installedModelIds => {
    for (final model in modelCatalog)
      if (model.files.every(
        (file) => installedFiles[model.id]?.contains(file) ?? false,
      ))
        model.id,
  };

  bool get hasVad => installedModelIds.contains('silero-vad');
  bool get hasAsr => modelCatalog.any(
    (model) => model.isAsr && installedModelIds.contains(model.id),
  );
  bool get hasDiarization =>
      installedModelIds.contains('pyannote-segmentation') &&
      installedModelIds.contains('campplus-zh-en');

  ModelManagerState copyWith({
    Map<String, List<String>>? installedFiles,
    bool? isLoading,
    ModelImportPhase? phase,
    String? currentModelId,
    int? bytesRead,
    int? totalBytes,
    String? message,
    bool clearMessage = false,
    bool clearCurrentModel = false,
  }) => ModelManagerState(
    installedFiles: installedFiles ?? this.installedFiles,
    isLoading: isLoading ?? this.isLoading,
    phase: phase ?? this.phase,
    currentModelId: clearCurrentModel
        ? null
        : currentModelId ?? this.currentModelId,
    bytesRead: bytesRead ?? this.bytesRead,
    totalBytes: totalBytes ?? this.totalBytes,
    message: clearMessage ? null : message ?? this.message,
  );
}

final modelImportClientProvider = Provider<ModelImportClient>(
  (ref) => const MethodChannelModelImportClient(),
);

final modelManagerProvider =
    NotifierProvider<ModelManagerController, ModelManagerState>(
      ModelManagerController.new,
    );

class ModelManagerController extends Notifier<ModelManagerState> {
  StreamSubscription<ModelImportProgress>? _progressSubscription;

  ModelImportClient get _client => ref.read(modelImportClientProvider);

  @override
  ModelManagerState build() {
    ref.onDispose(() => unawaited(_progressSubscription?.cancel()));
    unawaited(refresh());
    return const ModelManagerState();
  }

  Future<void> refresh() async {
    try {
      final installed = await _client.listInstalled();
      state = state.copyWith(installedFiles: installed, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, message: error.toString());
    }
  }

  Future<void> importModel(CatalogModel model) async {
    state = state.copyWith(
      phase: ModelImportPhase.picking,
      currentModelId: model.id,
      bytesRead: 0,
      totalBytes: model.sizeBytes,
      clearMessage: true,
    );
    try {
      final uri = await _client.pickDocument();
      if (uri == null) {
        state = state.copyWith(
          phase: ModelImportPhase.idle,
          clearCurrentModel: true,
        );
        return;
      }
      await _progressSubscription?.cancel();
      _progressSubscription = _client.progress.listen((progress) {
        if (progress.modelId == model.id) {
          state = state.copyWith(
            phase: ModelImportPhase.importing,
            bytesRead: progress.bytesRead,
            totalBytes: progress.totalBytes > 0
                ? progress.totalBytes
                : model.sizeBytes,
          );
        }
      });
      state = state.copyWith(phase: ModelImportPhase.importing);
      await _client.importModel(uri, model);
      await refresh();
      state = state.copyWith(
        phase: ModelImportPhase.success,
        message: '${model.displayName} imported.',
      );
    } catch (error) {
      state = state.copyWith(
        phase: ModelImportPhase.failure,
        message: error.toString(),
      );
    } finally {
      await _progressSubscription?.cancel();
      _progressSubscription = null;
    }
  }

  Future<void> deleteModel(CatalogModel model) async {
    try {
      await _client.delete(model.id);
      await refresh();
      state = state.copyWith(
        phase: ModelImportPhase.success,
        message: '${model.displayName} deleted.',
      );
    } catch (error) {
      state = state.copyWith(
        phase: ModelImportPhase.failure,
        message: error.toString(),
      );
    }
  }
}
