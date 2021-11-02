" Better nav for omnicomplete (FLIPPED)
" inoremap <expr> <c-k> ("\<C-n>")
" inoremap <expr> <c-j> ("\<C-p>")


" Use alt + hjkl to resize windows
" nnoremap <M-j>    :resize -2<CR>
" nnoremap <M-k>    :resize +2<CR>
" nnoremap <M-h>    :vertical resize -2<CR>
" nnoremap <M-l>    :vertical resize +2<CR>

" Easy CAPS
inoremap <c-u> <ESC>viwUi
nnoremap <c-u> viwU<Esc>

" TAB in general mode will move to text buffer
nnoremap <TAB> :bnext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :bprevious<CR>

" Alternate way to save
nnoremap <C-s> :wa<CR>
" Close buffer -- Hard quit -- OPTION+q
nnoremap œ :bd!<CR>
" Close buffer -- Save
map <leader>q :w\|bd<CR>
" Save all, Close all buffers but this one -- escape the | 
nnoremap <C-D> mz\|:wa\|%bd\|e#\|bd#<cr>`z
" <TAB>: completion. -- TODO: Should this be here?
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

map ß :w\|so %<CR>

" Better tabbing
vnoremap < <gv
vnoremap > >gv
nnoremap < <<
nnoremap > >>

" Better window navigation (NOT FLIPPED - May not need?)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>k
nnoremap <C-k> <C-w>j
nnoremap <C-l> <C-w>l

" What do this do?
" nnoremap <Leader>o o<Esc>^Da
" nnoremap <Leader>O O<Esc>^Da


" My Remaps
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L $
nnoremap j k
nnoremap k j
nnoremap J {zz
nnoremap K }zz
xnoremap j k
xnoremap k j
xnoremap J {zz
xnoremap K }zz
onoremap J {zz
onoremap K }zz
onoremap j k
onoremap k j
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

" ∆ and ˚ are literally the results of OPTION-J and OPTION-K on my mac in
" hyper -- May have to change for aca
"nnoremap ∆ :m .-2<CR>==
"nnoremap ˚ :m .+1<CR>==
nnoremap ˚ <esc>:m .+1<CR>==
nnoremap ∆ <esc>:m .-2<CR>==
vnoremap ˚ :m '>+1<CR>gv=gv
vnoremap ∆ :m '<-2<CR>gv=gv
nnoremap yL yg_
nnoremap <expr> j (v:count > 1 ? "m'" . v:count : '') . 'gk'
nnoremap <expr> k (v:count > 1 ? "m'" . v:count : '') . 'gj'

" Terminal
" Normal Mode
" « = OPTION+\
tnoremap « <C-\><C-N>

" Navigation, Sessions, FZF

" Fugitive
map <leader>gf :G<CR>
map <leader>g1 :diffget //2<CR>
map <leader>g2 :diffget //3<CR>

" Fugitive: Commit=cc Checkout=coo
map <leader>gcc :Git commit
map <leader>gco :Git checkout
map <leader>gcs :Git push -u
map <leader>gcp :Git pull -r
" map <leader>gs :G push -u<CR>

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

" Quick Fix List -- Center on moving and when closing list
nnoremap <leader>co :copen<CR>
nnoremap <leader>cl :cclose<CR>zz
" OPTION+z: Previous Option+x next
nnoremap Ω :cp<CR>zz
nnoremap ≈ :cn<CR>zz


" Toggle relative line number
" nmap <C-L><C-L> :set invrelativenumber<CR>
