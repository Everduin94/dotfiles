let g:coc_global_extensions = [
      \'coc-html',
      \'coc-tsserver',
      \'coc-vimlsp',
      \'coc-angular',
      \'coc-css',
      \'coc-highlight',
      \'coc-prettier', 
      \'coc-json', 
      \'coc-eslint',
      \'coc-snippets',
      \]

" Removed coc-git

nmap <leader>lf <Plug>(coc-fix-current)
nmap <leader>lc <Plug>(coc-codeaction)
nmap <leader>lr <Plug>(coc-rename)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> <leader>K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover') 
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Test these
" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>la  <Plug>(coc-codeaction-selected)
nmap <leader>la  <Plug>(coc-codeaction-selected)


" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> <leader>lj <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>lk <Plug>(coc-diagnostic-next)
nnoremap <silent><nowait> <leader>ld  :<C-u>CocList diagnostics<cr>


" Snippets -- TODO: Test these. Did not test defaults

" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)
" let g:UltiSnipsExpandTrigger="<c-l>" -- This doesn't work because all is
" done via coc. Not ultisnips

" Use <C-k> for select text for visual placeholder of snippet.
vmap <C-k> <Plug>(coc-snippets-select)

" Use <C-k> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-k>'

" Use <C-j> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-j>'

" Use <C-k> for both expand and jump (make expand higher priority.)
imap ∫ <Plug>(coc-snippets-expand-jump)


" Testing
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'
