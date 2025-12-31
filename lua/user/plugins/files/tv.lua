return {
   "alexpasmantier/tv.nvim",
   lazy = false,
   -- Keybindings commented out - using Telescope for now
   -- Uncomment when ready to migrate from Telescope
   -- keys = {
   --    {
   --       "<leader>ff",
   --       function()
   --          require("tv").tv_channel "files"
   --       end,
   --       desc = "Find files",
   --    },
   --    {
   --       "<leader>fw",
   --       function()
   --          require("tv").tv_channel "text"
   --       end,
   --       desc = "Find word",
   --    },
   -- },
   config = function()
      local h = require("tv").handlers
      require("tv").setup {
         channels = {
            -- Channel configurations kept for manual use via :Tv command
            files = {
               handlers = {
                  ["<CR>"] = h.open_as_files,
                  ["<C-q>"] = h.send_to_quickfix,
               },
            },
            text = {
               handlers = {
                  ["<CR>"] = h.open_at_line,
                  ["<C-q>"] = h.send_to_quickfix,
               },
            },
         },
      }
   end,
}
