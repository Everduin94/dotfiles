" - Buffers | Splits -
nnoremap <TAB> :bnext<CR>
nnoremap <S-TAB> :bprevious<CR>

nnoremap <C-s> :wa<CR>
" Close buffer -- Hard quit -- OPTION+q
nnoremap œ :bd!<CR>
" Close buffer -- Save
map <leader>q :w\|bd<CR>
  
" Save all, Close all buffers but this one -- escape the | -- I wanted to keep
" this just so i have the syntax. But ctrl d is a bad bind (overwrites)
" nnoremap <C-D> mz\|:wa\|%bd\|e#\|bd#<cr>`z

" <TAB>: completion. -- TODO: Should this be here?
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Better tabbing - Enforce this mapping over plugins
vnoremap < <gv
vnoremap > >gv
nnoremap < <<
nnoremap > >>

" Better window navigation 
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>k
nnoremap <C-k> <C-w>j
nnoremap <C-l> <C-w>l


nnoremap gj gk
nnoremap gk gj

" - Base -
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L $
nnoremap j <Up>
nnoremap k <Down>
nnoremap J {zz
nnoremap K }zz
xnoremap j <Up>
xnoremap k <Down>
xnoremap J {zz
xnoremap K }zz
onoremap J {zz
onoremap K }zz
onoremap j <Up>
onoremap k <Down>
onoremap H ^
onoremap L $

" Undo Break Points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" Center when X
nnoremap n nzzzv
nnoremap N Nzzzv

" nnoremap J mzJ`z
nnoremap <leader>/ :noh<CR>
nnoremap <leader>k K
nnoremap <leader>j J

" ∆ and ˚ are the results of OPTION-J and OPTION-K on  mac 
nnoremap ˚ <esc>:m .+1<CR>==
nnoremap ∆ <esc>:m .-2<CR>==
vnoremap ˚ :m '>+1<CR>gv=gv
vnoremap ∆ :m '<-2<CR>gv=gv
nnoremap yL yg_
" TODO: Bring these back

" - Terminal | Normal Mode -
" « = OPTION+\
tnoremap « <C-\><C-N>

" - Fugitive -
map <leader>gf :G<CR>
map <leader>g1 :diffget //2<CR>
map <leader>g2 :diffget //3<CR>
map <leader>gcc :Git commit
map <leader>gco :Git checkout
map <leader>gcs :Git push -u
map <leader>gcp :Git pull -r
" Commit=cc Checkout=coo

" - Navigation - 
" Find files
map <leader>pp :Files<CR>
map <leader>po :GFiles<CR>
map <leader>pb :Buffers<CR>
map <leader>pq :Rgmacros<CR>
" Find in CWD
nnoremap <leader>pf :Rg<CR>
" Find in Git Root
nnoremap <leader>pg :Rgg<CR>
" Find in buffer directory
nnoremap <leader>ph :Rggg<CR>
" Strict find (not fuzzy)
nnoremap <leader>pF :RG<CR>
nnoremap <leader>pG :RGG<CR>
nnoremap <leader>pH :RGGG<CR>
nnoremap <leader>pt :Tags<CR>
nnoremap <leader>pm :Marks<CR>
nnoremap <leader>ps :Startify<CR>

" - Quick Fix List - 
" Center on moving and when closing list
nnoremap <leader>co :copen<CR>
nnoremap <leader>cl :cclose<CR>zz

" OPTION+Z: Previous | Option+X Next
nnoremap Ω :cp<CR>zz
nnoremap ≈ :cn<CR>zz


