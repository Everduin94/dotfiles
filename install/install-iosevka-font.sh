#!/usr/bin/env bash

set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required."
  echo 'Install it first: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

if brew list --cask font-iosevka >/dev/null 2>&1; then
  echo "font-iosevka already installed."
else
  brew install --cask font-iosevka
fi

echo
echo "Done."
echo "Ghostty in this repo is already configured to use Iosevka."
echo "If Ghostty was open, quit and reopen it."
