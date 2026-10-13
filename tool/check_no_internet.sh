#!/usr/bin/env bash
set -euo pipefail

apk="${1:?Usage: check_no_internet.sh <apk>}"
aapt2="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}/build-tools"
if command -v aapt2 >/dev/null 2>&1; then
  aapt2_bin="$(command -v aapt2)"
else
  aapt2_bin="$(find "$aapt2" -mindepth 2 -maxdepth 2 -type f -name aapt2 -printf '%p\n' | sort -V | tail -n 1)"
fi
if [[ -z "${aapt2_bin:-}" || ! -x "$aapt2_bin" ]]; then
  echo "aapt2 not found; install Android build-tools or add aapt2 to PATH." >&2
  exit 2
fi

permissions="$("$aapt2_bin" dump permissions "$apk")"
printf '%s\n' "$permissions"
if grep -Eq 'android\.permission\.(INTERNET|ACCESS_NETWORK_STATE)' <<<"$permissions"; then
  echo "Forbidden network permission found in $apk" >&2
  exit 1
fi
echo "PASS: no INTERNET or ACCESS_NETWORK_STATE permission in $apk"
