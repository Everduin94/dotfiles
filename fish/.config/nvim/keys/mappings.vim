" Better nav for omnicomplete (FLIPPED)
inoremap <expr> <c-k> ("\<C-n>")
inoremap <expr> <c-j> ("\<C-p>")

" Use alt + hjkl to resize windows
" nnoremap <M-j>    :resize -2<CR>
" nnoremap <M-k>    :resize +2<CR>
nnoremap <M-h>    :vertical resize -2<CR>
nnoremap <M-l>    :vertical resize +2<CR>

" Easy CAPS
inoremap <c-u> <ESC>viwUi
nnoremap <c-u> viwU<Esc>

" TAB in general mode will move to text buffer
nnoremap <TAB> :bnext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :bprevious<CR>

" Alternate way to save
nnoremap <C-s> :w<CR>
" Alternate way to quit
nnoremap <C-Q> :wq!<CR>
" Use control-c instead of escape
nnoremap <C-c> <Esc>
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Better tabbing
vnoremap < <gv
vnoremap > >gv

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
nnoremap <leader>y yyp
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

" Navigation, Sessions, FZF

map <leader>pp :Files<CR>
map <leader>po :GFiles<CR>
map <leader>pb :Buffers<CR>
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


" Toggle relative line number
nmap <C-L><C-L> :set invrelativenumber<CR>
