# Stack
- Alacritty
- Neovim
- Tmux
- Zsh (no ohmyzsh)
- Raycast
- Lua scripts (in place of Bash) 

Font: `Nerdfont Hack`

## Some Interesting Things

*The following may not be useful for your workflow but may inspire your own ideas*

### Alacritty & TMUX

My entire development workflow works out of Alacritty, which is just a terminal emulator.

Tmux is a terminal multiplexer. A fancy way of saying "opens multiple terminals"

I run scripts (see lua-scripts) to open Tmux in a specific state based on work or home
- Opens: config folder, notes folder, project (specific to work/home), and a terminal reserved for servers

### Stow
The project is manged by stow. -- The file structure may seem weird that's because:

The first folder is just a namespace for the user to know what's there.

So `tmux/.config/tmux`

Will create symlinks of a folder structure in `~/.config/tmux`
- i.e. the first folder is ignored.

So `tmux/.tmux-conf`

Will create a symlink `~/.tmux-conf`

Run `stow */` to link all folders/files into `~` ($HOME)

### Raycast

It's an alternative to `Spotlight` or `Alfred`

My hotkey is (CMD+SPACE). Open any application, resize windows, paste snippets.
- I primarily use this to open alacrity/chrome and navigate to specific hard to remember company URLs
  - e.g. my team's jira board

### Lua Scripts
A project I created to simplify writing bash like scripts in lua.

Huge caveat, these run in a child thread, not your current thread.

So imagine you want to export a bash variable. The variable gets set in the child, not the current shell.
- So you could export an artifact or auth token, use that token in the current process, but once it ends that token won't be availabe like you'd imagine

The upside is that control blocks, string manipulation, using tables, etc... is all very easy compared to bash.
- The commands are then piped to the shell, or to tmux.

See files like `css-utils`, scripts to rewrite/refactor files can be done just by chaining luagrep and string manipulation.

### Projects
- `p` is a utility for jumping into projects fast
- `pn` is a utility for jumping into neovim fast

`p` will open an FZF prompt of all of my projects.
- Select a project to navigate to that selection

Composable, type `pn` to open a prompt that will open that folder in neovim
- Hypothetically you could do the same with VS Code

### Neovim
During development one of the biggest speed gains I get (aside from vim motions and plugins like sneak) is through two plugins
- Harpoon (Setting marks in files and opening terminals inside neovim)
- Quick Switcher (My own plugin, allows switching based on prefix / alternatve files)

I can set a mark in a file such as ticket.component.ts
- Now via switcher I can jump to ticket.component.ts|ticket.component.scss|ticket.component.spec.ts|ticket.model.ts|ticket.effects.ts|etc...

Setup marks for 2-4 files at a time and you can quickly navigate between 12+ files quickly with relatively few keybinds

Additionally, I can run tests/servers in neovim. Then when there's an issue or failure I can use `gf` to, go to file, straight from the terminal


### Zsh

The zsh config, taken from chris@machine, does completion and suggestions without installing ohmyzsh
- i.e. it's less bloat.

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

## Optional Setup

**Install Lua Deps (for Lua-Scripts [custom scripts])**
`luarocks install luaposix`

**Install Lua Language Server (for Lua LSP in Neovim)** 
```
cd .config/nvim
git clone https://github.com/sumneko/lua-language-server
cd lua-language-server
git submodule update --init --recursive
cd 3rd/luamake
ninja -f compile/ninja/macos.ninja
cd ../..
./3rd/luamake/luamake rebuild
```

*Caveat: This doesn't resolve to same path for me anymore. May have to adjust in lua-ls.lua*

**Setup project functionality**
- `p` is a utility for jumping into projects fast
- `pn` is a utility for jumping into neovim fast

*See `projects` for examples. bash variables resolve to their path, are piped to fzf, the selection is piped to cd*

**Setup Language Servers**
 `npm install -g @angular/language-server`
 `npm i @angular/cli`
 `npm install -g typescript typescript-language-server`
 `npm i -g vscode-langservers-extracted`

**Install Tmux Plugins**

*caveat I don't know that I really use resurrect anymore, I just run my script*

While in tmux `Prefix+I`. Prefix is (CTRL+B) 


# Arch Setup (WIP)

This works on Arch minus Raycast and Mac specific things

I don't currently have the pacman & yay lists setup.

Caveats:
- Have to adjust alacritty decoration to `none`
- Lua LS install script needs to be adjusted for linux
