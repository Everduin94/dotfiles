#!/bin/sh
set -eu

script="$HOME/.config/tmux/plugins/easyjump.tmux/easyjump.py"
pane_id="$(tmux display-message -p '#{pane_id}')"

if [ ! -f "$script" ]; then
  tmux display-message 'easyjump.tmux is not installed yet'
  exit 1
fi

cleanup() {
  tmux set-option -gu @pi_easyjump_active 2>/dev/null || true

  if [ "$(tmux display-message -p -t "$pane_id" '#{pane_mode}')" = "copy-mode" ]; then
    tmux set-option -g pane-active-border-style 'fg=#a6e3a1' 2>/dev/null || true
  else
    tmux set-option -g pane-active-border-style 'fg=#89b4fa' 2>/dev/null || true
  fi

  tmux refresh-client -S 2>/dev/null || true
}

trap cleanup EXIT HUP INT TERM

tmux set-option -g @pi_easyjump_active 1
tmux set-option -g pane-active-border-style 'fg=#cba6f7'
tmux refresh-client -S

python3 "$script" \
  --mode=xcopy \
  --smart-case "$(tmux show-option -gqv @easyjump-smart-case)" \
  --label-chars "$(tmux show-option -gqv @easyjump-label-chars)" \
  --label-attrs "$(tmux show-option -gqv @easyjump-label-attrs)" \
  --text-attrs "$(tmux show-option -gqv @easyjump-text-attrs)" \
  --auto-begin-selection "$(tmux show-option -gqv @easyjump-auto-begin-selection)"
