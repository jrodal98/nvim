local keymap = vim.keymap.set

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable space in normal/visual mode (already mapped to leader)
keymap({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- ========================================
-- General
-- ========================================

-- Save file
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- ========================================
-- Navigation
-- ========================================

-- Line navigation - H/L for start/end of line
keymap("n", "H", "^", { desc = "Go to first non-blank character" })
keymap("n", "L", "$", { desc = "Go to end of line" })

-- Move visual selection up/down
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when searching
keymap("n", "*", "m`:keepjumps normal! *``<CR>", { desc = "Search word under cursor (no jump)" })

-- ========================================
-- Window Navigation
-- ========================================

-- Normal mode window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Terminal mode window navigation
keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to bottom window" })
keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to top window" })
keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })

-- Window resizing
keymap("n", "<Up>", "<cmd>resize +1<CR>", { desc = "Increase window height" })
keymap("n", "<Down>", "<cmd>resize -1<CR>", { desc = "Decrease window height" })
keymap("n", "<Left>", "<cmd>vertical resize -1<CR>", { desc = "Decrease window width" })
keymap("n", "<Right>", "<cmd>vertical resize +1<CR>", { desc = "Increase window width" })

-- ========================================
-- Buffer Navigation
-- ========================================

keymap("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- ========================================
-- Editing
-- ========================================

-- Better paste (don't overwrite register)
keymap("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Stay in indent mode
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- ========================================
-- Search & Replace
-- ========================================

-- Substitute word once (use . to repeat for next occurrence)
keymap("n", "<leader>so", "*cgn", { remap = true, desc = "Substitute word once (repeat with .)" })

-- Substitute word everywhere in buffer
keymap("n", "<leader>sw", ':%s/<C-r>=expand("<cword>")<CR>//g<Left><Left>', { desc = "Substitute word globally" })
keymap("v", "<leader>sw", '"hy:%s/<C-r>h//g<Left><Left>', { desc = "Substitute selection globally" })

-- ========================================
-- Folding
-- ========================================

-- Toggle fold (za is default, but making it more discoverable)
keymap({ "n", "v" }, "<leader><space>", "za", { desc = "Toggle fold" })

-- ========================================
-- Utilities
-- ========================================

-- Spellcheck toggle
keymap("n", "<leader>sc", "<cmd>setlocal spell! spelllang=en_us<CR>", { desc = "Toggle spellcheck" })

-- Format JSON (visual mode)
keymap("v", "<leader>fj", ":!python3 -m json.tool<CR>", { desc = "Format JSON" })
