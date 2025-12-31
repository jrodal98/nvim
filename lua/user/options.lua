local opt = vim.opt

-- General
opt.mouse = "c" -- Only allow mouse in command-line mode
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.fileencoding = "utf-8" -- File encoding
opt.termguicolors = true -- Enable 24-bit RGB colors

-- UI
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.cursorline = true -- Highlight current line
opt.signcolumn = "yes" -- Always show sign column to prevent text shifting
opt.colorcolumn = "80" -- Show column border at 80 chars
opt.showmode = false -- Don't show mode (shown in statusline)
opt.showcmd = false -- Don't show partial commands
opt.ruler = false -- Don't show ruler (shown in statusline)
opt.laststatus = 3 -- Global statusline
opt.cmdheight = 1 -- Command line height
opt.pumheight = 10 -- Popup menu height
opt.showtabline = 0 -- Never show tabline
opt.numberwidth = 2 -- Minimal number width
opt.guifont = "monospace:h17" -- GUI font
opt.fillchars.eob = " " -- Hide end-of-buffer tildes

-- Splitting
opt.splitbelow = true -- Horizontal splits go below
opt.splitright = true -- Vertical splits go right

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Number of spaces for indentation
opt.tabstop = 2 -- Number of spaces tabs count for
opt.smartindent = true -- Smart auto-indenting

-- Search
opt.hlsearch = true -- Highlight search results
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Override ignorecase if search has uppercase

-- Wrapping & Scrolling
opt.wrap = true -- Wrap long lines
opt.linebreak = true -- Wrap at word boundaries
opt.scrolloff = 8 -- Lines to keep above/below cursor
opt.sidescrolloff = 8 -- Columns to keep left/right of cursor

-- Files & Buffers
opt.autoread = true -- Auto-reload files changed outside vim
opt.backup = false -- Don't create backup files
opt.swapfile = false -- Don't create swap files
opt.writebackup = false -- Don't backup before overwriting file
opt.undofile = true -- Enable persistent undo

-- Completion
opt.completeopt = { "menuone", "noselect" } -- Completion options
opt.shortmess:append "c" -- Don't show completion messages
opt.conceallevel = 0 -- Don't hide characters (e.g., `` in markdown)

-- Timing
opt.updatetime = 300 -- Faster completion and swap write (default: 4000ms)
opt.timeoutlen = 1000 -- Time to wait for mapped sequence

-- Behavior
opt.whichwrap:append "<,>,[,],h,l" -- Allow h/l to wrap lines
opt.iskeyword:append "-" -- Treat dash as part of word
opt.formatoptions:remove { "c", "r", "o" } -- Don't auto-continue comments

-- Folding
opt.foldmethod = "indent" -- Fold based on indentation
opt.foldnestmax = 10 -- Maximum fold nesting
opt.foldlevelstart = 10 -- Start with all folds open
