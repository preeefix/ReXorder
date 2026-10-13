enum ModelType { whisper, sensevoice, vad }

class CatalogModel {
  const CatalogModel({
    required this.id,
    required this.displayName,
    required this.type,
    required this.url,
    required this.fileName,
    required this.sha256,
    required this.sizeBytes,
    required this.files,
  });

  final String id;
  final String displayName;
  final ModelType type;
  final String url;
  final String fileName;
  final String sha256;
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
    sha256: '9e2449e1087496d8d4caba907f23e0bd3f78d91fa552479bb9c23ac09cbb1fd6',
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
    sha256: '486a46afbb7ba798507190ffe02fea2dd726049af212e774537efac6afb210a6',
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
    sha256: 'b11acbbcd660b44a8e0df33724feb5aaa709cf65668f2823d59f656312544f22',
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
    sha256: '7d1efa2138a65b0b488df37f8b89e3d91a60676e416f515b952358d83dfd347e',
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
