# better-prompts and persona integration

Findings only. Nothing here is built yet.

The goal is to start a chat with a pi persona from Neovim, either from a picker or from a better-prompts prompt, as many times as needed.

## How personas load

pi-persona-light (`~/dev/pi-persona-light`) applies a persona when pi starts:

```sh
pi --no-context-files --no-skills --no-extensions -e ~/dev/pi-persona-light --persona=research
```

The persona's system prompt, skills, tools, context, and extensions all load at startup, so a persona is picked when a chat starts. It can't be swapped into a running session. Personas live in `~/.pi/agent/pi-persona-light/pi-persona-light.config.json`.

## Getting persona flags into a chat

pi-acp always starts `pi --mode rpc --no-themes` and has no way to add flags. It does read `PI_ACP_PI_COMMAND`, which replaces `pi` with another executable. A small wrapper on the PATH can add the persona flags:

```sh
#!/bin/sh
exec pi --no-context-files --no-skills --no-extensions -e "$HOME/dev/pi-persona-light" --persona="$PI_PERSONA" "$@"
```

pi-persona-light could also read `PI_PERSONA` itself, but the wrapper would still be needed for the `--no-*` flags.

CodeCompanion ACP adapters can have several named start commands. One per persona would look like this:

```lua
research = { "env", "PI_PERSONA=research", "PI_ACP_PI_COMMAND=pi-persona", "pi-acp" }
```

`lua/config/ai.lua` could build these from the persona config at startup, so a new persona in the JSON shows up in Neovim with no other edits. Plain `<leader>an` keeps starting a normal pi chat with everything loaded.

## Ways to start a persona chat

- A picker key (for example `<leader>aP`) lists the personas and opens a new chat with the one you choose.
- `:CodeCompanionChat adapter=pi command=research` works once the commands exist, and suits a direct mapping.
- `/command` inside a chat switches persona, but it restarts pi. The old text stays in the buffer and the agent's context resets.

The statusline could show `research · claude-sonnet-5` in a persona chat instead of only the model.

## better-prompts

better-prompts (`~/dev/better-prompts`) builds a prompt from YAML steps, then hands the result to a named command from `.better-prompts/config.yaml`. That command is where it connects to Neovim.

The flow:

1. A key opens a floating terminal running `better-prompts prompt`.
2. You pick a prompt and fill in its steps, including the persona.
3. The prompt's command calls back into Neovim, and the float closes.
4. A new chat opens with that persona, and the prompt is already sent.

### The command

```yaml
commands:
  nvim-chat:
    inputs:
      persona: { default: "" } # empty means normal pi
    env:
      PERSONA: ${{ inputs.persona }}
    run: |
      f=$(mktemp); printf '%s' "$PROMPT_OUTPUT" > "$f"
      nvim --server "$NVIM" --remote-expr "v:lua.require'config.ai'.chat_from_file('$f', '$PERSONA')"
```

`nvim --server` doesn't open another editor. It connects to the Neovim you're already in, runs one function there, and exits. Neovim sets `$NVIM` to its own socket address in every terminal it starts, including the float. `bin/pi-nvim-edit` already uses this for the `<C-g>` prompt editor. Each run opens one more chat, and the existing chats stay open.

The temp file keeps multi-line prompts from breaking shell quoting.

### Choosing the persona

A prompt can fix its persona:

```yaml
command:
  use: nvim-chat
  with:
    persona: research
```

Or ask for it, loading the options from the persona config so there's one list:

```yaml
- id: persona
  type: select
  message: Persona?
  options:
    load: jq -r '.personas[].name' ~/.pi/agent/pi-persona-light/pi-persona-light.config.json
```

and pass `persona: ${{ steps.persona.output }}` to `nvim-chat`.

### Neovim side

`chat_from_file(path, persona)` in `ai.lua` would read the file and call `require("codecompanion").chat()` with the pi adapter, the persona's command, and the text as a message that's sent right away. `CodeCompanion.chat()` already accepts an adapter, an ACP command, and initial messages it submits.

better-prompts has its own searchable prompt list, so the float may be enough. A Snacks picker over `.better-prompts/prompts` in the repo and `~/.better-prompts/prompts` could pick the prompt in Neovim instead, then run `better-prompts prompt NAME` in the float.

Script steps such as `git diff --staged` run in Neovim's working directory, so a prompt picks up context from the current project.

## Before building

- better-prompts isn't on the PATH yet. Run `npm link` in the repo or install it globally.
- `~/.better-prompts/` doesn't exist yet. The `nvim-chat` command and personal prompts would go there.
- Outside Neovim `$NVIM` isn't set. Those runs can use `--command` with a terminal command, such as a `pi-persona` command that opens pi with the persona. The repo's `pi` command in `.better-prompts/config.yaml` shows the pattern.

## Build order

1. The wrapper script and the per-persona CodeCompanion commands.
2. The persona picker and the persona name in the statusline.
3. `chat_from_file`, the `nvim-chat` command, and a key that opens better-prompts in a float.
