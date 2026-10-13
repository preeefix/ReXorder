# ReXorder

An offline voice recorder for Android with on-device English and Japanese transcription. ReXorder never connects to the network: download official model files separately and import them locally. See [model download and import instructions](docs/MODELS.md).

The app includes crash-safe PCM capture, resumable transcription, playback, transcript navigation, and model benchmarking.

See [the full project plan](docs/PLAN.md) for the roadmap.

Release APKs are debug-signed for sideloading in Phase 1. TODO: configure a sideload keystore through CI secrets before distributing signed production builds.
