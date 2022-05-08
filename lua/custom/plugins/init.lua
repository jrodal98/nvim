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
      -- rainbow parentheses
      "p00f/nvim-ts-rainbow",
      after = "nvim-treesitter",
   },
   -- yank with osc, which allows yanking from remote machines
   {
      "ojroques/vim-oscyank",
      config = function()
         require("core.utils").map("v", "<leader>y", ":OSCYank <CR>")
      end,
      event = "BufRead",
   },
   -- copy vim statusline into tmux statusline
   {
      "vimpostor/vim-tpipeline",
      -- disable if tmux is not installed
      disable=not vim.fn.executable("tmux"),
      config = function()
         vim.cmd [[
          if system('pgrep tmux')
            " prevent statusline duplication when tmux is running
            autocmd BufRead,BufNewFile,BufEnter,BufWinEnter * set laststatus=0
          else
            " set global statusline otherwise
            autocmd BufRead,BufNewFile,BufEnter,BufWinEnter * set laststatus=3
          endif
        ]]
      end,
   },
   {
      -- swap arguments
      "nvim-treesitter/nvim-treesitter-textobjects",
      after = "nvim-treesitter",
      config = function()
         require "custom.plugins.nvim-treesitter-textobjects"
      end,
   },
}
