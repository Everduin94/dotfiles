#!/usr/bin/env bash

set -euo pipefail

defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2
defaults write com.apple.dock autohide -bool true

python3 - <<'PY'
import os
import plistlib

path = os.path.expanduser('~/Library/Preferences/com.apple.symbolichotkeys.plist')

if os.path.exists(path):
    with open(path, 'rb') as f:
        data = plistlib.load(f)
else:
    data = {}

hotkeys = data.setdefault('AppleSymbolicHotKeys', {})
seed = {
    '64': [32, 49, 1048576],
    '65': [32, 49, 1572864],
}

for key, parameters in seed.items():
    entry = hotkeys.get(key, {})
    value = entry.get('value', {'parameters': parameters, 'type': 'standard'})
    hotkeys[key] = {
        'enabled': False,
        'value': value,
    }

with open(path, 'wb') as f:
    plistlib.dump(data, f)
PY

killall cfprefsd >/dev/null 2>&1 || true
killall Dock >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true

echo
echo "Done."
echo "Set fast key repeat, disabled Spotlight shortcuts, and turned on Dock auto-hide."
echo "Caps Lock is handled by Karabiner."
