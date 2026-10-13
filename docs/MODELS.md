# Model downloads and imports

ReXorder never downloads models or audio and has no `INTERNET` permission. Download a model from its official release link outside the app, then import the downloaded file from **Settings → Models**. The app streams the selected file into private storage and extracts only the model files needed by sherpa-onnx. Before installing an archive, it checks that the expected model files are present.

| Model | Download size | Official download | Purpose |
|---|---:|---|---|
| Silero VAD | 643,854 bytes | [silero_vad.onnx](https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/silero_vad.onnx) | Detect speech boundaries |
| Whisper Small | 639,387,718 bytes | [archive](https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-small.tar.bz2) | Multilingual English/Japanese transcription |
| Whisper Turbo | 563,790,207 bytes | [archive](https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-turbo.tar.bz2) | Faster multilingual transcription benchmark |
| SenseVoice | 163,002,883 bytes | [archive](https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2) | English/Japanese transcription benchmark |

## Import steps

1. Open **Settings → Models**.
2. Tap **Open download link** for a model and download the file in the browser, or copy the link to another device.
3. Return to ReXorder and tap **Import…**. Select the downloaded `.onnx` file for Silero VAD or the `.tar.bz2` archive for an ASR model.
4. Wait for extraction to finish. Imported files stay in the app's private storage and are not added to the APK.

The SenseVoice archive also provides `test_wavs/ja.wav` and `test_wavs/en.wav`; these are imported as local benchmark samples. Developer-only `tool/fetch_models.sh` downloads the pinned release files into the ignored `dev-models/` directory for emulator testing.
