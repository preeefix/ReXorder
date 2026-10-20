#!/usr/bin/env bash
set -euo pipefail

apk="${1:?Usage: check_release_signing.sh <apk>}"
build_tools="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}/build-tools"
if command -v apksigner >/dev/null 2>&1; then
  apksigner_bin="$(command -v apksigner)"
else
  apksigner_bin="$(find "$build_tools" -mindepth 2 -maxdepth 2 -type f -name apksigner -printf '%p\n' | sort -V | tail -n 1)"
fi
if [[ -z "${apksigner_bin:-}" || ! -x "$apksigner_bin" ]]; then
  echo "apksigner not found; install Android build-tools or add apksigner to PATH." >&2
  exit 2
fi

if ! verification_output="$("$apksigner_bin" verify --print-certs "$apk" 2>&1)"; then
  printf '%s\n' "$verification_output" >&2
  echo "APK signature verification failed: $apk" >&2
  exit 1
fi
printf '%s\n' "$verification_output"

if grep -Eq 'certificate DN:.*CN=Android Debug(,|$)' <<<"$verification_output"; then
  echo "Debug signing key is not allowed for release APK: $apk" >&2
  exit 1
fi

sha256_lines="$(grep -E 'certificate SHA-256 digest:' <<<"$verification_output" || true)"
if [[ -z "$sha256_lines" ]]; then
  echo "APK signer SHA-256 digest not found: $apk" >&2
  exit 1
fi
printf '%s\n' "$sha256_lines"
echo "PASS: APK is release-signed: $apk"
