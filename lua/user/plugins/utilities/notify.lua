local M = {
   "rcarriga/nvim-notify",
   event = "VeryLazy",
}

function M.config()
   local notify = require "notify"

   notify.setup {
      background_colour = "#000000",
      render = "default",
      on_open = function(win)
         vim.api.nvim_win_set_config(win, { zindex = 500 })
      end,
   }

   local ignored_messages = {
      "warning: multiple different client offset_encodings detected for buffer, this is not supported yet",
      "No code actions available",
      "method textDocument/codeAction is not supported by any of the servers registered for the current buffer",
      "completion request failed",
      "position_encoding param is required in vim.lsp.util.make_range_params. Defaulting to position encoding of the first client.",
      "warning: multiple different client offset_encodings detected for buffer, vim.lsp.util._get_offset_encoding() uses the offset_encoding from the first client",
   }

   vim.notify = function(msg, lvl, opts)
      lvl = lvl or vim.log.levels.INFO
      if vim.tbl_contains(ignored_messages, msg) then
         return
      end
      local lvls = vim.log.levels
      local keep = function()
         return true
      end
      local _opts = ({
         [lvls.TRACE] = { timeout = 500 },
         [lvls.DEBUG] = { timeout = 500 },
         [lvls.INFO] = { timeout = 1000 },
         [lvls.WARN] = { timeout = 10000 },
         [lvls.ERROR] = { timeout = 10000, keep = keep },
      })[lvl]
      opts = vim.tbl_extend("force", _opts or {}, opts or {})
      return notify.notify(msg, lvl, opts)
   end

   -- Keymaps
   local keymap = vim.keymap.set
   local opts = { noremap = true, silent = true }
   keymap("n", "<Esc>", function()
      require("notify").dismiss() -- clear notifications
      vim.cmd.nohlsearch() -- clear highlights
      vim.cmd.echo() -- clear short-message
      vim.cmd.helpclose() -- close vim help pages
   end, opts)
end

return M
