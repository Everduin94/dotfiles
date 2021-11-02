
let g:startify_session_dir = '~/.config/nvim/sessions'

let g:startify_lists = [
          \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
          \ { 'type': 'files',     'header': ['   Files']            },
          \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
          \ { 'type': 'sessions',  'header': ['   Sessions']       },
          \ ]

let g:startify_bookmarks = [
            \ { 'i': '$WS_CONFIG/nvim/.config/nvim/init.vim' },
            \ { 'd': '$WS_CONFIG' },
            \ { 'z': '$WS_ZSHRC' },
            \ { 'r': '$WS_CX_CLOUD'},
            \ { 't': '$WS_PLAYGROUND'},
            \ { 'f': '$WS_FULL_METAL'},
            \ { 'u': '$WS_NOTES'},
            \ ]

let g:startify_session_autoload = 1
let g:startify_session_delete_buffers = 1
let g:startify_change_to_vcs_root = 0  " 1 is cool, but bad for mono
let g:startify_fortune_use_unicode = 1
let g:startify_session_persistence = 1
let g:startify_enable_special = 0


 let g:startify_custom_header = [
        \     '    _   ___    ________  ___',
        \    '   / | / / |  / /  _/  |/  /', 
        \   '  /  |/ /| | / // // /|_/ /', 
        \  ' / /|  / | |/ // // /  / /',
        \ '/_/ |_/  |___/___/_/  /_/',
        \ ]
