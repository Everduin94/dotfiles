vim.cmd [[
  " Sneak
  let g:sneak#label = 1
    " case insensitive sneak
  let g:sneak#use_ic_scs = 1
    " no smart s
  let g:sneak#s_next = 0

    " remap so I can use , and ; with f and t
  map gS <Plug>Sneak_,
  map gs <Plug>Sneak_;
  let g:sneak#prompt = '🔭 '

  " Quick Scope
  let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
  let g:qs_max_chars=150

  " Codi
  highlight CodiVirtualText guifg=#73daca
  let g:codi#virtual_text_prefix = "❯ "
  let g:codi#aliases = {
                     \ 'javascript.jsx': 'javascript',
                     \ }

  " Vim Wiki
  let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'},
        \ {'path': '~/Documents/dev/notes/', 'syntax': 'markdown', 'ext': '.md'},
        \ {'path': '~/Documents/dev/task-manager/', 'syntax': 'markdown', 'ext': '.md'}
        \ ]

  " Set v-split border width
  " ▎ ━
  set fillchars+=vert:\│	
        
  " Auto Commands
    " Wiki
  augroup Markdown
    autocmd!
    autocmd FileType markdown set wrap
    autocmd FileType markdown set linebreak
    autocmd FileType markdown nmap <buffer><silent> <leader>mp :call mdip#MarkdownClipboardImage()<CR>
  augroup END
    " Man
  autocmd FileType man nnoremap <buffer> j gk
  autocmd FileType man nnoremap <buffer> k gj
    " Tmux
  autocmd BufWritePost ~/dotfiles/tmux/.config/tmux/tmux.conf execute ':!tmux source-file %' 
    " General
  augroup _general_settings
    autocmd!
    autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR> 
    autocmd BufWinEnter * :set formatoptions-=cro
    autocmd FileType qf set nobuflisted
  augroup end

  augroup _highlights
    autocmd!
    autocmd ColorScheme * highlight TelescopeNormal cterm=NONE ctermbg=76 ctermfg=16 gui=NONE guibg=NONE guifg=#a9b1d6
    \ | highlight TelescopePrompt cterm=NONE ctermbg=76 ctermfg=16 gui=NONE guibg=NONE guifg=#a9b1d6
    \ | highlight TelescopeBorder cterm=NONE ctermbg=76 ctermfg=16 gui=NONE guibg=NONE guifg=#7aa2f7
    \ | highlight NvimTreeNormal cterm=NONE ctermbg=76 ctermfg=16 gui=NONE guibg=NONE guifg=#a9b1d6
    \ | highlight NvimTreeVertSplit cterm=NONE gui=NONE guibg=#7aa2f7 guifg=#a9b1d6
    \ | highlight NormalFloat cterm=NONE ctermbg=76 ctermfg=16 gui=NONE guibg=NONE guifg=#a9b1d6
    \ | highlight VertSplit cterm=reverse gui=NONE guifg=#7aa2f7
    \ | highlight FloatBorder cterm=NONE gui=NONE guibg=NONE guifg=#7aa2f7
  augroup end
]]
