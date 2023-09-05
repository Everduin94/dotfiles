local options = {
 hidden=true,                             -- Required to keep multiple buffers open multiple buffers
 wrap=false,                             -- Display long lines as just one line
 encoding="utf-8",                        -- The encoding displayed
 pumheight=10,                            -- Makes popup menu smaller
 fileencoding="utf-8",                    -- The encoding written to file
 ruler=true,              		            -- Show the cursor position all the time
 cmdheight=1,                             -- More space for displaying messages - Was 2, made 1
 mouse="a",                               -- Enable your mouse
 splitbelow=true,                         -- Horizontal splits will automatically be below
 splitright=true,                         -- Vertical splits will automatically be to the right
 swapfile = false,                        -- Creates a swapfile
 conceallevel=0,                          -- So that I can see `` in markdown files
 tabstop=2,                               -- Insert 2 spaces for a tab
 shiftwidth=2,                            -- Change the number of space characters inserted for indentation
 smarttab=true,                           -- Makes tabbing smarter will realize you have 2 vs 4
 expandtab=true,                          -- Converts tabs to spaces
 -- smartindent=true,                     -- Makes indenting smart (THIS BREAKS SVELTE INDENT AND I USED BROKEN INDENTS FOR 8 MONTHS WHYYYYYYYYYYYYY)
 -- autoindent=true,                         -- Good auto indent
 number=true,                             -- Line numbers
 background="dark",                       -- Tell vim what the background color looks like
 showtabline=0,                           -- Always show tabs
 updatetime=300,                          -- Faster completion
 timeoutlen=500,                          -- By default timeoutlen is 1000 ms
 clipboard="unnamedplus",                 -- Copy paste between vim and everything else
 signcolumn="yes",                        -- Always show sign column for signify
 ignorecase=true,                         -- Ignore case for search
 relativenumber=true,                     -- 3 2 1 39 1 2 3
 showmode=false,                          -- Hide INSERT
 compatible=false,                        -- Not compatible with vi
 termguicolors=true,                      -- Required for colorizer
 scrolloff = 8,                           -- NEW
 sidescrolloff = 8,                       -- NEW
 completeopt = { "menuone", "noselect" },
 laststatus = 3,
 showcmd = false,
 spell = false,
} 

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd [[set iskeyword+=-]]
