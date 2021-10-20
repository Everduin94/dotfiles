
" nnoremap <silent> <leader> K :call <SID>show_documentation()<CR>
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
xmap <leader> la  <Plug>(coc-codeaction-selected)
nmap <leader> la  <Plug>(coc-codeaction-selected)


" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> <leader> lj <Plug>(coc-diagnostic-prev)
nmap <silent> <leader> lk <Plug>(coc-diagnostic-next)
nnoremap <silent><nowait> <leader>ld  :<C-u>CocList diagnostics<cr>
