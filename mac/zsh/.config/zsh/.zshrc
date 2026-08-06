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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
command -v nvm >/dev/null 2>&1 && nvm use --silent default >/dev/null 2>&1

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
