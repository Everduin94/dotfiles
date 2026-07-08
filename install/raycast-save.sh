#!/usr/bin/env bash

set -euo pipefail

FILE="$HOME/.config/raycast/config.rayconfig"
SOURCE="${1:-}"

if [[ -z "$SOURCE" ]]; then
  SOURCE=$(ls -t "$HOME"/Downloads/*.rayconfig 2>/dev/null | head -1 || true)
fi

if [[ -z "$SOURCE" || ! -f "$SOURCE" ]]; then
  echo "No Raycast export found."
  echo "Export your config from Raycast first, then run this script again."
  exit 1
fi

if [[ ! -e "$FILE" ]]; then
  echo "Missing $FILE"
  echo "Stow your Raycast package first."
  exit 1
fi

TARGET=$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$FILE")
mkdir -p "$(dirname "$TARGET")"
cp "$SOURCE" "$TARGET"

echo

echo "Saved $SOURCE"
echo "-> $TARGET"
