# Dotfiles

*Managed with GNU Stow*
- `stow */` to symlink all folders into `.config` and `$HOME`

### Stack
- Alacritty
- Neovim
- Tmux
- Zsh

**Additional Features**
- Ranger
- Fzf
- Git
- No OMZ
- NerdFonts Enabled

### Programs
 - `xargs brew install < programs/.brew.list`
 - `xargs brew install --cask < programs/.brew-cask.list`
 - `programs/.npm.list` -- No installation setup (yet).
 - `:PlugInstall` -- nvim utilizing Vim-Plug
  - Some themes I hard-editted. May need to adjust
  based on comments in files like nord.vim
 - `Prefix+I` -- Install tmux plugins

### Scripts
- Moved from fish to zsh. Need to convert.

### TODO
- Include alfred (brew cask if possible)
- Install bottom (or a similar program)
- vc nerdfont config / move nerd fonts to dotfiles
- install script (you could do this manually just by following instructions in "Programs")

