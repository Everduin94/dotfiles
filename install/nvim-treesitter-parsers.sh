#!/usr/bin/env bash
set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo "git is required" >&2
  exit 1
fi

if ! command -v tree-sitter >/dev/null 2>&1; then
  echo "tree-sitter CLI is required" >&2
  exit 1
fi

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
PARSER_DIR="$DATA_HOME/nvim/site/parser"
QUERY_DIR="$DATA_HOME/nvim/site/queries"
WORK_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

mkdir -p "$PARSER_DIR" "$QUERY_DIR"

patch_native_javascript_queries() {
  local file="$QUERY_DIR/javascript/highlights.scm"

  if [[ -f "$file" ]]; then
    python3 - "$file" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("\n (#is-not? local))", "\n)")
path.write_text(text)
PY
  fi
}

install_repo() {
  local lang="$1"
  local repo="$2"
  local build_subdir="${3:-.}"
  local query_subdir="${4:-queries}"
  local query_lang="${5:-$lang}"
  local repo_dir="$WORK_DIR/$lang"

  echo "Installing $lang"
  git clone --depth=1 "$repo" "$repo_dir" >/dev/null 2>&1
  tree-sitter build --output "$PARSER_DIR/$lang.so" "$repo_dir/$build_subdir" >/dev/null

  if [[ -d "$repo_dir/$query_subdir" ]]; then
    rm -rf "$QUERY_DIR/$query_lang"
    mkdir -p "$QUERY_DIR/$query_lang"
    cp -R "$repo_dir/$query_subdir/." "$QUERY_DIR/$query_lang/"
  fi
}

install_repo "javascript" "https://github.com/tree-sitter/tree-sitter-javascript.git"
patch_native_javascript_queries
install_repo "html" "https://github.com/tree-sitter/tree-sitter-html.git"
install_repo "css" "https://github.com/tree-sitter/tree-sitter-css.git"
install_repo "scss" "https://github.com/serenadeai/tree-sitter-scss.git"
install_repo "svelte" "https://github.com/Himujjal/tree-sitter-svelte.git"
install_repo "yaml" "https://github.com/tree-sitter-grammars/tree-sitter-yaml.git"

TYPESCRIPT_REPO="$WORK_DIR/typescript-repo"
echo "Installing typescript"
git clone --depth=1 https://github.com/tree-sitter/tree-sitter-typescript.git "$TYPESCRIPT_REPO" >/dev/null 2>&1
tree-sitter build --output "$PARSER_DIR/typescript.so" "$TYPESCRIPT_REPO/typescript" >/dev/null
tree-sitter build --output "$PARSER_DIR/tsx.so" "$TYPESCRIPT_REPO/tsx" >/dev/null
for lang in typescript tsx; do
  rm -rf "$QUERY_DIR/$lang"
  mkdir -p "$QUERY_DIR/$lang"
  cp -R "$TYPESCRIPT_REPO/queries/." "$QUERY_DIR/$lang/"
  # TypeScript queries only define TS-specific nodes; JS highlights must be inherited
  if ! grep -q "; inherits: javascript" "$QUERY_DIR/$lang/highlights.scm" 2>/dev/null; then
    { echo "; inherits: javascript"; echo ""; cat "$QUERY_DIR/$lang/highlights.scm"; } > /tmp/ts_hl_patch.scm
    mv /tmp/ts_hl_patch.scm "$QUERY_DIR/$lang/highlights.scm"
  fi
done

echo "Done"
