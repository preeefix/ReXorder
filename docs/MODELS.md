# Model downloads and imports

ReXorder never downloads models or audio and has no `INTERNET` permission. Download a model from its official release link outside the app, then import the downloaded file from **Settings → Models**. The app streams the selected file into private storage and extracts only the model files needed by sherpa-onnx. Before installing an archive, it checks that the expected model files are present.

| Model | Download size | Official download | Purpose |
|---|---:|---|---|
| Silero VAD | 643,854 bytes | [silero_vad.onnx](https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/silero_vad.onnx) | Detect speech boundaries |
| Whisper Small | 639,387,718 bytes | [archive](https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-small.tar.bz2) | Multilingual English/Japanese transcription |
| Whisper Turbo | 563,790,207 bytes | [archive](https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-turbo.tar.bz2) | Faster multilingual transcription benchmark |
| SenseVoice | 163,002,883 bytes | [archive](https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2) | English/Japanese transcription benchmark |
| Speaker segmentation (pyannote 3.0) | 6,958,444 bytes | [archive](https://github.com/k2-fsa/sherpa-onnx/releases/download/speaker-segmentation-models/sherpa-onnx-pyannote-segmentation-3-0.tar.bz2) | Optional speaker detection |
| Speaker voiceprint (3D-Speaker CAM++) | 28,281,164 bytes | [embedding model](https://github.com/k2-fsa/sherpa-onnx/releases/download/speaker-recongition-models/3dspeaker_speech_campplus_sv_zh_en_16k-common_advanced.onnx) | Optional speaker detection |

## Import steps

1. Open **Settings → Models**.
2. Tap **Open download link** for a model and download the file in the browser, or copy the link to another device.
3. Return to ReXorder and tap **Import…**. Select the downloaded `.onnx` file for Silero VAD or CAM++ or the `.tar.bz2` archive for an ASR or speaker-segmentation model.
4. Wait for extraction to finish. Imported files stay in the app's private storage and are not added to the APK.

Speaker detection is optional; import both speaker models to enable it. Transcription works as before without them.

The SenseVoice archive also provides `test_wavs/ja.wav` and `test_wavs/en.wav`; these are imported as local benchmark samples. Developer-only `tool/fetch_models.sh` downloads the release files into the ignored `dev-models/` directory for emulator testing.

SenseVoice is the default: it ran at about 35× real-time speed on Xperia 1 VII with the best Japanese accuracy; Whisper models remain available for re-transcription.
