#!/usr/bin/env bash

set -euo pipefail

FILE="$HOME/.config/raycast/config.rayconfig"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is for macOS only."
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "Missing $FILE"
  echo "Place or stow a Raycast export there first."
  exit 1
fi

echo "Note: this repo ships with an encrypted Raycast configuration for everduin94."
echo "If that is not you, replace $FILE with your own Raycast export before importing."
echo

open -a Raycast "$FILE"

echo "Opened $FILE in Raycast."
echo "Raycast should prompt you to import and overwrite the current config."
