local M = {
   "folke/tokyonight.nvim",
   lazy = false, -- make sure we load this during startup if it is your main colorscheme
   priority = 1000, -- make sure to load this before all the other start plugins
}

function M.config()
   require("tokyonight").setup {
      transparent = true,
   }
   vim.cmd.colorscheme "tokyonight-night"

   -- Remove grey background from inlay hints
   vim.cmd [[highlight! link LspInlayHint Comment]]
end

return M
