# ReXorder: offline voice recorder for Android (plan)

Record → transcribe (English/Japanese) → label speakers, entirely on the device.

## Decisions (agreed)
- **Framework: Flutter** (Dart). Native Kotlin is kept to a small foreground-service shim.
- **Completely offline**: works out of the box. All models are bundled and nothing is ever downloaded. The `INTERNET` permission is explicitly removed from the merged release manifest, and CI checks this.
- **Distribution**: sideloaded APK first. Play Store requirements are sketched below.
- **Languages**: English and Japanese, auto-detected for each chunk.
- **Transcription runs after recording stops.** No live captions in v1.
- Commits go straight to `main`.

## Stack
| Concern | Choice |
|---|---|
| App | Flutter, Riverpod, go_router, freezed, drift (SQLite) |
| Capture | `record` package streaming PCM16 at 16 kHz mono. The app writes the chunks to a `.pcm` file as they arrive, then wraps it in a WAV header on stop. If the app is killed mid-recording, the orphaned `.pcm` files are recovered on the next launch. |
| Background | Small Kotlin foreground service (`foregroundServiceType="microphone"`) started over a MethodChannel while recording. A second service of type `dataSync` (or `mediaProcessing` on API 35+) runs transcription. |
| Playback / share | `just_audio`, `share_plus` |
| ML runtime | `sherpa_onnx` Flutter package (Dart FFI over the prebuilt sherpa-onnx native libraries), run in a background isolate |
| VAD | silero-vad, which splits audio into chunks of 30 s or less |
| ASR | Whisper multilingual int8. It detects one language per chunk, and the result includes `lang`. Compared against SenseVoice (zh/en/ja/ko/yue) on mixed EN/JA speech before choosing a default. |
| Diarization | `OfflineSpeakerDiarization`: pyannote segmentation-3.0 + speaker-embedding model + clustering, with an optional speaker-count hint |

## Processing pipeline
1. VAD over the 16 kHz WAV gives speech chunks.
2. Each chunk goes through Whisper with language auto-detect, which returns text, timestamps and `lang`. Results are saved per chunk so an interrupted job can resume.
3. Diarization over the full file gives `(start, end, speaker)` segments.
4. Merge: each ASR chunk gets the speaker with the most overlap, and chunks are split where the speaker changes.
5. Save, then show a notification.

Language note: a recording that switches EN↔JA between sentences or turns transcribes correctly. Code-switching within a single sentence does not; the chunk gets one language.

## Models: bundled, no downloads
- Models ship as Flutter assets. The sherpa-onnx Dart API needs real file paths, so the models are copied once to app-support storage on first launch. This uses extra disk space but no network.
- Base set: silero-vad, Whisper multilingual int8 (base or small, picked from benchmarks), segmentation, embedding.
- APK target is arm64-v8a only for release, with x86_64 also built for emulator/dev.
- Optional later: "import model file" to swap in larger models, still without network access.

## Phases
1. **Scaffold + recorder core**: Flutter app, CI (analyze, test, release APK, no-INTERNET check), foreground recording service, crash-safe PCM→WAV capture, drift library, playback, rename/delete/share.
2. **Benchmark + offline transcription**: bundle the models, run a benchmark screen on the emulator and on Q.'s phone, then build the VAD → Whisper pipeline (background isolate, resumable job), a transcript view synced to playback, and manual language override.
3. **Speaker detection**: diarization, merge, speaker colors and renaming, speaker-count hint, re-run.
4. **Polish**: exports (TXT/SRT/VTT/JSON), full-text search, bookmarks, a "transcribe only while charging" option, and the model import screen.

## Play Store: technical requirements (not planned yet)
Items to re-check against current Play policy when the time comes:
- **Format**: AAB, not APK. The base module has a compressed download-size cap, so bundled models must move into **Play Asset Delivery install-time asset packs**. These are still installed with the app, so the "no downloads" rule holds, and the app reads them through the Android AssetManager (a small Kotlin bridge copies them to files on first run). Pack size limits need checking against current docs.
- **Target SDK**: must meet Play's current target-API-level requirement, which rises yearly.
- **16 KB page size**: native `.so` files (sherpa-onnx, onnxruntime) must be 16 KB-aligned for Android 15+ devices. Check the prebuilt libraries' alignment.
- **Foreground service declarations**: Play Console requires a declaration and justification (plus a video) for `microphone` and `dataSync`/`mediaProcessing` FGS types.
- **Permissions/policy**: RECORD_AUDIO needs an in-app prominent disclosure. The Data safety form says "no data collected or shared", which holds because there is no INTERNET permission. A privacy policy URL is still required.
- **Signing**: Play App Signing (upload key) instead of the sideload keystore. Version codes come from CI.
- **Store listing**: screenshots, content rating questionnaire, and a target-audience declaration.

## Risks
- Whisper speed on mid-range phones for long recordings. Mitigations: per-chunk resume, a charging-only option, and model choice informed by the Phase 2 benchmark.
- Japanese accuracy is much better with larger Whisper models, which trades against APK size. The benchmark decides.
- Diarization degrades with overlapping speech and far-field audio. The speaker-count hint and manual merge/rename help.
