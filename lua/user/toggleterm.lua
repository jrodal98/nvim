local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
   return
end

toggleterm.setup {
   size = 20,
   open_mapping = [[<c-\>]],
   hide_numbers = true,
   shade_filetypes = {},
   shade_terminals = true,
   shading_factor = 2,
   start_in_insert = true,
   insert_mappings = true,
   persist_size = true,
   direction = "float",
   close_on_exit = true,
   shell = vim.o.shell,
   float_opts = {
      border = "curved",
      winblend = 0,
      highlights = {
         border = "Normal",
         background = "Normal",
      },
   },
}

function _G.set_terminal_keymaps()
   local opts = { noremap = true }
   vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
end

vim.cmd "autocmd! TermOpen term://* lua set_terminal_keymaps()"

local Terminal = require("toggleterm.terminal").Terminal

local python = Terminal:new { cmd = "python3", hidden = true }

function _PYTHON_TOGGLE()
   python:toggle()
end
