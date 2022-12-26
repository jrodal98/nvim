-- Shorten function name
local keymap = vim.keymap.set
-- Silent keymap option
local opts = { noremap = true, silent = true }

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- save file
keymap("n", "<leader>w", ":w<CR>", opts)

-- line navigation
keymap("n", "H", "^", opts) -- go to first char in line easier
keymap("n", "L", "$", opts) -- go to last char in line easier
keymap("v", "J", ":m '>+1<CR>gv=gv", opts) -- move visual selection up
keymap("v", "K", ":m '<-2<CR>gv=gv", opts) -- move visual selection down

-- spellcheck
keymap("n", "<leader>sc", ":setlocal spell! spelllang=en_us<CR>", opts) -- spellcheck

-- word substitution
keymap("n", "<leader>so", "*cgn", { remap = true }) -- substitute word "once". Dot repeat to replace next match
keymap("n", "<leader>sw", ':%s/<C-r>=expand("<cword>")<CR>//g<left><left>', opts) -- subtitute word everywhere
keymap("v", "<leader>sw", '"hy:%s/<C-r>h//g<left><left>', opts) -- substitute word everwhere (visual mode)
keymap("n", "*", "m`:keepjumps normal! *``<cr>", opts) -- don't jump to next word when matching with *

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- window resize logic
keymap("n", "<Up>", ":resize +1<CR>", opts)
keymap("n", "<Down>", ":resize -1<CR>", opts)
keymap("n", "<left>", ":vertical resize -1<CR>", opts)
keymap("n", "<right>", ":vertical resize +1<CR>", opts)

-- Navigate buffers
keymap("n", "<TAB>", ":bnext<CR>", opts)
keymap("n", "<S-TAB>", ":bprevious<CR>", opts)
-- Close buffers
keymap("n", "<LEADER>x", "<cmd>Bdelete!<CR>", opts)

-- Clear notifications, highlights, and short messages
keymap("n", "<Esc>", function()
   require("notify").dismiss() -- clear notifications
   vim.cmd.nohlsearch() -- clear highlights
   vim.cmd.echo() -- clear short-message
end, opts)

-- Folding
--  Increase with zm, decrease with zr, fold all with zM, unfold all with zR
--  Toggle fold with za, open fold with zo, close fold with zc
--  If foldmethod is changed to manual, zf to fold (use as text object, e.g. zfaw, or in visual mode)
-- Toggle fold
keymap({ "n", "v" }, "<LEADER><space>", "za", opts)

-- Better paste
keymap("v", "p", '"_dP', opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Plugins --

-- NvimTree
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Telescope
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fa", ":Telescope find_files follow=true no_ignore=true hidden=true <CR>", opts)
keymap("n", "<leader>fo", ":Telescope oldfiles<CR>", opts)
keymap("n", "<leader>fw", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)

-- Git
keymap("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", opts)

-- Comment
keymap("n", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", opts)
keymap("x", "<leader>/", '<ESC><CMD>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>')

-- DAP
keymap("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts)
keymap("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", opts)
keymap("n", "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", opts)
keymap("n", "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", opts)
keymap("n", "<leader>dO", "<cmd>lua require'dap'.step_out()<cr>", opts)
keymap("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", opts)
keymap("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", opts)
keymap("n", "<leader>du", "<cmd>lua require'dapui'.toggle()<cr>", opts)
keymap("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<cr>", opts)

-- Toggleterm
keymap("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", opts)
keymap("n", "<leader>tt", "<cmd>ToggleTerm direction=tab<cr>", opts)
keymap("n", "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", opts)
keymap("n", "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", opts)
keymap("n", "<leader>tp", "<cmd>lua _PYTHON_TOGGLE()<cr>", opts)

-- cutlass
keymap("n", "x", "d", opts)
keymap("x", "x", "d", opts)
keymap("n", "xx", "dd", opts)
keymap("n", "X", "D", opts)

-- OSCYank
keymap("v", "<leader>y", ":OSCYank <CR>", opts)
