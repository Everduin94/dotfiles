#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
settings_file="$HOME/Library/Application Support/voice-control/settings.json"
output_file="$repo_dir/mac/hex/.local/share/hex/dictation-processing.json"

if pgrep -f '/Hex.app/Contents/MacOS/hex' >/dev/null; then
  echo "Quit Hex before saving corrections." >&2
  exit 1
fi

if [ ! -f "$settings_file" ]; then
  echo "Hex settings not found: $settings_file" >&2
  exit 1
fi

tmp=$(mktemp "$output_file.tmp.XXXXXX")
trap 'rm -f "$tmp"' EXIT
jq -e '.dictation_processing' "$settings_file" > "$tmp"
mv "$tmp" "$output_file"
trap - EXIT

echo "Saved Hex corrections to $output_file"
