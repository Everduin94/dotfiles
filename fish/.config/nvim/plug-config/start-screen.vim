
let g:startify_session_dir = '~/.config/nvim/sessions'

let g:startify_lists = [
          \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
          \ { 'type': 'files',     'header': ['   Files']            },
          \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
          \ { 'type': 'sessions',  'header': ['   Sessions']       },
          \ ]

let g:startify_bookmarks = [
            \ { 'i': '~/.config/nvim/init.vim' },
            \ { 'c': '~/.config' },
            \ { 'w': '~/Documents/dev/cx-cloud-ui-clone/cx-cloud-ui/apps/athena-playground'},
            \ { 'r': '~/Documents/dev/cx-cloud-ui/apps/cx-portal/src/main.ts'},
            \ { 't': '~/Documents/dev/erxk-article-playground/README.md'},
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
