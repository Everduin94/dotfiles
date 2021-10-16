let g:marvim_find_key = 'mf' " change find key from <F2> to 'mf'
let g:marvim_store_key = 'ms'     " change store key from <F3> to 'ms'

" TODO: This must change once we fix dotfiles (point to .config)
let g:marvim_store = '/Users/everduin/dotfiles/fish/.config/nvim/macros' 

nmap <leader>Rt mfstoreprop<CR>mfstoreselect<CR>mfstorevm2<CR>mfstoreupdater<CR>mfsubproptype<CR>mfstoreupcaseupdater<CR>
nmap <leader>Ry mfstoreprop<CR>mfstoreselect<CR>mfstorevm2<CR>mfstoreupdater<CR>mfstorevalue<CR>mfsubvalue<CR>mfsubproptype<CR>mfstoreupcaseupdater<CR>
