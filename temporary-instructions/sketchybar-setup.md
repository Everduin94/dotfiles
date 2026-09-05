# Reproducible SketchyBar setup

This guide describes how to add a small, event-driven SketchyBar to the Stow-managed dotfiles repository at `~/dotfiles`.

It is designed to complement the SIP-enabled yabai/skhd setup documented in `~/yabai-setup.md`.

## Desired behavior

- Show the available macOS/yabai Spaces on every display.
- Highlight the active Space.
- Click a Space number to focus it through yabai.
- Show the focused application and a clock.
- Keep the configuration small, readable, and Stow-managed.
- Keep System Integrity Protection (SIP) enabled.
- Avoid Screen Recording permission unless native menu-bar aliases are added later.

SketchyBar is a status-bar replacement, not a window manager. yabai remains responsible for tiling, focus, and Space commands.

## Important decisions

1. Install SketchyBar from the author's Homebrew tap: `FelixKratz/formulae`.
2. Use SketchyBar's native `space` components for Mission Control Spaces.
3. Use `yabai -m space --focus` for clickable Space indicators.
4. Discover current Space indices from yabai when the bar configuration loads.
5. Use standard macOS fonts and plain text, avoiding a required Nerd Font.
6. Store the configuration under `~/dotfiles/mac/sketchybar` and link it with GNU Stow.
7. Start SketchyBar with `brew services`.
8. Keep the initial bar intentionally minimal; add battery, volume, Wi-Fi, and native menu-bar aliases later if wanted.

## Prerequisites

- yabai is installed, configured, and running.
- `jq` is installed.
- GNU Stow is installed.
- **Displays have separate Spaces** is enabled. The SketchyBar documentation says this is required and is the macOS default.

Apple places that setting under:

**System Settings → Desktop & Dock → Mission Control → Displays have separate Spaces**

It may appear near the bottom of the Desktop & Dock page. Use System Settings search if it is difficult to locate. Changing it may require logging out and back in.

## Current environment context

When this guide was written:

- Machine: Apple Silicon (`arm64`)
- macOS: 26.6.2
- Homebrew: `/opt/homebrew/bin/brew`
- SIP: enabled
- yabai: installed and running
- skhd: installed and running
- Dotfiles: `~/dotfiles`
- Dotfiles contained unrelated uncommitted changes
- SketchyBar: not yet installed

An agent must run `git -C ~/dotfiles status --short` before editing and must not reset, discard, stage, or overwrite unrelated changes.

## Intended dotfiles structure

Create one macOS-only Stow package:

```text
~/dotfiles/
├── mac/
│   └── sketchybar/
│       └── .config/
│           └── sketchybar/
│               ├── sketchybarrc
│               └── plugins/
│                   ├── clock.sh
│                   ├── front_app.sh
│                   └── space.sh
└── install/
    └── Brewfile.macos-dotfiles
```

After Stow runs:

```text
~/.config/sketchybar -> ~/dotfiles/mac/sketchybar/.config/sketchybar
```

## Implementation plan for an agent

1. Inspect Git status, the dotfiles README, Brewfile, and existing SketchyBar paths.
2. Create the Stow package without touching unrelated files.
3. Add the tap and SketchyBar formula to the Brewfile.
4. Update the dotfiles README with the Stow package and service instructions.
5. Validate all shell scripts.
6. Dry-run Stow before linking anything.
7. Install through Homebrew only after the user confirms.
8. Start SketchyBar and validate Space components.
9. Ask the user to inspect the appearance and choose whether to hide the native macOS menu bar.
10. Report changed files and remaining optional work.

Do not copy an unreviewed third-party dotfiles setup wholesale. SketchyBar configurations and plugins are executable shell code.

## 1. Add the Homebrew dependency

Edit:

```text
~/dotfiles/install/Brewfile.macos-dotfiles
```

Add:

```ruby
# Status bar
tap "FelixKratz/formulae"
brew "FelixKratz/formulae/sketchybar"
```

