local map = require("core.utils").map

-- formatting
map("n", "<leader>fm", "<cmd>lua vim.lsp.buf.format{async=true}<CR>")
-- additional code action binding (on my corne keyboard, this is lower-c)
map("n", "<F3>", "<cmd>lua vim.lsp.buf.code_action()<CR>")

-- cutlass
-- next four map x to d.
map("n", "x", "d", { noremap = true })
map("x", "x", "d", { noremap = true })
map("n", "xx", "dd", { noremap = true })
map("n", "X", "D", { noremap = true })

-- window resize logic
map("n", "<Up>", ":resize +1<CR>")
map("n", "<Down>", ":resize -1<CR>")
map("n", "<left>", ":vertical resize -1<CR>")
map("n", "<right>", ":vertical resize +1<CR>")

-- line navigation
map("n", "H", "^") -- go to first char in line easier
map("n", "L", "$") -- go to last char in line easier
map("v", "J", ":m '>+1<CR>gv=gv") -- move visual selection up
map("v", "K", ":m '<-2<CR>gv=gv") -- move visual selection down

-- word substitution
map("n", "<leader>so", "*cgn", { noremap = false }) -- substitute word "once". Dot repeat to replace next match
map("n", "<leader>sw", ':%s/<C-r>=expand("<cword>")<CR>//g<left><left>') -- subtitute word everywhere
map("v", "<leader>sw", '"hy:%s/<C-r>h//g<left><left>') -- substitute word everwhere (visual mode)

-- misc
map("n", "*", "m`:keepjumps normal! *``<cr>") -- don't jump to next word when matching with *
map("n", "<leader>sc", ":setlocal spell! spelllang=en_us<CR>") -- spellcheck
