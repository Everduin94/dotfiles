" LSP config (the mappings used in the default file don't quite work right)
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gli <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gls <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> <C-n> <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> <C-p> <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <silent> glr <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> glc <cmd>lua vim.lsp.buf.code_action()<CR>

" TODO: Can we replace vim-prettier by setting this up with efm?
" - Basically, we need to find out the command for efm format, then run on
"   write.
"
" auto-format -- Replaced with vim-prettier
" autocmd BufWritePre *.js lua vim.lsp.buf.formatting_sync(nil, 100)
" autocmd BufWritePre *.ts lua vim.lsp.buf.formatting_sync(nil, 100)
" autocmd BufWritePre *.html lua vim.lsp.buf.formatting_sync(nil, 100)
" autocmd BufWritePre *.scss lua vim.lsp.buf.formatting_sync(nil, 100)
" autocmd BufWritePre *.css lua vim.lsp.buf.formatting_sync(nil, 100)