Install only SketchyBar with:

```sh
brew tap FelixKratz/formulae
brew install sketchybar
```

Or install the curated Brewfile with:

```sh
brew bundle --file=~/dotfiles/install/Brewfile.macos-dotfiles
```

The custom configuration below uses plain numerals and the macOS system font, so `font-hack-nerd-font` is not required. Install a Nerd Font later only if icon glyphs are added.

## 2. Create the SketchyBar configuration

Create:

```text
~/dotfiles/mac/sketchybar/.config/sketchybar/sketchybarrc
```

Recommended contents:

```bash
#!/usr/bin/env bash

PLUGIN_DIR="$CONFIG_DIR/plugins"

# Colors use 0xAARRGGBB.
BAR_COLOR=0xe622252b
TEXT_COLOR=0xffc8ccd4
MUTED_COLOR=0xff7f8490
ACCENT_COLOR=0xff7aa2f7

# Bar appearance.
sketchybar --bar \
  position=top \
  height=34 \
  color="$BAR_COLOR" \
  blur_radius=20 \
  padding_left=8 \
  padding_right=8 \
  sticky=on

# Defaults inherited by subsequently created items.
sketchybar --default \
  icon.font="SF Pro:Semibold:13.0" \
  label.font="SF Pro:Medium:13.0" \
  icon.color="$TEXT_COLOR" \
  label.color="$TEXT_COLOR" \
  icon.padding_left=8 \
  icon.padding_right=8 \
  label.padding_left=8 \
  label.padding_right=8

# Ask yabai for global Mission Control Space indices. If yabai is not ready
# during login, show the five Spaces expected by this machine; reload once
# yabai is running.
SPACE_IDS="$(yabai -m query --spaces 2>/dev/null | jq -r '.[].index' 2>/dev/null)"
if [[ -z "$SPACE_IDS" ]]; then
  SPACE_IDS="1 2 3 4 5"
fi

for sid in $SPACE_IDS; do
  space=(
    space="$sid"
    icon="$sid"
    label.drawing=off
    icon.color="$MUTED_COLOR"
    icon.highlight_color="$TEXT_COLOR"
    background.color="$ACCENT_COLOR"
    background.corner_radius=6
    background.height=24
    background.drawing=off
    script="$PLUGIN_DIR/space.sh"
    click_script="yabai -m space --focus $sid"
  )

  sketchybar --add space "space.$sid" left \
             --set "space.$sid" "${space[@]}"
done

# Focused application.
sketchybar --add item front_app left \
           --set front_app \
             icon.drawing=off \
             label.max_chars=40 \
             script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched

# Clock.
sketchybar --add item clock right \
           --set clock \
             icon.drawing=off \
             update_freq=10 \
             script="$PLUGIN_DIR/clock.sh"

# Initialize all items once, then reload automatically when config files change.
sketchybar --update
sketchybar --hotload on
```

### Space discovery behavior

At startup, the config asks yabai for current global Space indices. With the present setup this should return `1` through `5`.

If yabai is not ready when SketchyBar starts, the config falls back to five Spaces. Change the fallback if a different fixed count is preferred.

After creating, deleting, or rearranging Spaces, reload the bar:

```sh
sketchybar --reload
```

## 3. Create the Space plugin

Create:

```text
~/dotfiles/mac/sketchybar/.config/sketchybar/plugins/space.sh
```

Contents:

```sh
#!/usr/bin/env sh

# SketchyBar supplies SELECTED for native Space components.
sketchybar --set "$NAME" \
  icon.highlight="$SELECTED" \
  background.drawing="$SELECTED"
```

SketchyBar runs this plugin only when the Space's selected state changes. The active Space gets the accent background and highlighted text configured in `sketchybarrc`.

## 4. Create the focused-application plugin

Create:

```text
~/dotfiles/mac/sketchybar/.config/sketchybar/plugins/front_app.sh
```

Contents:

