# ReXorder

An offline voice recorder for Android with on-device English and Japanese transcription. ReXorder never connects to the network: download official model files separately and import them locally. See [model download and import instructions](docs/MODELS.md).

The app includes crash-safe PCM capture, resumable transcription, playback, transcript navigation, and model benchmarking.

See [the full project plan](docs/PLAN.md) for the roadmap.

## Release signing

Create a permanent release keystore and key with:

```sh
keytool -genkeypair -v -keystore release.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias rexorder
```

Add these GitHub repository secrets. Set `ANDROID_KEY_ALIAS` to `rexorder`; use the keystore and key passwords chosen with `keytool`.

- `ANDROID_KEYSTORE_BASE64`: output of `base64 < release.jks | tr -d '\n'`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

For local release builds, the same values can be placed in the gitignored `android/key.properties` file using the `storeFile`, `storePassword`, `keyAlias`, and `keyPassword` properties. CI writes the decoded keystore to its temporary directory and does not print the secret values.

Back up the keystore and passwords securely. Losing them prevents signing future updates. Switching from the existing debug-signed build to this release key requires uninstalling the app once before installing the new APK; uninstalling removes local recordings and imported models.
