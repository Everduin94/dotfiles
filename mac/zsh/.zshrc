export ZDOTDIR=$HOME/.config/zsh
source "$HOME/.config/zsh/.zshrc"

# NVM is lazy-loaded in $ZDOTDIR/.zshrc; do not source it again here.

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export FPATH="$HOME/completions/zsh:$FPATH"
export FPATH="$HOME/eza/completions/zsh:$FPATH"

if [ -f "$HOME/.pi/certs/cisco-secure-access-root.pem" ]; then
  export NODE_EXTRA_CA_CERTS="$HOME/.pi/certs/cisco-secure-access-root.pem"
else
  unset NODE_EXTRA_CA_CERTS
fi

# Pi voice input extension
# Auto-select Shure first, then fall back to the MacBook Pro microphone.
export PI_VOICE_AUDIO_INPUT="auto"
export PI_VOICE_PYTHON="$HOME/.venvs/pi-voice/bin/python"
export PI_VOICE_MODEL="base"
export PI_VOICE_DEVICE="cpu"
export PI_VOICE_COMPUTE_TYPE="int8"
export PI_VOICE_LANGUAGE="en"

alias download-avf="$HOME/.pi/agent/paladin/projects/avf/scripts/core/download-avf-openapi.sh"
alias search-avf="$HOME/.pi/agent/paladin/projects/avf/scripts/core/search-avf-openapi.sh"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit
(( ${+_comps[docker]} )) || compinit
# End of Docker CLI completions
