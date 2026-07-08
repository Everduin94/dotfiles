#!/usr/bin/env bash
set -euo pipefail

url="${COPY_CURSOR_HYPERLINK:-}"
line="${COPY_CURSOR_LINE:-}"
cursor_x="${COPY_CURSOR_X:-}"

if [[ -z "$url" && -n "$line" && -n "$cursor_x" ]]; then
  url="$({
    URL_LINE="$line" URL_CURSOR_X="$cursor_x" python3 <<'PY'
import os
import re

line = os.environ["URL_LINE"]
cursor_x = int(os.environ["URL_CURSOR_X"])
pattern = re.compile(r"https?://[^\s<>\"']+")
trim_chars = ".,;:!?)]}>"

for match in pattern.finditer(line):
    candidate = match.group(0).rstrip(trim_chars)
    start = match.start()
    end = start + len(candidate)
    if start <= cursor_x < end:
        print(candidate)
        break
PY
  })"
fi

if [[ -z "$url" ]]; then
  tmux display-message "No URL under cursor"
  exit 0
fi

if command -v open >/dev/null 2>&1; then
  open "$url" >/dev/null 2>&1 &
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$url" >/dev/null 2>&1 &
else
  tmux display-message "No URL opener found"
  exit 1
fi
