#!/usr/bin/env sh

VPN_BIN="/opt/cisco/secureclient/bin/vpn"
CONNECTED_COLOR="0xffa6da95"
DISCONNECTED_COLOR="0xffed8796"
UNKNOWN_COLOR="0xff7f8490"

if [ ! -x "$VPN_BIN" ]; then
  STATE="Unavailable"
else
  OUTPUT="$(perl -e 'alarm 5; exec @ARGV' "$VPN_BIN" state 2>/dev/null)"
  STATE="$(printf '%s\n' "$OUTPUT" | awk -F': ' '/>> state:/ { gsub(/\r/, "", $2); state=$2 } END { print state }')"
fi

case "$STATE" in
  Connected)
    COLOR="$CONNECTED_COLOR"
    ;;
  Disconnected)
    COLOR="$DISCONNECTED_COLOR"
    ;;
  *)
    COLOR="$UNKNOWN_COLOR"
    ;;
esac

sketchybar --set "$NAME" \
  label="VPN" \
  label.color="$COLOR"
