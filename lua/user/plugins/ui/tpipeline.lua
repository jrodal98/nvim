-- ehh. I'm not sure that I want this plugin anymore, so let's disable it for
-- now.
local enable = false
local is_tmux_running = enable and vim.fn.system("pgrep tmux"):match "%S" ~= nil

local M = {
   "vimpostor/vim-tpipeline",
   event = { "CursorMoved", "ModeChanged" },
   cond = is_tmux_running,
   config = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufEnter", "BufWinEnter" }, {
         pattern = "*",
         callback = function()
            vim.opt.laststatus = 0
         end,
      })
   end,
}

return M
