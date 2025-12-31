local M = {
   "akinsho/toggleterm.nvim",
   keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", mode = "n", noremap = true, silent = true },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", mode = "n", noremap = true, silent = true },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", mode = "n", noremap = true, silent = true },
      { "<leader>tt", "<cmd>ToggleTerm direction=tab<cr>", mode = "n", noremap = true, silent = true },
      { "<leader>tp", "<cmd>lua _PYTHON_TOGGLE()<cr>", mode = "n", noremap = true, silent = true },
   },
   cmd = {
      "ToggleTerm",
      "ToggleTermToggleAll",
      "ToggleTermSendCurrentLine",
      "ToggleTermSendVisualSelection",
      "ToggleTermSendVisualLine",
      "ToggleTermSetName",
   },
}

function M.config()
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

   local Terminal = require("toggleterm.terminal").Terminal

   local python_cmd = "python3"
   local ok, python_provider = pcall(require, "meta-private.python-cmd")
   if ok then
      local meta_python = python_provider.get()
      if meta_python then
         python_cmd = meta_python
      end
   end
   local python = Terminal:new { cmd = python_cmd, hidden = true }

   function _PYTHON_TOGGLE()
      python:toggle()
   end
end

return M
