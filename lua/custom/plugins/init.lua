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
      "tpope/vim-surround",
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

   -- vscode lightbulb for code actions
   {
      "kosayoda/nvim-lightbulb",
      after = "nvim-lspconfig",
      config = function()
         vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]
      end,
   },

   {
      -- better increment/decrement logic
      "monaqa/dial.nvim",
      event = "BufRead",
      config = function()
         require "custom.plugins.dial"
      end,
   },
   -- uses the sign column to indicate added, modified and removed lines
   -- in a file that is managed by a version control system
   {
      "mhinz/vim-signify",
      event = "BufRead",
      config = function()
         require "custom.plugins.signify"
      end,
   },
   {
      "jbyuki/venn.nvim",
      event = "BufRead",
      config = function()
         require "custom.plugins.venn"
      end,
   },
}
