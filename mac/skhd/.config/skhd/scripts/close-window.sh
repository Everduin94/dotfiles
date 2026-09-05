#!/usr/bin/env sh

CURRENT_ID="$(yabai -m query --windows --window 2>/dev/null | jq -r '.id // empty')"
[ -n "$CURRENT_ID" ] || exit 1

# Capture a usable window on this Space before the current app loses focus.
# Prefer tiled windows, then fall back to a floating window.
TARGET_ID="$(
  yabai -m query --windows --space 2>/dev/null |
    jq -r --argjson current "$CURRENT_ID" '
      [
        .[]
        | select(.id != $current)
        | select(."is-minimized" == false and ."is-hidden" == false)
      ]
      | sort_by(."is-floating")
      | first.id // empty
    '
)"

# Close only the selected macOS window; this never sends Command+Q.
yabai -m window "$CURRENT_ID" --close || exit 1

# Closing is asynchronous. Restore focus after the window leaves the tree.
if [ -n "$TARGET_ID" ]; then
  sleep 0.15
  yabai -m window "$TARGET_ID" --focus >/dev/null 2>&1 || true
fi
