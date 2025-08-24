# 🌑 Dotfiles

- [Neovim](https://github.com/Everduin94/dotfiles/tree/main/all/nvim/.config/nvim)
- [Wezterm](https://github.com/Everduin94/dotfiles/tree/main/all/wezterm/.config/wezterm)
- [Zsh + Zap](https://github.com/Everduin94/dotfiles/tree/main/all/zsh/.config/zsh)
- [Starship](https://github.com/Everduin94/dotfiles/tree/main/all/starship/.config/starship)
- Arch + AwesomeWM `Home`
- MacOS `Work / Mobile`

> [!NOTE]
> This repository is managed by gnu stow. The file structure is based on running stow from the OS level folders `all`, `mac` and `arch`.


## 📦 Installation

You can install individual folders of these dotfiles, for example `nvim`, based on your needs / operating system. - The following example will create a symlink to the `nvim` folder in your `~/.config` directory.

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
> This example will clone the entire dotfiles repository, but will only symlink the `nvim` folder into your `~/.config` directory. Folders will not impact your editor/terminal unless stowed.

> [!WARNING]
> These instructions are high level, and some dependencies may be out of date or missing. It may be better to take inspiration from these dotfiles instead of using them directly.

## ⚙️ Configuration

Some configuration will be required depending on the folders you installed. For example:

- Updating the `.gitconfig` from the `git` folder to use your name / email
- Updating the `projects` file from the `projects` folder to point to your desired paths.
  - The `p` command from the `zsh` folder will open an FZF prompt of those projects.
- The list of dependencies for these dotfiles may be out of date. If something doesn't work, you may just be missing a dependency that needs to be installed via `npm` or your package manager (`brew`, `pacman`, etc...)

## 🖥️ Start from Zero (Mac)

```sh
# Install Brew
cd ~
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone Me
git clone https://github.com/Everduin94/dotfiles.git

# Install Stow
brew install stow

# Run Stow
cd ~/dotfiles/all
stow -t ~ nvim

## 🔄 Rinse and repeat for all desired modules.

# Install All Apps
brew tap homebrew/cask-fonts
xargs brew install < .brew-starter.list
xargs brew install --cask < .brew-cask-starter.list

# Authenticate Github (Optional)
gh auth login
gh auth setup-git
```


**Manual Improvements**
- Increase key repeat: System > Keyboard: Max both settings
- Rebind Caps: Click Modifier Keys in Bottom Right: Set Caps Lock to ESC
- Turn off spotlight: System Settings > Spotlight >Shortcuts
- Hide toolbar: System Preferences > Docks & Menu > Automatically hide

## 🖥️ Arch Setup (WIP)


> [!NOTE]
> The pacman & yay lists of dependencies are missing. But, you can still use the `arch` section for inspiration. Or stow and try to figure out missing dependencies through trial and error.
