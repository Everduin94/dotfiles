# Reproducible yabai setup

This guide describes how to add an i3/AwesomeWM-style yabai workflow to the Stow-managed dotfiles repository at `~/dotfiles`.

It is written for both:

- a person installing the setup on a Mac
- an agent implementing or troubleshooting the setup

## Desired behavior

Terminology:

- **Display**: a physical monitor
- **Space**: a macOS virtual desktop/workspace
- **Window**: an application window within a Space

The intended workflow is:

- `⌘ H/J/K/L`: focus the window west/south/north/east
- `⇧⌘ H/J/K/L`: move/reinsert the window west/south/north/east
- `⌘ 1–9`: switch to Space 1–9
- `⇧⌘ 1–9`: move the current window to Space 1–9 and follow it
- New windows automatically tile and consume available space
- Closing a tiled window causes the remaining windows to reclaim its space
- Keep System Integrity Protection (SIP) enabled

Overriding the native `⌘ H` “Hide application” behavior is intentional.

## Important decisions

1. Use [yabai](https://github.com/asmvik/yabai) for BSP tiling and window/Space commands.
2. Use [skhd](https://github.com/asmvik/skhd) for global keyboard shortcuts.
3. Install both from `asmvik/formulae` with Homebrew.
4. Keep SIP enabled and do **not** install yabai's scripting addition.
5. Store configs under `~/dotfiles/mac` and link them with GNU Stow.
6. Use macOS Spaces as workspaces. Create the desired Spaces manually once per machine.

Keeping SIP enabled still supports the core workflow: tiling, focus, swap/warp, float, zoom, display movement, focusing Spaces, and moving individual windows between Spaces.

The scripting addition is only needed for advanced operations such as creating/destroying/reordering entire Spaces, opacity, sticky windows, scratchpads, and window-server effects. It is deliberately out of scope.

## Current environment context

When this guide was written:

- Machine: Apple Silicon (`arm64`)
- macOS: 26.6.2
- Homebrew: `/opt/homebrew/bin/brew`
- SIP: enabled
- Ghostty: installed
- Raycast: installed
- `jq`: available
- yabai/skhd: not yet installed
- Dotfiles: `~/dotfiles`
- Dotfiles branch: `main`
- Dotfiles already contained unrelated uncommitted changes

An agent must run `git -C ~/dotfiles status --short` before editing and must not reset, discard, stage, or overwrite unrelated changes.

## Intended dotfiles structure

Create two macOS-only Stow packages:

```text
~/dotfiles/
├── mac/
│   ├── yabai/
│   │   └── .config/
│   │       └── yabai/
│   │           └── yabairc
│   └── skhd/
│       └── .config/
│           └── skhd/
│               └── skhdrc
└── install/
    ├── Brewfile.macos-dotfiles
    └── macos-adjustments.sh
```

After Stow runs, these resolve as:

```text
~/.config/yabai/yabairc -> ~/dotfiles/mac/yabai/.config/yabai/yabairc
~/.config/skhd/skhdrc   -> ~/dotfiles/mac/skhd/.config/skhd/skhdrc
```

## Implementation plan for an agent

1. Inspect `~/dotfiles/README.md`, the Brewfile, `macos-adjustments.sh`, and Git status.
2. Create the two Stow packages without touching unrelated files.
3. Add the custom Homebrew tap and formulae to the Brewfile.
4. Update the dotfiles README with the new Stow packages and manual permission steps.
5. Optionally add only well-understood Mission Control defaults to `macos-adjustments.sh`.
6. Dry-run Stow before linking anything.
7. Install with Homebrew only after the user confirms installation should proceed.
8. Start services, then ask the user to grant macOS Accessibility permissions.
9. Restart services and validate commands/hotkeys.
10. Report all changed files and any remaining manual actions.

Do not partially disable SIP, create sudoers entries, install a scripting addition, or install from yabai HEAD for this setup.

## 1. Add Homebrew dependencies

Edit:

```text
~/dotfiles/install/Brewfile.macos-dotfiles
```

Add:

```ruby
# Window management
tap "asmvik/formulae"
brew "asmvik/formulae/yabai"
brew "asmvik/formulae/skhd"
```

Install everything in the curated Brewfile with:

```sh
brew bundle --file=~/dotfiles/install/Brewfile.macos-dotfiles
```

Or install only the window manager dependencies with:

```sh
brew install asmvik/formulae/yabai
brew install asmvik/formulae/skhd
```

Use release builds. On macOS 26.6, the unreleased yabai fix only affects the optional scripting addition's create-Space operation, which this setup does not use.

## 2. Create the yabai configuration

Create:

```text
~/dotfiles/mac/yabai/.config/yabai/yabairc
```

Recommended contents:

```sh
#!/usr/bin/env sh

# Automatic binary-space-partitioning layout.
yabai -m config layout                       bsp
yabai -m config split_type                   auto
yabai -m config split_ratio                  0.50
yabai -m config auto_balance                 off
yabai -m config window_placement             second_child
yabai -m config window_insertion_point       focused
yabai -m config window_zoom_persist          on

# Small gaps while preserving most of the display area.
yabai -m config top_padding                  10
yabai -m config bottom_padding               10
yabai -m config left_padding                 10
yabai -m config right_padding                10
yabai -m config window_gap                   8

# Immediate layout changes. Nonzero animation requires Screen Recording.
yabai -m config window_animation_duration    0.0

# This is intended for the SIP-enabled/no-scripting-addition path.
yabai -m config skip_window_focus_animation  on

# Conservative defaults. `autofocus` can be tried later.
yabai -m config focus_follows_mouse          off
yabai -m config mouse_follows_focus          off

# Command + mouse drag anywhere in a window.
yabai -m config mouse_modifier               cmd
yabai -m config mouse_action1                move
yabai -m config mouse_action2                resize
yabai -m config mouse_drop_action            swap

# Utility applications generally work better floating.
yabai -m rule --add app="^(System Settings|Calculator)$" manage=off

echo "yabai configuration loaded"
```

Make it executable:

```sh
chmod +x ~/dotfiles/mac/yabai/.config/yabai/yabairc
```

### Layout behavior

`layout bsp` causes windows to tile automatically:

- First window fills the usable area.
- Second window splits that area.
- Additional windows recursively split the focused region.
- Closing a window expands neighboring windows into the released area.
- `auto_balance off` preserves manually adjusted split ratios.

To force equal areas whenever windows open or close, change:

```sh
yabai -m config auto_balance on
```

## 3. Create the skhd configuration

Create:

```text
~/dotfiles/mac/skhd/.config/skhd/skhdrc
```

Recommended contents:

```sh
# -----------------------------------------------------------------------------
# Window focus: west / south / north / east
# This intentionally replaces the native Command+H “Hide application” shortcut.
# -----------------------------------------------------------------------------
cmd - h : yabai -m window --focus west
cmd - j : yabai -m window --focus south
cmd - k : yabai -m window --focus north
cmd - l : yabai -m window --focus east

# Move/reinsert a managed window in the BSP tree.
shift + cmd - h : yabai -m window --warp west
shift + cmd - j : yabai -m window --warp south
shift + cmd - k : yabai -m window --warp north
shift + cmd - l : yabai -m window --warp east

# -----------------------------------------------------------------------------
# Spaces/workspaces
# -----------------------------------------------------------------------------
cmd - 1 : yabai -m space --focus 1
cmd - 2 : yabai -m space --focus 2
cmd - 3 : yabai -m space --focus 3
cmd - 4 : yabai -m space --focus 4
cmd - 5 : yabai -m space --focus 5
cmd - 6 : yabai -m space --focus 6
cmd - 7 : yabai -m space --focus 7
cmd - 8 : yabai -m space --focus 8
cmd - 9 : yabai -m space --focus 9

# Move a window to a Space and follow it. This works with SIP enabled.
shift + cmd - 1 : yabai -m window --space 1 --focus
shift + cmd - 2 : yabai -m window --space 2 --focus
shift + cmd - 3 : yabai -m window --space 3 --focus
shift + cmd - 4 : yabai -m window --space 4 --focus
shift + cmd - 5 : yabai -m window --space 5 --focus
shift + cmd - 6 : yabai -m window --space 6 --focus
shift + cmd - 7 : yabai -m window --space 7 --focus
shift + cmd - 8 : yabai -m window --space 8 --focus
shift + cmd - 9 : yabai -m window --space 9 --focus

# Toggle back to the previously focused Space.
cmd - 0 : yabai -m space --focus recent

# -----------------------------------------------------------------------------
# Secondary window-management actions
# These use Control+Command to avoid replacing common application shortcuts.
# -----------------------------------------------------------------------------
ctrl + cmd - f     : yabai -m window --toggle zoom-fullscreen
ctrl + cmd - space : yabai -m window --toggle float --grid 4:4:1:1:2:2
ctrl + cmd - b     : yabai -m space --balance
ctrl + cmd - e     : yabai -m window --toggle split

# Physical displays. Useful only when multiple monitors are connected.
ctrl + cmd - h : yabai -m display --focus west
ctrl + cmd - l : yabai -m display --focus east

# Move the current window to another physical display and follow it.
shift + ctrl + cmd - h : yabai -m window --display west; yabai -m display --focus west
shift + ctrl + cmd - l : yabai -m window --display east; yabai -m display --focus east

# Optional i3-style launcher. Uncomment if desired.
# cmd - return : open -na /Applications/Ghostty.app
```

### Hotkey tradeoffs

skhd consumes these combinations globally. Therefore:

- `⌘ H` no longer hides applications—intentional.
- `⌘ J/K/L` no longer reach applications.
- `⌘ 1–9` no longer select browser/editor tabs.
- Application exceptions can be added later using skhd's per-application syntax.
- Secure Keyboard Entry prevents skhd from receiving keys. If all bindings suddenly stop working, check whether a terminal or password field enabled it.

## 4. Update the dotfiles README

In `~/dotfiles/README.md`, add yabai/skhd to the macOS Stow command:

```sh
cd ~/dotfiles/mac
stow -t ~ karabiner raycast zsh yabai skhd
```

Document these remaining manual steps:

1. Grant Accessibility access to yabai and skhd.
2. Create the desired number of macOS Spaces.
3. Confirm the required Desktop & Dock settings.
4. Restart both services after granting permissions.

## 5. Configure macOS

Open **System Settings → Desktop & Dock**.

Required/recommended settings:

- Mission Control → **Displays have separate Spaces: On**
- Mission Control → **Automatically rearrange Spaces based on most recent use: Off**
- Desktop & Stage Manager → **Show Items On Desktop: On**
- Desktop & Stage Manager → **Click wallpaper to reveal Desktop: Only in Stage Manager**

The last two settings improve display and Space focus reliability on recent macOS versions.

Do not disable Finder's desktop with `CreateDesktop = false`; yabai uses the Finder desktop window when focusing empty Spaces.

### Optional automation

The safe Mission Control setting can be added to `~/dotfiles/install/macos-adjustments.sh`:

```sh
defaults write com.apple.dock mru-spaces -bool false
```

The other settings can change implementation details between macOS releases. Prefer documenting and setting them through System Settings unless their current defaults keys have been verified on the target macOS version.

## 6. Create Spaces

With SIP enabled, this setup intentionally does not automate Space creation.

On each new Mac:

1. Open Mission Control.
2. Use the `+` button to create at least five Spaces, or up to nine if all configured bindings are wanted.
3. Keep their order stable by disabling automatic rearrangement.

`⌘ 1` means yabai Space index 1, `⌘ 2` means index 2, and so on. With multiple physical displays, macOS maintains Spaces across displays and Mission Control indices are global; verify the resulting order once after arranging the displays.

Bindings for missing Space numbers simply fail without changing anything.

## 7. Dry-run and apply Stow

Before linking, inspect for conflicts:

```sh
cd ~/dotfiles/mac
stow --no --verbose=2 --target="$HOME" yabai skhd
```

If the dry run is clean:

```sh
stow --target="$HOME" yabai skhd
```

Verify:

```sh
ls -l ~/.config/yabai/yabairc
ls -l ~/.config/skhd/skhdrc
```

Do not replace existing real config files without first reviewing and preserving them.

## 8. Start services and grant permissions

Start both launchd services:

```sh
yabai --start-service
skhd --start-service
```

Then open:

**System Settings → Privacy & Security → Accessibility**

Enable both `yabai` and `skhd`. macOS may add them automatically after first launch; otherwise use the `+` button.

After permissions are granted, restart both services:

```sh
yabai --restart-service
skhd --restart-service
```

If macOS separately requests Input Monitoring for skhd, grant it and restart skhd.

Screen Recording is not needed because window animations are configured to `0.0`.

## 9. Validate

### Services and configuration

```sh
yabai --version
skhd --version

yabai -m config layout
yabai -m query --spaces | jq
yabai -m query --windows | jq
```

Expected layout output:

```text
bsp
```

### Manual behavior test

1. Open Ghostty. It should fill the available area.
2. Open another window. Both should tile automatically.
3. Open a third window. The focused region should split.
4. Press `⌘ H/J/K/L`; focus should move directionally.
5. Press `⇧⌘ H/J/K/L`; the focused window should move within the tree.
6. Press `⌘ 1–5`; the corresponding Spaces should activate.
7. Press `⇧⌘ 1–5`; the focused window should move to that Space and follow focus.
8. Close a tiled window; remaining windows should reclaim the area.
9. Press `⌃⌘ F`; the current tile should zoom/unzoom.
10. Press `⌃⌘ Space`; the window should float/unfloat and center.

### Hotkey debugging

Observe keys received by skhd:

```sh
skhd -o
```

Press `Ctrl+C` to exit observer mode.

### Logs

```sh
tail -f /tmp/yabai_$USER.err.log
tail -f /tmp/yabai_$USER.out.log
tail -f /tmp/skhd_$USER.err.log
tail -f /tmp/skhd_$USER.out.log
```

Enable detailed yabai output temporarily:

```sh
yabai -m config debug_output on
yabai --restart-service
```

Disable it after troubleshooting:

```sh
yabai -m config debug_output off
yabai --restart-service
```

## Everyday configuration workflow

After editing yabai config:

```sh
yabai --restart-service
```

skhd normally hotloads edits. Force a reload with:

```sh
skhd -r
```

Most yabai settings can be tested live before changing dotfiles:

```sh
yabai -m config focus_follows_mouse autofocus
yabai -m config focus_follows_mouse off
```

## Installing on another Mac

```sh
# 1. Clone and install dependencies
git clone https://github.com/Everduin94/dotfiles.git ~/dotfiles
brew install stow
brew bundle --file=~/dotfiles/install/Brewfile.macos-dotfiles

# 2. Stow the configs
cd ~/dotfiles/mac
stow --target="$HOME" yabai skhd

# 3. Apply general macOS adjustments if desired
~/dotfiles/install/macos-adjustments.sh

# 4. Start services
yabai --start-service
skhd --start-service

# 5. Manually grant Accessibility permission to both
# 6. Manually create Spaces and verify Desktop & Dock settings

# 7. Restart after permissions
yabai --restart-service
skhd --restart-service
```

This reproduces configuration and dependencies. macOS privacy approvals and Space creation remain intentionally per-machine.

## Updating

Update formulae:

```sh
yabai --stop-service
yabai --uninstall-service
brew upgrade yabai
yabai --start-service

brew upgrade skhd
skhd --restart-service
```

Recheck Accessibility permission if an updated binary stops responding.

Because this setup does not use the scripting addition, there is no sudoers hash, SIP change, or scripting-addition reload to maintain.

## Uninstalling

Stop services and remove their launch agents:

```sh
skhd --stop-service
skhd --uninstall-service

yabai --stop-service
yabai --uninstall-service
```

Remove Stow links:

```sh
cd ~/dotfiles/mac
stow --delete --target="$HOME" skhd yabai
```

Uninstall packages:

```sh
brew uninstall skhd yabai
```

The tracked configs remain in `~/dotfiles` unless deliberately deleted.

## Troubleshooting notes for an agent

- First inspect `git -C ~/dotfiles status --short`; preserve unrelated work.
- Confirm the symlink targets before editing `~/.config` directly.
- Confirm `csrutil status` remains enabled. Do not suggest weakening SIP for the documented core workflow.
- Confirm both processes exist and commands can reach yabai:

  ```sh
  pgrep -fl 'yabai|skhd'
  yabai -m query --spaces
  ```

- If yabai commands fail, check Accessibility permission and `/tmp/yabai_$USER.err.log`.
- If commands work in a terminal but hotkeys do not, check skhd's Accessibility permission, Secure Keyboard Entry, `skhd -o`, and the skhd error log.
- If focus works but windows do not tile, verify `yabai -m config layout` returns `bsp` and check whether an app-specific rule floated the window.
- If a window cannot be controlled after startup, visit its Space once; yabai may not yet have an Accessibility reference for a window opened on an inactive Space.
- If Space numbers change, ensure automatic Space rearrangement is off and inspect `yabai -m query --spaces | jq`.
- Some dialogs and utility windows cannot resize and should remain floating.
- Native macOS fullscreen creates a special Space. Prefer yabai's `zoom-fullscreen` for an i3-like maximize action.
- Do not add scripting-addition startup commands such as `sudo yabai --load-sa` to this configuration.

## Source material

- [yabai wiki](https://github.com/asmvik/yabai/wiki)
- [yabai installation](https://github.com/asmvik/yabai/wiki/Installing-yabai-(latest-release))
- [yabai configuration](https://github.com/asmvik/yabai/wiki/Configuration)
- [yabai commands](https://github.com/asmvik/yabai/wiki/Commands)
- [yabai manual](https://github.com/asmvik/yabai/blob/master/doc/yabai.asciidoc)
- [yabai examples](https://github.com/asmvik/yabai/tree/master/examples)
- [skhd repository and configuration](https://github.com/asmvik/skhd)
