# Vim Guide

The goal of these improvements is to limit the number of things that
slow me down or create mental overhead. A major piece of not being slowed down
is avoiding refreshing and manually viewing the browser.

## Emmet

Available on normal, insert, and visual: all prefixed with option

- option+l - balance in
- option+h - balance out
- option+, - expand
- option+o - next edit
- option+O - previous edit

## Git

Mostly fugitive

- leader+gf - open fugitive
- cc - create commit
- gq - close
- s - stage
- u - unstage
- X - discard
- Push - leader+gs
- Pull
  - Merge (Git pull) - leader+gm (Merge after pushing changes)
  - Rebase (Git pull -r) - (Only rebase unpushed changes)
- Merge Conflicts
  - Accept Left - leader+ga
  - Accept Right - leader+gl
- log
- diff
- blame

Some necessary configuration: `git config --global push.default current`

- Makes sure we can push on a new feature branch

## Snippets

Ultisnip, not fully setup yet

## Macros

- Add a macro - record -> ma -> name
- Use a macro - mf -> search (tab complete) -> use
- Search all macros - <leader>+pq

## Workflows

Git worktree

- Update main -> checkout branch -> copy node modules (script: )

## Windows / Splits / Sessions

### TMUX

- Explanation of session management (TODO)
- See notes/tmux.md: ~/Documents/dev/notes/creative-work/tmux.md
- Switch windows - should match nvim (TODO)
- Create pane - nvim or tmux can handle. Choose 1 or make same keybind (TODO)

### NVIM

- Save all -> Close all buffers except this one - C-d
- Save all - C-s
- Save & close buffer - <leader>+q
- Hard close buffer - C-q
- Move up/down splits - C-j / C-k
- Move left/right splits - C-h / C-l
- Switch buffer - TAB/SHIFT-TAB
- Open start - leader+ps

### Float Window

- Today I use Ranger -> S -> fish. Which is a ton of commands: leader+r S fish command. exit exit q
- TODO: Switch tmux default shell to fish (only did this cause red herring with treesitter)
- TODO: Install something like floatterm

## Testing things :)
