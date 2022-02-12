return {
   {
      -- smooth scrolling
      "karb94/neoscroll.nvim",
      opt = true,
      config = function()
         require("neoscroll").setup()
      end,

      -- lazy loading
      setup = function()
         require("core.utils").packer_lazy_load "neoscroll.nvim"
      end,
   },

   {
      -- add, change, and replace surroundings
      "blackCauldron7/surround.nvim",
      config = function()
         require("surround").setup { mappings_style = "surround" }
      end,
   },

   {
      -- sane copy-paste logic
      "svermeulen/vim-cutlass",
      event = "BufRead",
   },

   {
      -- lsp-like things (formatting, linting, diagnostics)
      "jose-elias-alvarez/null-ls.nvim",
      after = "nvim-lspconfig",
      config = function()
         require("custom.plugins.null-ls").setup()
      end,
   },

   {
      -- motion plugin (move with s)
      "ggandor/lightspeed.nvim",
   },

   {
      -- better repeat logic (e.g. hit . to repeat some commands)
      "tpope/vim-repeat",
      event = "BufRead",
   },
}
