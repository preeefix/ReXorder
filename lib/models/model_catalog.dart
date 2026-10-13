enum ModelType { whisper, sensevoice, vad }

class CatalogModel {
  const CatalogModel({
    required this.id,
    required this.displayName,
    required this.type,
    required this.url,
    required this.fileName,
    required this.sizeBytes,
    required this.files,
  });

  final String id;
  final String displayName;
  final ModelType type;
  final String url;
  final String fileName;
  final int sizeBytes;
  final List<String> files;

  bool get isAsr => type == ModelType.whisper || type == ModelType.sensevoice;
  String get importKind => type == ModelType.vad ? 'file' : 'tar.bz2';
}

const modelCatalog = <CatalogModel>[
  CatalogModel(
    id: 'silero-vad',
    displayName: 'Silero VAD',
    type: ModelType.vad,
    url:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/silero_vad.onnx',
    fileName: 'silero_vad.onnx',
    sizeBytes: 643854,
    files: ['silero_vad.onnx'],
  ),
  CatalogModel(
    id: 'whisper-small',
    displayName: 'Whisper Small',
    type: ModelType.whisper,
    url:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-small.tar.bz2',
    fileName: 'sherpa-onnx-whisper-small.tar.bz2',
    sizeBytes: 639387718,
    files: ['encoder.int8.onnx', 'decoder.int8.onnx', 'tokens.txt'],
  ),
  CatalogModel(
    id: 'whisper-turbo',
    displayName: 'Whisper Turbo',
    type: ModelType.whisper,
    url:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-turbo.tar.bz2',
    fileName: 'sherpa-onnx-whisper-turbo.tar.bz2',
    sizeBytes: 563790207,
    files: ['encoder.int8.onnx', 'decoder.int8.onnx', 'tokens.txt'],
  ),
  CatalogModel(
    id: 'sense-voice',
    displayName: 'SenseVoice',
    type: ModelType.sensevoice,
    url:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2',
    fileName: 'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2',
    sizeBytes: 163002883,
    files: [
      'model.int8.onnx',
      'tokens.txt',
      'test_wavs/ja.wav',
      'test_wavs/en.wav',
    ],
  ),
];

CatalogModel? modelById(String id) {
  for (final model in modelCatalog) {
    if (model.id == id) return model;
  }
  return null;
}

String formatModelSize(int bytes) {
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
