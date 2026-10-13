#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
model_directory="$repo_root/dev-models"
mkdir -p "$model_directory"

fetch_model() {
    local file_name="$1"
    local release_tag="${2:-asr-models}"
    local destination="$model_directory/$file_name"
    local download="$model_directory/.$file_name.$$.download"
    local url="https://github.com/k2-fsa/sherpa-onnx/releases/download/$release_tag/$file_name"

    if [[ -f "$destination" ]]; then
        printf 'Already present: %s\n' "$file_name"
        return
    fi

    rm -f "$download"
    curl -fL --retry 3 --retry-delay 2 "$url" -o "$download"
    mv "$download" "$destination"
    printf 'Fetched: %s\n' "$file_name"
}

fetch_model "silero_vad.onnx"
fetch_model "sherpa-onnx-whisper-small.tar.bz2"
fetch_model "sherpa-onnx-whisper-turbo.tar.bz2"
fetch_model "sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2"
fetch_model "sherpa-onnx-pyannote-segmentation-3-0.tar.bz2" "speaker-segmentation-models"
fetch_model "3dspeaker_speech_campplus_sv_zh_en_16k-common_advanced.onnx" "speaker-recongition-models"
