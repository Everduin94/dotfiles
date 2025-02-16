# Stack
- Wezterm
- Neovim
- Arch / MacOS (work)
- Zsh (Zap Plugin Manager)
- Raycast (MacOS)

## Some Interesting Things

*The following may not be useful for your workflow but may inspire your own ideas*

### Stow
The project is manged by stow. -- The file structure may seem weird that's because:

The first folder is just a namespace for the user to know what's there.

So `tmux/.config/tmux` will create symlinks of a folder structure in `~/.config/tmux`
- i.e. the first folder is ignored.

So `tmux/.tmux-conf` will create a symlink `~/.tmux-conf`

Run `stow */` to link all folders/files into `~` ($HOME)

### Raycast (MacOS) (Work)

It's an alternative to `Spotlight` or `Alfred`

My hotkey is (CMD+SPACE). Open any application, resize windows, paste snippets.
- I primarily use this to open alacrity/chrome and navigate to specific hard to remember company URLs
  - e.g. my team's jira board

### Projects
- `p` is a utility for jumping into projects fast
- `pn` is a utility for jumping into neovim fast

`p` will open an FZF prompt of all of my projects.
- Select a project to navigate to that selection

Composable, type `pn` to open a prompt that will open that folder in neovim
- Hypothetically you could do the same with VS Code

# Start from Zero (Mac)

**Install Brew**
`cd ~`
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

**Clone Me**
`git clone https://github.com/Everduin94/dotfiles.git`

**Install Stow**
`brew install stow`

**Run Stow**
`cd dotfiles`
`stow */`

*Dotfiles should now be avilable in ~/.config*

**Install All Apps**
`brew tap homebrew/cask-fonts`
`xargs brew install < .brew-starter.list`
`xargs brew install --cask < .brew-cask-starter.list`

**Authenticate Github**
`gh auth login`
`gh auth setup-git`

**Setup Raycast**

*Not sure how to automate this*

There should be a file ending in `.raycast` in your home (~), open Raycast Preferences and import that file.

**Manual Improvements**
- Increase key repeat: System > Keyboard: Max both settings
- Rebind Caps: Click Modifier Keys in Bottom Right: Set Caps Lock to ESC
- Turn off spotlight: System Settings > Spotlight >Shortcuts
- Hide toolbar: System Preferences > Docks & Menu > Automatically hide

# Arch Setup (WIP)

This works on Arch minus Raycast and Mac specific things. I don't currently have the pacman & yay lists setup.

