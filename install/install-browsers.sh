#!/usr/bin/env bash

set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required."
  echo 'Install it first: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

for cask in google-chrome zen; do
  if brew list --cask "$cask" >/dev/null 2>&1; then
    echo "$cask already installed."
  else
    brew install --cask "$cask"
  fi
done

echo
echo "Done."
echo "Installed browsers: google-chrome, zen"
