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
export PATH=$PATH:$HOME/.spicetify

# make CapsLock behave like Ctrl:
setxkbmap -option ctrl:nocaps

# make short-pressed Ctrl behave like Escape:
xcape -e 'Control_L=Escape'

# Sane key repeat
xset r rate 210 40

# Swap mode with alt on Mode Loop keyboard
setxkbmap -option altwin:swap_lalt_lwin

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
eval "$(zoxide init zsh)"
