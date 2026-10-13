import 'package:flutter/services.dart';

import 'model_catalog.dart';

class ModelImportProgress {
  const ModelImportProgress({
    required this.modelId,
    required this.bytesRead,
    required this.totalBytes,
    this.stage = 'copying',
  });

  final String modelId;
  final int bytesRead;
  final int totalBytes;
  final String stage;

  factory ModelImportProgress.fromEvent(Object? event) {
    final value = event as Map<Object?, Object?>;
    return ModelImportProgress(
      modelId: value['modelId']! as String,
      bytesRead: (value['bytesRead']! as num).toInt(),
      totalBytes: (value['totalBytes']! as num).toInt(),
      stage: value['stage'] as String? ?? 'copying',
    );
  }
}

abstract interface class ModelImportClient {
  Stream<ModelImportProgress> get progress;
  Future<String?> pickDocument();
  Future<String> importModel(String uri, CatalogModel model);
  Future<Map<String, List<String>>> listInstalled();
  Future<bool> delete(String modelId);
}

class MethodChannelModelImportClient implements ModelImportClient {
  const MethodChannelModelImportClient();

  static const _methods = MethodChannel('rexorder/models');
  static const _events = EventChannel('rexorder/models/progress');

  @override
  Stream<ModelImportProgress> get progress =>
      _events.receiveBroadcastStream().map(ModelImportProgress.fromEvent);

  @override
  Future<String?> pickDocument() =>
      _methods.invokeMethod<String>('pickDocument');

  @override
  Future<String> importModel(String uri, CatalogModel model) async {
    return (await _methods.invokeMethod<String>('importModel', {
      'uri': uri,
      'modelId': model.id,
      'displayName': model.displayName,
      'kind': model.importKind,
      'files': model.files,
      if (model.importKind == 'file') 'targetFileName': model.files.single,
    }))!;
  }

  @override
  Future<Map<String, List<String>>> listInstalled() async {
    final result = await _methods.invokeMapMethod<String, dynamic>(
      'listInstalled',
    );
    return {
      for (final entry
          in result?.entries ?? const <MapEntry<String, dynamic>>[])
        entry.key: List<String>.from(entry.value as List),
    };
  }

  @override
  Future<bool> delete(String modelId) async =>
      await _methods.invokeMethod<bool>('delete', {'modelId': modelId}) ??
      false;
}
