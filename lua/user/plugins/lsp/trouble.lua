local M = {
   "folke/trouble.nvim",
   event = { "BufReadPre", "BufNewFile" },
   opts = {},
   cmd = "Trouble",
   dependencies = { "kyazdani42/nvim-web-devicons" },
}

return M
