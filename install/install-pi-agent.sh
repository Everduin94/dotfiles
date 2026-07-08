#!/usr/bin/env bash

set -euo pipefail

curl -fsSL https://pi.dev/install.sh | sh

echo
echo "Done."
echo "Installed pi agent."
echo "Restart your shell if the pi command is not available yet."
