let g:rnvimr_ex_enable = 1              " Make Ranger replace netrw and be the file explorer
let g:rnvimr_enable_picker = 1          " Hide Ranger On File Pick
let g:rnvimr_hide_gitignore = 1         " Hide files included in .gitignore
let g:rnvimr_enable_bw = 1              " Wipe Buffer Corresponding to File Deleted by Ranger
let g:rnvimr_ranger_cmd = 'ranger --cmd="set draw_borders both"' " Draw Border with Both? 
nmap <space>r :RnvimrToggle<CR>
