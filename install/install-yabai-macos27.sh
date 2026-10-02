#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORMULA="$SCRIPT_DIR/yabai-macos27.rb"
TAP="everduin/local"
TAP_REPOSITORY="$(brew --repository)/Library/Taps/everduin/homebrew-local"

if [[ "$(sw_vers -productVersion | cut -d. -f1)" != "27" ]]; then
    echo "This temporary yabai build is intended only for macOS 27." >&2
    exit 1
fi

sdk_major="$(xcrun --show-sdk-version 2>/dev/null | cut -d. -f1 || true)"
if [[ "$sdk_major" != "27" ]]; then
    cat >&2 <<'EOF'
The macOS 27 Command Line Tools are required to build patched yabai.
Install "Command Line Tools for Xcode 27.0" in System Settings -> General ->
Software Update, or find its exact command-line label with:

  softwareupdate --list
EOF
    exit 1
fi

if [[ "${1:-}" == "--restore-official" ]]; then
    yabai --stop-service >/dev/null 2>&1 || true
    brew unlink yabai-macos27 >/dev/null 2>&1 || true
    brew uninstall yabai-macos27 >/dev/null 2>&1 || true
    if ! brew list --versions yabai >/dev/null 2>&1; then
        brew install asmvik/formulae/yabai
    fi
    brew link --overwrite yabai
    /opt/homebrew/bin/yabai --start-service
    brew untap --force "$TAP" >/dev/null 2>&1 || true

    python3 - <<'PY'
import json
import os

path = os.path.expanduser('~/.homebrew/trust.json')
if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)
    formulae = data.get('formulae', [])
    data['formulae'] = [item for item in formulae if item != 'everduin/local/yabai-macos27']
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')
PY

    echo "Restored the official Homebrew yabai and removed the temporary local tap."
    exit 0
fi

if ! brew list --versions yabai >/dev/null 2>&1; then
    brew install asmvik/formulae/yabai
fi

if ! brew tap | grep -qx "$TAP"; then
    brew tap-new "$TAP"
fi
mkdir -p "$TAP_REPOSITORY/Formula"
cp "$FORMULA" "$TAP_REPOSITORY/Formula/yabai-macos27.rb"
git -C "$TAP_REPOSITORY" add Formula/yabai-macos27.rb
if ! git -C "$TAP_REPOSITORY" diff --cached --quiet; then
    git -C "$TAP_REPOSITORY" commit -m "Add pinned macOS 27 yabai formula" >/dev/null
fi

rollback_required=1
rollback() {
    status=$?
    if [[ "$rollback_required" -eq 1 ]]; then
        echo "Patched yabai installation failed; restoring official yabai." >&2
        brew unlink yabai-macos27 >/dev/null 2>&1 || true
        brew link --overwrite yabai >/dev/null 2>&1 || true
        /opt/homebrew/bin/yabai --start-service >/dev/null 2>&1 || true
    fi
    exit "$status"
}
trap rollback ERR

if command -v yabai >/dev/null 2>&1; then
    yabai --stop-service >/dev/null 2>&1 || true
fi
brew unlink yabai >/dev/null 2>&1 || true

if brew list --versions yabai-macos27 >/dev/null 2>&1; then
    brew upgrade "$TAP/yabai-macos27"
else
    brew install "$TAP/yabai-macos27"
fi

brew link --overwrite yabai-macos27
/opt/homebrew/bin/yabai --start-service
rollback_required=0
trap - ERR

sleep 1
if /opt/homebrew/bin/yabai -m query --spaces >/dev/null 2>&1; then
    cat <<'EOF'

Installed and started the pinned macOS 27 yabai build successfully.
EOF
else
    cat <<'EOF'

Installed the pinned macOS 27 yabai build, but Accessibility blocked its new
ad-hoc signature. In System Settings -> Privacy & Security -> Accessibility:

1. Remove the existing yabai entry.
2. Click +, press Command+Shift+G, and add /opt/homebrew/bin/yabai.
3. Enable yabai and run: yabai --restart-service
EOF
fi
