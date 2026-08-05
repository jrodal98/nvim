local M = {
   "folke/trouble.nvim",
   event = { "BufReadPre", "BufNewFile" },
   opts = {},
   cmd = "Trouble",
   dependencies = { "nvim-tree/nvim-web-devicons" },
}

return M
