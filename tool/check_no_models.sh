#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f "$1" ]]; then
    printf 'Usage: %s <apk>\n' "$0" >&2
    exit 2
fi

apk="$1"
onnx_count="$(unzip -l "$apk" | awk '$NF ~ /\.onnx$/ { count++ } END { print count + 0 }')"
if [[ "$onnx_count" -ne 0 ]]; then
    printf 'FAIL: %s contains %s ONNX model file(s)\n' "$apk" "$onnx_count" >&2
    exit 1
fi

printf 'PASS: no ONNX model files in %s\n' "$apk"
