# yabai on macOS 27

## Why this exists

macOS 27 changed the private IOHID payload used by yabai's SIP-enabled,
animation-free Space-switching gesture. With official yabai 7.1.25,
`yabai -m space --focus N` can exit successfully without switching Spaces.
Window tiling and queries may continue to work, which makes the failure look
like a hotkey problem even though `skhd` is working correctly.

This is tracked in:

- [yabai issue #2822 — macOS 27](https://github.com/asmvik/yabai/issues/2822)
- [reviewed SIP-enabled fix](https://github.com/YazeedAlKhalaf/yabai/commit/9d6104a01fcba61ab4a19e5c19931da9efc76a7a)
- [original InstantSpaceSwitcher implementation](https://github.com/geesawra/InstantSpaceSwitcher/commit/79a17c4dd041639751a3d6087009864a2d6dcf1b)

The maintainer confirms in #2822 that the SIP-enabled path broke in macOS 27.
Multiple users confirmed the patch on macOS 27.0 build 26A428 with SIP enabled.
It was also built and tested on this dotfiles machine before installation.

This fix does **not** disable SIP or install yabai's scripting addition. Issue
[#2832](https://github.com/asmvik/yabai/issues/2832), concerning macOS 27.2
scripting-addition offsets, is a separate code path that this setup does not
use.

## What is pinned

`install/yabai-macos27.rb` builds:

- official yabai commit `dd845723416f5fe92af49fad5ebab00369e07edd`
- patch commit `9d6104a01fcba61ab4a19e5c19931da9efc76a7a`
- local formula version `7.1.25-macos27.1`

Both the source archive and patch have pinned SHA-256 checksums. The patch is
one commit over official master and is limited to the macOS 27 Space gesture,
its error handling, and tests. Homebrew builds it locally and ad-hoc signs the
result, just as the official yabai Homebrew formula does for `HEAD` builds.

## New Mac setup

### 1. Install and stow the normal dotfiles

From the dotfiles root:

```sh
brew bundle --file=install/Brewfile.macos-dotfiles

cd all
stow -t ~ git nvim starship wezterm ghostty hunk

cd ../mac
stow -t ~ hex karabiner raycast zsh yabai skhd sketchybar
```

Create the desired macOS Spaces manually. In **Desktop & Dock**:

- enable **Displays have separate Spaces**
- disable **Automatically rearrange Spaces based on most recent use**

Grant both the official `yabai` and `skhd` Accessibility access when prompted.
The patched binary may require yabai to be approved again later because its
signature differs.

### 2. Ensure macOS 27 Command Line Tools are installed

Check:

```sh
xcrun --show-sdk-version
```

It must report a 27.x SDK. If it does not, install **Command Line Tools for
Xcode 27.0** from **System Settings → General → Software Update**, or list the
exact command-line update label with:

```sh
softwareupdate --list
```

The installer checks this before changing the active yabai link.

### 3. Install patched yabai

From the dotfiles root:

```sh
./install/install-yabai-macos27.sh
```

The installer:

1. validates macOS and Command Line Tools version 27
2. ensures official yabai remains installed as a rollback copy
3. creates the standard local Homebrew tap `everduin/local`
4. copies the tracked formula into that tap
5. builds the pinned official source plus the reviewed patch
6. ad-hoc signs and links `yabai-macos27`
7. starts the existing yabai LaunchAgent
8. restores official yabai automatically if installation fails

The command is idempotent. Re-running it does not rebuild an already current
formula.

### 4. Re-approve Accessibility if requested

If the installer says Accessibility blocked yabai:

1. Open **System Settings → Privacy & Security → Accessibility**.
2. Remove the existing **yabai** entry.
3. Click `+`.
4. In the file picker, press `Command+Shift+G`.
5. Enter `/opt/homebrew/bin/yabai` and click **Open**.
6. Ensure yabai is enabled.
7. Restart it:

```sh
yabai --restart-service
```

## Verify

Confirm the patched formula owns the active binary:

```sh
readlink /opt/homebrew/bin/yabai
brew list --versions yabai yabai-macos27
```

The symlink should point into `Cellar/yabai-macos27/7.1.25-macos27.1`, while
both official `yabai` and patched `yabai-macos27` remain installed.

Confirm the daemon responds:

```sh
yabai -m query --spaces --space | jq '.index, ."has-focus"'
```

Test direct Space switching:

```sh
yabai -m space --focus 2
yabai -m space --focus 1
```

Finally test `Command+1` through `Command+9`. The tracked
`mac/skhd/.config/skhd/skhdrc` binds those keys directly to
`yabai -m space --focus N`; there are no Control+Arrow, Reduce Motion, or
native symbolic-hotkey workarounds in this setup.

For service diagnostics:

```sh
launchctl print "gui/$(id -u)/com.asmvik.yabai"
tail -50 "/tmp/yabai_${USER}.err.log"
tail -50 "/tmp/skhd_${USER}.err.log"
```

## Return to official yabai

After #2822 is merged and included in an official release, first update the
installed official formula, then restore it:

```sh
brew update
brew upgrade yabai
./install/install-yabai-macos27.sh --restore-official
```

The restore mode stops patched yabai, uninstalls it, relinks official yabai,
starts the service, removes the local tap, and removes the formula's Homebrew
trust entry. The tracked formula and documentation remain in dotfiles for
history and for any other Mac that still runs an affected release.
