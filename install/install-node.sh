#!/usr/bin/env bash

set -euo pipefail

export PROFILE=/dev/null
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash

# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"

nvm install --lts
nvm alias default 'lts/*'

echo
echo "Done."
echo "Installed nvm and the current Node LTS."
echo "Restart your shell if nvm is not available yet."
