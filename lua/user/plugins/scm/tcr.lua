local M = {
   "tcr",
   dir = "~/.config/tcr",
   dependencies = {
      "nvim-lua/plenary.nvim",
   },
   -- Only load on Meta devserver
   cond = function()
      -- not ready to productionize
      -- return false
      local dotgk = require("init-utils.dotgk-wrapper").get()
      return dotgk.check "meta/devserver"
   end,
   config = function()
      require("tcr").setup {
         -- Configuration options
         diff = {
            split_ratio = 0.5,
            vertical = true,
         },
         comments = {
            virtual_text = true,
            max_length = 80,
            signs = true,
         },
      }
   end,
}

return M
