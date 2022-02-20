#!/bin/sh
export ZDOTDIR=$HOME/.config/zsh
HISTFILE=~/.zsh_history
setopt appendhistory

# some useful options (man zshoptions)
setopt autocd extendedglob nomatch menucomplete
setopt interactive_comments
stty stop undef		# Disable ctrl-s to freeze terminal.
zle_highlight=('paste:none')

# beeping is annoying
unsetopt BEEP

# Must be before bindkey calls
# Turns off vim-mode and enables emacs mode (default): https://unix.stackexchange.com/questions/197839/why-does-exporting-vim-as-editor-in-zsh-disable-keyboard-shortcuts
bindkey -e 

# completions
autoload -Uz compinit
zstyle ':completion:*' menu select
# zstyle ':completion::complete:lsof:*' menu yes select
zmodload zsh/complist
# compinit
_comp_options+=(globdots)		# Include hidden files.

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Colors
autoload -Uz colors && colors

# Useful Functions
source "$ZDOTDIR/zsh-functions"

# Normal files to source
zsh_add_file "zsh-exports"
# zsh_add_file "zsh-vim-mode"
zsh_add_file "zsh-aliases"
zsh_add_file "zsh-prompt"

# Plugins
zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"
zsh_add_plugin "hlissner/zsh-autopair"
# zsh_add_completion "esc/conda-zsh-completion" false
# For more plugins: https://github.com/unixorn/awesome-zsh-plugins
# More completions https://github.com/zsh-users/zsh-completions

# Key-bindings
bindkey -s '^o' 'ranger^M'
bindkey -s '^f' 'zi^M'
bindkey -s '^s' 'ncdu^M'
# bindkey -s '^n' 'nvim $(fzf)^M'
# bindkey -s '^v' 'nvim\n'
bindkey -s '^z' 'zi^M'
bindkey '^[[P' delete-char
bindkey "^p" up-line-or-beginning-search # Up
bindkey "^n" down-line-or-beginning-search # Down
# bindkey "^j" up-line-or-history # Up
# bindkey "^k" down-line-or-history # Down
bindkey "^j": previous-history
bindkey "^k": next-history
bindkey -M menuselect '^j' up-line-or-beginning-search
bindkey -M menuselect '^k' down-line-or-beginning-search

# Important: Removed \ec binding from fzf shell keybinds
zle     -N    fzf-cd-widget
bindkey 'ç' fzf-cd-widget # Option+ç

# Flipped -- TODO: Dec 14th, disable these in favor of bind above as a test.
# bindkey "^j" up-line-or-beginning-search # Up
# bindkey "^k" down-line-or-beginning-search # Down
bindkey "^L" end-of-line
bindkey -r "^u"
bindkey -r "^d"

# FZF 
# TODO update for mac
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f $ZDOTDIR/completion/_fnm ] && fpath+="$ZDOTDIR/completion/"
# export FZF_DEFAULT_COMMAND='rg --hidden -l ""'
export FZF_DEFAULT_OPTS='--bind=ctrl-j:up,ctrl-k:down'
compinit

# Edit line in vim with ctrl-e:
# TODO: EV Commented out to test
# autoload edit-command-line; zle -N edit-command-line
# bindkey '^e' edit-command-line

# Speedy keys
setxkbmap -option caps:escape

# Environment variables set everywhere
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="chrome"


# For QT Themes
export QT_QPA_PLATFORMTHEME=qt5ct

# remap caps to escape
# setxkbmap -option caps:escape
# swap escape and caps
# setxkbmap -option caps:swapescape



# fnm
export PATH=/home/erik/.local/bin:$PATH
eval "`fnm env`"
