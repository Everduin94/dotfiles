" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'



let g:fzf_tags_command = 'ctags -R'
" Border color
let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,'yoffset':0.5,'xoffset': 0.5, 'highlight': 'Todo', 'border': 'sharp' } }

" Changed to ignore node modules -- I don't think this matters though. Since
" you always use :RG or :Rg or :Files
let $FZF_DEFAULT_OPTS = '--keep-right --layout=reverse --info=inline --bind=ctrl-j:up,ctrl-k:down'
let $FZF_DEFAULT_COMMAND='rg --files --hidden -g "!{node_modules/*,.git/*,.vscode/*,*/package-lock.json}"'


" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

"Get Files

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}), <bang>0)

" Git Dir, does not reload til cwd change.
function! GetGitDir()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction

" Get text in files with Rg -- Actually Fuzzy
" Limit columns, avoids IDs/Hashes getting mixed in fuzzy search
" I added langArgs to make specific file searches like CSS only or filter
" garbage for the most common usecases
function! FuzzyRipgrep(query, fullscreen, dir, langArgs)
  call fzf#vim#grep(
  \   'rg --column --line-number --max-columns=150 --color=always --no-heading --ignore-case ' . a:langArgs.shellescape(a:query), 1,
  \   fzf#vim#with_preview({'options': ['--delimiter=:', '--nth=4..'], 'dir': a:dir}), a:fullscreen)
endfunction

command! -bang -nargs=* Rg call FuzzyRipgrep(<q-args>, <bang>0, getcwd(), ' -Tjson ' )
command! -bang -nargs=* Rgg call FuzzyRipgrep(<q-args>, <bang>0, GetGitDir(), ' -Tjson ' )
command! -bang -nargs=* Rggg call FuzzyRipgrep(<q-args>, <bang>0, expand('%:p:h'), ' -Tjson ' )
command! -bang -nargs=* Rgcss call FuzzyRipgrep(<q-args>, <bang>0, getcwd(), " -tcss " )

nnoremap <silent> <Leader>piw :Rg <C-R><C-W><CR>
nnoremap <silent> <Leader>pig :Rgg <C-R><C-W><CR>
nnoremap <silent> <Leader>pic :Rgcss <C-R><C-W><CR>

" Ripgrep advanced -- Not fuzzy (exact search)
function! RipgrepFzf(query, fullscreen, dir)
  let command_fmt = 'rg --column --line-number --color=always --no-heading --ignore-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command], 'dir': a:dir}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0, getcwd())
command! -nargs=* -bang RGG call RipgrepFzf(<q-args>, <bang>0, GetGitDir())
command! -nargs=* -bang RGGG call RipgrepFzf(<q-args>, <bang>0, expand('%:p:h'))

" Git grep
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)
