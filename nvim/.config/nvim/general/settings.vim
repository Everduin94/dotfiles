" set leader key
let g:mapleader = "\<Space>"

filetype plugin on

au! BufWritePost $MYVIMRC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC
