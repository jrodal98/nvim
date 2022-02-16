local map = require("core.utils").map

-- formatting
map("n", "<leader>fm", "<cmd>lua vim.lsp.buf.formatting()<CR>")

-- cutlass
-- next four map x to d.
map("n", "x", "d", { noremap = true })
map("x", "x", "d", { noremap = true })
map("n", "xx", "dd", { noremap = true })
map("n", "X", "D", { noremap = true })

-- window management
-- resize logic
map("n", "<Up>", ":resize +1<CR>")
map("n", "<Down>", ":resize -1<CR>")
map("n", "<left>", ":vertical resize -1<CR>")
map("n", "<right>", ":vertical resize +1<CR>")

-- misc
map("n", "*", "m`:keepjumps normal! *``<cr>") -- don't jump to next word when matching with *
map("n", "<leader>sw", "*cgn", { noremap = false }) -- substitute word
map("n", "<leader>sc", ":setlocal spell! spelllang=en_us<CR>") -- spellcheck
