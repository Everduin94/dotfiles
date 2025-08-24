# Neovim Config

<img width="1483" height="909" alt="Screenshot 2025-08-24 at 7 46 13 AM" src="https://github.com/user-attachments/assets/e500a536-5912-4805-ad07-3f47def2407e" />

This is my [LazyVim](https://github.com/LazyVim/LazyVim) configuration. Some refactoring is still in progress. Most of the configuration is located in the `modules` folder. Each `module` represents functionality of the editor. Some functionality is not explicitly defined, because it is using the `LazyVim` defaults or a `LazyVimExtra`.

Some things my configuration does that you might find interesting:

- The `sub_mode` module repurposes `TAB` and `SHIFT-TAB` based on a custom mode. For example, looping over git hunks or lsp errors.
- The `snippets` module allows for activating of snippets via hotkeys, and adds them to `whichkey`.
- The `ai` module has examples of using a locally hosted ollama instance for free, private, offline-capable AI.
- The `navigation` module sets up plugins for switching between files with the fewest keystrokes.
- The `ui` module creates a minimal lua-line, and adds the title of the file in the buffer to the top corner via `incline`. buffer-line is disabled in `plugins.lua`.
- `faster-whisper.py` allows you to record a mp3 via `ffmpeg` and then transcribe it with `faster-whisper` on a consumer cpu. - Allowing you to talk > text > paste.


> [!NOTE]
> All `modules` are loaded by `plugins.lua` inside of `/plugins`.
