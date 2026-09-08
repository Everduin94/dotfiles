# 🌑 Dotfiles

- [Neovim](https://github.com/Everduin94/dotfiles/tree/main/all/nvim/.config/nvim)
- [Wezterm](https://github.com/Everduin94/dotfiles/tree/main/all/wezterm/.config/wezterm)
- Ghostty (`all/ghostty/.config/ghostty/config.ghostty`)
- Hunk (`all/hunk/.config/hunk/config.toml`)
- Hex corrections (`mac/hex/.local/share/hex/dictation-processing.json`)
- Zsh + Zap ([mac](https://github.com/Everduin94/dotfiles/tree/main/mac/zsh/.config/zsh), [arch](https://github.com/Everduin94/dotfiles/tree/main/arch/zsh/.config/zsh))
- [Starship](https://github.com/Everduin94/dotfiles/tree/main/all/starship/.config/starship)
- Arch + AwesomeWM `Home`
- MacOS `Work / Mobile`

> [!NOTE]
> This repository is managed by GNU Stow. Install packages from the OS-level folders `all`, `mac`, and `arch`.

## 📦 Installation

Stow only the packages you want.

```sh
# In your $HOME directory
git clone https://github.com/Everduin94/dotfiles.git
brew install stow

cd ~/dotfiles/all
stow -t ~ git nvim starship wezterm ghostty hunk

cd ~/dotfiles/mac
stow -t ~ hex karabiner raycast zsh yabai skhd sketchybar
```

On Linux / Arch, stow from `~/dotfiles/arch` for OS-specific packages.

The curated macOS bootstrap flow lives under `install/`:
- `install/Brewfile.macos-dotfiles`
- `install/AGENT_INSTALL.md`

## ⚙️ Configuration

Some configuration will still be required depending on what you stowed.

- Update `all/git/.gitconfig` with your name / email.
- Update the `projects` file if you use the project picker.
- If you use Raycast, replace `mac/raycast/.config/raycast/config.rayconfig` with your own export before importing it.
- Hex stores corrections inside `~/Library/Application Support/voice-control/settings.json`. Quit Hex, then use `install/hex-save.sh` to update the tracked snapshot or `install/hex-import.sh` to restore it without replacing unrelated settings.

## 🖥️ Start from Zero (Mac)

```sh
# Install Brew
cd ~
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone repo
git clone https://github.com/Everduin94/dotfiles.git
cd ~/dotfiles

# Install stow + curated dependencies
brew install stow
brew bundle --file=install/Brewfile.macos-dotfiles

# Stow desired packages
cd ~/dotfiles/all
stow -t ~ git nvim starship wezterm ghostty hunk

cd ~/dotfiles/mac
stow -t ~ hex karabiner raycast zsh yabai skhd sketchybar

# Authenticate GitHub
gh auth login
gh auth setup-git

# Install shell / tooling
./install/install-node.sh
./install/install-pi-agent.sh
./install/install-npm-globals.sh

# Optional
./install/install-browsers.sh
./install/install-iosevka-font.sh
./install/macos-adjustments.sh
./install/raycast-import.sh
./install/hex-import.sh # after completing Hex setup and quitting Hex
```

**Manual Improvements**
- Increase key repeat: System > Keyboard: Max both settings
- Turn off spotlight shortcuts: System Settings > Spotlight > Shortcuts
- Hide toolbar: System Settings > Desktop & Dock > Automatically hide and show the Dock

**yabai/skhd setup**
- Grant Accessibility access to both `yabai` and `skhd`, then restart both services.
- Create the desired number of macOS Spaces manually.
- In Desktop & Dock: enable separate Spaces per display, disable automatic Space rearrangement, show desktop items, and set wallpaper clicks to reveal the desktop only in Stage Manager.

**SketchyBar setup**
- Start it with `brew services start sketchybar`.
- SketchyBar requires **Displays have separate Spaces**.
- Keep the native menu bar visible until the SketchyBar status items are sufficient.

## 🖥️ Arch Setup

Stow from `all/` and `arch/`.
Install distro-specific dependencies with your package manager as needed.
