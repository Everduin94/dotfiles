export ZDOTDIR=$HOME/.config/zsh
source "$HOME/.config/zsh/.zshrc"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
command -v nvm >/dev/null 2>&1 && nvm use --silent default >/dev/null 2>&1

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export FPATH="$HOME/completions/zsh:$FPATH"
export FPATH="$HOME/eza/completions/zsh:$FPATH"

export NODE_EXTRA_CA_CERTS="$HOME/.pi/certs/cisco-secure-access-root.pem"

# Pi voice input extension
# Auto-select Shure first, then fall back to the MacBook Pro microphone.
export PI_VOICE_AUDIO_INPUT="auto"
export PI_VOICE_PYTHON="$HOME/.venvs/pi-voice/bin/python"
export PI_VOICE_MODEL="base"
export PI_VOICE_DEVICE="cpu"
export PI_VOICE_COMPUTE_TYPE="int8"
export PI_VOICE_LANGUAGE="en"

alias download-avf="$HOME/.pi/scripts/download-avf-openapi.sh"
alias search-avf="$HOME/.pi/scripts/search-avf-openapi.sh"
