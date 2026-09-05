#!/usr/bin/env sh

if [ "$SENDER" = "front_app_switched" ]; then
  APP="$INFO"
else
  APP="$(yabai -m query --windows --window 2>/dev/null | jq -r '.app // ""')"
fi

sketchybar --set "$NAME" label="$APP"
