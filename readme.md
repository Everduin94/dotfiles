# 👋 Welcome to my Dotfiles

- Neovim
- Wezterm
- Zsh + Zap
- MacOS
- Arch Linux + AwesomeWM

## Installation

These dotfiles are managed by gnu stow. You can install individual modules of these dotfiles, for example `nvim`, based on your needs / OS. This will create a symlink to the module in your `~/.config` or `$HOME` directory, depending on the module.

```sh
# In your $HOME directory
git clone https://github.com/Everduin94/dotfiles.git

# Install stow with your package manager
brew install stow

# Navigate to the folder containing the module you want to install
cd ~/dotfiles/all
stow -t ~ nvim

# 🔄 Rinse and repeat for all desired modules.
```

> [!NOTE]
> This example will clone all of my dotfiles, but will only install the `nvim` module into your `~/.config` directory. Modules will not impact your editor/terminal unless stowed.

## Configuration

Some configuration will be required depending on the modules you installed. For example:

- Updating the `git` module to use your name / email
- Updating the `projects` list to point to your projects.
  - The `p` command from the `zsh` module will open an FZF prompt of those projects.
- The list of dependencies for these dotfiles may be out of date. If something doesn't work, you may just be missing a dependency that needs to be installed via `npm` or your package manager (`brew`, `pacman`, etc...)

## Start from Zero (Mac)

**Install Brew**
`cd ~`
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

**Clone Me**
`git clone https://github.com/Everduin94/dotfiles.git`

**Install Stow**
`brew install stow`

**Run Stow**

- See installation section

Install All Apps\*\*
`brew tap homebrew/cask-fonts`
`xargs brew install < .brew-starter.list`
`xargs brew install --cask < .brew-cask-starter.list`

**Authenticate Github**
`gh auth login`
`gh auth setup-git`

\*Manual Improvements\*\*
Increase key repeat: System > Keyboard: Max both settings
Rebind Caps: Click Modifier Keys in Bottom Right: Set Caps Lock to ESC
Turn off spotlight: System Settings > Spotlight >Shortcuts
Hide toolbar: System Preferences > Docks & Menu > Automatically hide

## Arch Setup (WIP)

This works on Arch minus Raycast and Mac specific things. I don't currently have the pacman & yay lists setup.