```sh
#!/usr/bin/env sh

if [ "$SENDER" = "front_app_switched" ]; then
  APP="$INFO"
else
  APP="$(yabai -m query --windows --window 2>/dev/null | jq -r '.app // ""')"
fi

sketchybar --set "$NAME" label="$APP"
```

The native `front_app_switched` event reports the front application. The yabai fallback initializes the label when SketchyBar performs its first forced update.

This identifies the application, not a specific window title. A title plugin can be added later using yabai signals or polling, but it is intentionally out of scope for the minimal bar.

## 5. Create the clock plugin

Create:

```text
~/dotfiles/mac/sketchybar/.config/sketchybar/plugins/clock.sh
```

Contents:

```sh
#!/usr/bin/env sh

sketchybar --set "$NAME" label="$(date '+%a %d %b  %H:%M')"
```

## 6. Make executable files executable

```sh
chmod +x ~/dotfiles/mac/sketchybar/.config/sketchybar/sketchybarrc
chmod +x ~/dotfiles/mac/sketchybar/.config/sketchybar/plugins/*.sh
```

Validate syntax:

```sh
bash -n ~/dotfiles/mac/sketchybar/.config/sketchybar/sketchybarrc
sh -n ~/dotfiles/mac/sketchybar/.config/sketchybar/plugins/space.sh
sh -n ~/dotfiles/mac/sketchybar/.config/sketchybar/plugins/front_app.sh
sh -n ~/dotfiles/mac/sketchybar/.config/sketchybar/plugins/clock.sh
```

## 7. Update the dotfiles README

Add `sketchybar` to the macOS Stow command:

```sh
cd ~/dotfiles/mac
stow -t ~ karabiner raycast zsh yabai skhd sketchybar
```

Document service startup:

```sh
brew services start sketchybar
```

Also document that SketchyBar requires **Displays have separate Spaces**.

## 8. Dry-run and apply Stow

Before linking, inspect for conflicts:

```sh
cd ~/dotfiles/mac
stow --no --verbose=2 --target="$HOME" sketchybar
```

If the dry run is clean:

```sh
stow --target="$HOME" sketchybar
```

Verify:

```sh
ls -ld ~/.config/sketchybar
ls -l ~/.config/sketchybar/sketchybarrc
ls -l ~/.config/sketchybar/plugins
```

Do not overwrite an existing real `~/.config/sketchybar` directory without reviewing and preserving it.

## 9. Start SketchyBar

Start it as a Homebrew service:

```sh
brew services start sketchybar
```

If it was already running:

```sh
brew services restart sketchybar
```

To debug interactively, stop the service and run SketchyBar in the terminal:

```sh
brew services stop sketchybar
sketchybar
```

Press `Ctrl+C` when finished, then restore the service:

```sh
brew services start sketchybar
```

The core bar, Space components, scripts, and clicks do not require Screen Recording. Native menu-bar `alias` components do require Screen Recording.

## 10. Auto-hide the native macOS menu bar

> [!IMPORTANT]
> Set the native menu bar to auto-hide. Otherwise macOS places SketchyBar below it, stacking both bars and allowing SketchyBar to overlap tiled windows.

Open:

**System Settings → Control Center → Automatically hide and show the menu bar → Always**

SketchyBar should move to the top of the display immediately. If it does not, reload it with `sketchybar --reload` or restart it with `brew services restart sketchybar`.

Reserve the bar and its top inset in yabai so tiled windows start below it:

```sh
yabai -m config external_bar all:40:0
```

Persist that command in `yabairc`. The current value reserves the 34px bar plus its 6px top inset; update it whenever the bar height or vertical offset changes.

The initial config only contains Spaces, focused application, and time. Before relying on SketchyBar alone, decide whether battery, volume, Wi-Fi, and other status items should be added.

SketchyBar can either:

- implement status items with scripts and native events, or
- mirror native menu-bar items using `alias` components.

Aliases require Screen Recording permission. Scripted Space indicators do not.

## 11. Validate

### Processes and configuration

