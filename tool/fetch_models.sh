#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
model_directory="$repo_root/dev-models"
mkdir -p "$model_directory"

fetch_model() {
    local file_name="$1"
    local expected_sha256="$2"
    local destination="$model_directory/$file_name"
    local download="$model_directory/.$file_name.$$.download"
    local url="https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/$file_name"

    if [[ -f "$destination" ]] &&
        [[ "$(sha256sum "$destination" | cut -d' ' -f1)" == "$expected_sha256" ]]; then
        printf 'Verified: %s\n' "$file_name"
        return
    fi

    rm -f "$download"
    curl -fL --retry 3 --retry-delay 2 "$url" -o "$download"
    local actual_sha256
    actual_sha256="$(sha256sum "$download" | cut -d' ' -f1)"
    if [[ "$actual_sha256" != "$expected_sha256" ]]; then
        rm -f "$download"
        printf 'SHA-256 mismatch for %s: expected %s, got %s\n' \
            "$file_name" "$expected_sha256" "$actual_sha256" >&2
        return 1
    fi
    mv "$download" "$destination"
    printf 'Fetched and verified: %s\n' "$file_name"
}

fetch_model \
    "silero_vad.onnx" \
    "9e2449e1087496d8d4caba907f23e0bd3f78d91fa552479bb9c23ac09cbb1fd6"
fetch_model \
    "sherpa-onnx-whisper-small.tar.bz2" \
    "486a46afbb7ba798507190ffe02fea2dd726049af212e774537efac6afb210a6"
fetch_model \
    "sherpa-onnx-whisper-turbo.tar.bz2" \
    "b11acbbcd660b44a8e0df33724feb5aaa709cf65668f2823d59f656312544f22"
fetch_model \
    "sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2" \
    "7d1efa2138a65b0b488df37f8b89e3d91a60676e416f515b952358d83dfd347e"
