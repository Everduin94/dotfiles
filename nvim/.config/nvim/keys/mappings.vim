" - Buffers | Splits -
" nnoremap <TAB> :bnext<CR>
" nnoremap <S-TAB> :bprevious<CR>
" nnoremap <C-s> :wa<CR>
" map <leader>q :w\|bd<CR>
  
" Save all, Close all buffers but this one -- escape the | -- I wanted to keep
" this just so i have the syntax. But ctrl d is a bad bind (overwrites)
" nnoremap <C-D> mz\|:wa\|%bd\|e#\|bd#<cr>`z

" Better tabbing 
" vnoremap < <gv
" vnoremap > >gv
" nnoremap < <<
" nnoremap > >>

" Better window navigation 
" nnoremap <C-h> <C-w>h
" nnoremap <C-j> <C-w>k
" nnoremap <C-k> <C-w>j
" nnoremap <C-l> <C-w>l

" - Base -
" nnoremap H ^
" nnoremap L $
" vnoremap H ^
" vnoremap L $
" onoremap H ^
" onoremap L $

" Undo Break Points
" inoremap , ,<c-g>u
" inoremap . .<c-g>u
" inoremap ! !<c-g>u
" inoremap ? ?<c-g>u

" Center when X
" nnoremap n nzzzv
" nnoremap N Nzzzv

" nnoremap J mzJ`z
" nnoremap <leader>/ :noh<CR>
" nnoremap <leader>k K
" nnoremap <leader>j J

" nnoremap yL yg_
" TODO: Bring these back

" - Fugitive -
" map <leader>gf :G<CR>
" map <leader>g1 :diffget //2<CR>
" map <leader>g2 :diffget //3<CR>
" map <leader>gcc :Git commit
" map <leader>gco :Git checkout
" map <leader>gcs :Git push -u
" map <leader>gcp :Git pull -r
" Commit=cc Checkout=coo

" - Navigation - 
" Find files
" map <leader>pp :Files<CR>
" map <leader>po :GFiles<CR>
" map <leader>pb :Buffers<CR>
" map <leader>pq :Rgmacros<CR>
" Find in CWD
" nnoremap <leader>pf :Rg<CR>
" Find in Git Root
" nnoremap <leader>pg :Rgg<CR>
" Find in buffer directory
" nnoremap <leader>ph :Rggg<CR>
" Strict find (not fuzzy)
" nnoremap <leader>pF :RG<CR>
" nnoremap <leader>pG :RGG<CR>
" nnoremap <leader>pH :RGGG<CR>
" nnoremap <leader>pt :Tags<CR>
" nnoremap <leader>pm :Marks<CR>
" nnoremap <leader>ps :Startify<CR>

" - Quick Fix List - 
" Center on moving and when closing list
" nnoremap <leader>co :copen<CR>
" nnoremap <leader>cl :cclose<CR>zz

" let g:os = substitute(system('uname'), '\n', '', '')

" if "Linux" == g:os
"   nnoremap <A-q> :bd!<CR>
"   nnoremap <A-z> :cp<CR>zz
"   nnoremap <A-x> :cn<CR>zz
"   nnoremap <A-j> G
"   nnoremap <A-k> <esc>:m .+1<CR>==
"   nnoremap <A-j> <esc>:m .-2<CR>==
"   vnoremap <A-k> :m '>+1<CR>gv=gv
"   vnoremap <A-j> :m '<-2<CR>gv=gv
"   tnoremap <A-\> <C-\><C-N>
"   " EMMET
"   " Option+h balance outward
"   nmap <A-h> <C-y>d
"   imap <A-h> <C-y>d
"   vmap <A-h> <C-y>d
"   " Option+l balance inward
"   nmap <A-l> <C-y>D
"   imap <A-l> <C-y>D
"   vmap <A-l> <C-y>D
"   " Option+, ´ expand -- Testing new binds (g)
"   nmap <A-,> <C-y>,
"   imap <A-,> <C-y>,
"   nmap <A-g> <C-y>,
"   imap <A-g> <C-y>,
"   " Option+o ø go to next edit
"   nmap <A-o> <C-y>n
"   imap <A-o> <C-y>n
"   " Option+O Ø go to previous edit
"   nmap <A-s-o> <C-y>N
"   imap <A-s-o> <C-y>N
" else
"   " Darwin
"   nnoremap œ :bd!<CR>
"   nnoremap Ω :cp<CR>zz
"   nnoremap ≈ :cn<CR>zz
"   nnoremap ˚ <esc>:m .+1<CR>==
"   nnoremap ∆ <esc>:m .-2<CR>==
"   vnoremap ˚ :m '>+1<CR>gv=gv
"   vnoremap ∆ :m '<-2<CR>gv=gv
"   " - Terminal | Normal Mode - 
"   tnoremap « <C-\><C-N>

"   " EMMET
"   " Option+h balance outward
"   nmap ˙ <C-y>d
"   imap ˙ <C-y>d
"   vmap ˙ <C-y>d
"   " Option+l balance inward
"   nmap ¬ <C-y>D
"   imap ¬ <C-y>D
"   vmap ¬ <C-y>D
"   " Option+, ´ expand TODO: Add alt+g
"   nmap ≤ <C-y>,
"   imap ≤ <C-y>,
"   " Option+o ø go to next edit
"   nmap ø <C-y>n
"   imap ø <C-y>n
"   " Option+O Ø go to previous edit
"   nmap Ø <C-y>N
"   imap Ø <C-y>N
" endif

