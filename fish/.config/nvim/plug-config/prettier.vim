" Allow prettier to run on autosave with form or perttier tags
" This is the magical combination to actaully use a .prettierrc file
" ! This did not work without "config_present"
let g:prettier#autoformat_config_present = 1
let g:prettier#autoformat_require_pragma = 0
let g:prettier#config#config_precedence = 'prefer-file'