```sh
sketchybar --version
brew services list | rg sketchybar
pgrep -fl sketchybar

sketchybar --query bar | jq
sketchybar --query displays | jq
sketchybar --query space.1 | jq
```

### Manual behavior test

1. Confirm Space numbers appear in the bar.
2. Switch with `⌘ 1–4`; the highlighted Space should update.
3. Click a Space number; yabai should focus it.
4. Move a window with `⇧⌘ 1–4`; the active indicator should follow.
5. Focus another application; the application label should update.
6. Connect or disconnect a display and confirm Space indicators remain on the display owning each Space.
7. Edit a color in `sketchybarrc`; hotload should refresh the bar.

### If no Spaces appear

```sh
yabai -m query --spaces | jq
sketchybar --reload
```

If yabai responds but the bar remains empty, stop the service and run `sketchybar` directly to inspect errors.

### If Space highlighting or placement is wrong

- Confirm **Displays have separate Spaces** is enabled.
- Log out and back in if that setting changed.
- Confirm every component has the correct `space=<index>` association:

  ```sh
  sketchybar --query space.1 | jq
  ```

- Reload after changing the number or ordering of Spaces.

### If clicking a Space does nothing

Run the same command directly:

```sh
yabai -m space --focus 1
```

If the direct command fails, troubleshoot yabai rather than SketchyBar. If it succeeds, inspect the Space item's `click_script` with `sketchybar --query space.1 | jq`.

## Everyday configuration workflow

SketchyBar hotloads edits under its config directory. Force a complete reload with:

```sh
sketchybar --reload
```

Properties can be tested live before changing dotfiles:

```sh
sketchybar --bar height=38
sketchybar --set space.1 background.color=0xffff9e64
```

Persistent settings belong in `sketchybarrc` or its plugin scripts.

## Installing on another Mac

```sh
# Install dependencies.
brew install stow jq
brew tap FelixKratz/formulae
brew install sketchybar

# Stow the config.
cd ~/dotfiles/mac
stow --target="$HOME" sketchybar

# Start the service after yabai is configured.
brew services start sketchybar

# Verify Displays have separate Spaces is enabled.
# Reload once yabai is running if fallback Space IDs appeared.
sketchybar --reload
```

## Updating

```sh
brew update
brew upgrade sketchybar
brew services restart sketchybar
```

Review release notes before major upgrades if the configuration stops loading.

## Uninstalling

```sh
brew services stop sketchybar

cd ~/dotfiles/mac
stow --delete --target="$HOME" sketchybar

brew uninstall sketchybar
```

Only untap `FelixKratz/formulae` if no other installed formula uses it. The `borders` focus-indicator tool also comes from this tap.

## Optional future improvements

- Battery and volume items using SketchyBar's native events.
- Application icons using `sketchybar-app-font`.
- Current window title from yabai.
- Occupied/empty Space styling using `space_windows_change`.
- Native menu-bar aliases, with Screen Recording permission.
- Different bars or item visibility per display.
- A Stow-managed JankyBorders package for focused-window borders.

## Source material

Read through GitHub using `gh` when this guide was written:

- [SketchyBar repository](https://github.com/FelixKratz/SketchyBar)
- [Setup](https://felixkratz.github.io/SketchyBar/setup)
- [Bar properties](https://felixkratz.github.io/SketchyBar/config/bar)
- [Items](https://felixkratz.github.io/SketchyBar/config/items)
- [Space components](https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item)
- [Events and scripting](https://felixkratz.github.io/SketchyBar/config/events)
- [Reloading and hotload](https://felixkratz.github.io/SketchyBar/config/reloading)
- [Querying](https://felixkratz.github.io/SketchyBar/config/querying)
- [Official example config](https://github.com/FelixKratz/SketchyBar/blob/master/sketchybarrc)
- [Official example plugins](https://github.com/FelixKratz/SketchyBar/tree/master/plugins)
- [JankyBorders](https://github.com/FelixKratz/JankyBorders)
