# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zsh-users/zsh-syntax-highlighting"

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
plug "wintermi/zsh-starship"
# plug "zap-zsh/zap-prompt"
# plug "MAHcodes/distro-prompt"

plug "$HOME/.config/zsh/zsh-aliases"
plug "$HOME/.config/zsh/zsh-exports"
plug "$HOME/.config/zsh/zsh-functions"

# Keybindings
# Force emacs mode even when EDITOR/VISUAL is nvim.
bindkey -e
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey '^F' end-of-line
bindkey '^P' up-line-or-beginning-search

# Load and initialise completion system
autoload -Uz compinit
compinit

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# pnpm
for pnpm_home_candidate in "$HOME/Library/pnpm" "$HOME/.local/share/pnpm"; do
  if [ -d "$pnpm_home_candidate" ]; then
    export PNPM_HOME="$pnpm_home_candidate"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
    break
  fi
done
unset pnpm_home_candidate
# pnpm end

# NVM (lazy-loaded): don't source nvm.sh or run `nvm use` on every shell.
# Real nvm/node/npm/npx/corepack load on first use. A project pin
# (.nvmrc/.node-version) wins over the `default` alias.
export NVM_DIR="$HOME/.nvm"

# Cheaply put the default nvm node version's bin dir on PATH without
# sourcing nvm.sh, so subprocesses/shebangs (e.g. `#!/usr/bin/env node`)
# resolve the right node even before any nvm/node/npm command is typed.
__nvm_default_version() {
  local target=""
  [ -f "$NVM_DIR/alias/default" ] && target=$(<"$NVM_DIR/alias/default")
  local seen=0
  while [ -n "$target" ] && [ -f "$NVM_DIR/alias/$target" ] && [ "$seen" -lt 5 ]; do
    target=$(<"$NVM_DIR/alias/$target")
    seen=$((seen + 1))
  done
  target="${target#v}"
  if [ -z "$target" ] || [ ! -d "$NVM_DIR/versions/node/v$target" ]; then
    target=$(command ls -1 "$NVM_DIR/versions/node" 2>/dev/null | sed 's/^v//' | sort -V | tail -1)
  fi
  echo "$target"
}
__nvm_default_bin="$NVM_DIR/versions/node/v$(__nvm_default_version)/bin"
[ -d "$__nvm_default_bin" ] && PATH="$__nvm_default_bin:$PATH"
unset __nvm_default_bin

__nvm_loaded=0
__nvm_lazy_load() {
  [ "$__nvm_loaded" = 1 ] && return 0
  __nvm_loaded=1
  unset -f nvm node npm npx corepack 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

__nvm_activate() {
  __nvm_lazy_load
  command -v nvm >/dev/null 2>&1 || return 0
  nvm use --silent >/dev/null 2>&1 || nvm use --silent default >/dev/null 2>&1
}

nvm() { __nvm_activate; nvm "$@"; }
node() { __nvm_activate; node "$@"; }
npm() { __nvm_activate; npm "$@"; }
npx() { __nvm_activate; npx "$@"; }
corepack() { __nvm_activate; corepack "$@"; }

# Auto-switch to a project's pinned Node version when cd-ing into a
# directory with .nvmrc/.node-version, without loading nvm elsewhere.
__nvm_dir_has_pin() {
  local dir="$PWD"
  while :; do
    [ -f "$dir/.nvmrc" ] && return 0
    [ -f "$dir/.node-version" ] && return 0
    [ "$dir" = "/" ] && return 1
    dir="${dir:h}"
  done
}
__nvm_chpwd() { __nvm_dir_has_pin && __nvm_activate; }
autoload -Uz add-zsh-hook
add-zsh-hook chpwd __nvm_chpwd
__nvm_chpwd  # handle the case where the shell starts inside a pinned repo

# zoxide
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

pi() {
  EDITOR='env PI_NVIM_INLINE=1 nvim' VISUAL='env PI_NVIM_INLINE=1 nvim' command pi "$@"
}

. "$HOME/.turso/env"

# Dark factory: create the task input and validation specification templates.
# Fill in prompt.md, then run create-task on it. The specification phase fills
# in validation-spec.md.
function create-task-template() {
  mkdir -p ./tmp
  cp "$HOME/.pi/turso-poller-tui/templates/task-template.md" ./tmp/prompt.md
  cp "$HOME/.pi/turso-poller-tui/templates/validation-specification-template.md" ./tmp/validation-spec.md
  echo "Created ./tmp/prompt.md and ./tmp/validation-spec.md"
  nvim ./tmp/prompt.md
}
alias ctt=create-task-template

# Dark factory: create a task row from ./tmp/prompt.md (or an override path
# passed as $1).
function create-task() {
  bun "$HOME/.pi/turso-poller-tui/scripts/create-task.ts" "$@"
}
alias ct=create-task
