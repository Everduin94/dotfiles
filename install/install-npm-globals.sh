#!/usr/bin/env bash

set -euo pipefail

export NVM_DIR="$HOME/.nvm"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm not found. Run install/install-node.sh first."
  exit 1
fi

npm install -g @redocly/cli better-commits

echo
echo "Done."
echo "Installed npm dependencies."
