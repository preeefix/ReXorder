# ReXorder: offline voice recorder for Android (plan)

Record → transcribe (English/Japanese) → label speakers, entirely on the device.

## Decisions (agreed)
- **Framework: Flutter** (Dart). Native Kotlin is kept to a small foreground-service shim.
- **Completely offline at runtime**: the app has no `INTERNET` permission and never downloads audio or models. Users download official model files outside the app and import them from local storage.
- **Distribution**: sideloaded APK first. Play Store requirements are sketched below.
- **Languages**: English and Japanese, auto-detected for each chunk.
- **Transcription runs after recording stops.** No live captions in v1.
- Commits go straight to `main`.

## Stack
| Concern | Choice |
|---|---|
| App | Flutter, Riverpod, go_router, freezed, drift (SQLite) |
| Capture | `record` package streaming PCM16 at 16 kHz mono. The app writes the chunks to a `.pcm` file as they arrive, then wraps it in a WAV header on stop. If the app is killed mid-recording, the orphaned `.pcm` files are recovered on the next launch. |
| Background | Kotlin foreground services for recording (`microphone`) and transcription (`dataSync` or `mediaProcessing` on API 35+), controlled over MethodChannels. |
| Playback / share | `just_audio`, `share_plus` |
| ML runtime | `sherpa_onnx` Flutter package (Dart FFI over the prebuilt sherpa-onnx native libraries), run in a background isolate |
| VAD | Imported Silero VAD splits audio into segments no longer than 20 s. |
| ASR | Imported Whisper multilingual int8 or SenseVoice; installed models are benchmarked on-device. |
| Diarization | `OfflineSpeakerDiarization`: pyannote segmentation-3.0 + speaker-embedding model + clustering, with an optional speaker-count hint |

## Processing pipeline
1. VAD over the 16 kHz WAV gives speech chunks.
2. Each chunk goes through Whisper with language auto-detect, which returns text, timestamps and `lang`. Results are saved per chunk so an interrupted job can resume.
3. Diarization over the full file gives `(start, end, speaker)` segments.
4. Merge: each ASR chunk gets the speaker with the most overlap, and chunks are split where the speaker changes.
5. Save, then show a notification.

Language note: a recording that switches EN↔JA between sentences or turns transcribes correctly. Code-switching within a single sentence does not; the chunk gets one language.

## Models: local imports, no bundled assets
- APKs contain no ONNX model files. Users download pinned models from the official sherpa-onnx release page and import them through Android's system document picker.
- A Kotlin importer streams and selectively extracts the files into app-private storage. Imported Whisper, SenseVoice, and Silero VAD models are used only on-device.
- CI checks APK permissions and asserts that no `.onnx` model files are packaged.

## Phases
1. **Scaffold + recorder core**: Flutter app, CI (analyze, test, release APK, no-INTERNET check), foreground recording service, crash-safe PCM→WAV capture, drift library, playback, rename/delete/share.
2. **Benchmark + offline transcription**: import models locally, benchmark them on the emulator and on Q.'s phone, then build the VAD → ASR pipeline (background isolate, resumable job), a transcript view synced to playback, and manual language override.
3. **Speaker detection**: diarization, merge, speaker colors and renaming, speaker-count hint, re-run.
4. **Polish**: exports (TXT/SRT/VTT/JSON), full-text search, bookmarks, and a "transcribe only while charging" option.

## Play Store: technical requirements (not planned yet)
Items to re-check against current Play policy when the time comes:
- **Format**: AAB, not APK. Imported model files remain in app-private storage and are not part of the app bundle.
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
