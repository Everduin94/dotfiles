#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
source_file="$repo_dir/mac/hex/.local/share/hex/dictation-processing.json"
support_dir="$HOME/Library/Application Support/voice-control"
settings_file="$support_dir/settings.json"

if pgrep -f '/Hex.app/Contents/MacOS/hex' >/dev/null; then
  echo "Quit Hex before importing corrections." >&2
  exit 1
fi

if [ ! -f "$settings_file" ]; then
  echo "Hex settings not found. Launch Hex and complete setup first." >&2
  exit 1
fi

jq empty "$source_file"
cp "$settings_file" "$settings_file.backup"
tmp=$(mktemp "$support_dir/settings.json.tmp.XXXXXX")
trap 'rm -f "$tmp"' EXIT
jq --slurpfile processing "$source_file" \
  '.dictation_processing = $processing[0]' "$settings_file" > "$tmp"
mv "$tmp" "$settings_file"
trap - EXIT

echo "Imported Hex corrections. Launch Hex to load them."
