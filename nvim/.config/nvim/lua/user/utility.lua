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

  " Prettier -- Replace me
    " Allow prettier to run on autosave with form or perttier tags
    " This is the magical combination to actaully use a .prettierrc file
    " ! This did not work without "config_present"
  let g:prettier#autoformat_config_present = 1
  let g:prettier#autoformat_require_pragma = 0
  let g:prettier#config#config_precedence = 'prefer-file'

  " Vim Wiki
  let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'},
        \ {'path': '~/Documents/dev/notes/', 'syntax': 'markdown', 'ext': '.md'},
        \ {'path': '~/Documents/dev/task-manager/', 'syntax': 'markdown', 'ext': '.md'}
        \ ]

  " Auto Commands
    " Wiki
  autocmd FileType markdown nmap <buffer><silent> <leader>mp :call mdip#MarkdownClipboardImage()<CR>
    " Man
  autocmd FileType man nnoremap <buffer> j gk
  autocmd FileType man nnoremap <buffer> k gj
    " Tmux
  autocmd BufWritePost ~/dotfiles/tmux/.config/tmux/tmux.conf execute ':!tmux source-file %' 
]]
