local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
   PACKER_BOOTSTRAP = fn.system {
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
   }
   print "Installing packer close and reopen Neovim..."
   vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
   return
end

-- Have packer use a popup window
packer.init {
   display = {
      open_fn = function()
         return require("packer.util").float { border = "rounded" }
      end,
   },
   git = {
      clone_timeout = 300, -- Timeout, in seconds, for git clones
   },
}

-- Install your plugins here
return packer.startup(function(use)
   -- My plugins here
   use { "wbthomason/packer.nvim", commit = "6afb67460283f0e990d35d229fd38fdc04063e0a" } -- Have packer manage itself
   use { "nvim-lua/plenary.nvim", commit = "4b7e52044bbb84242158d977a50c4cbcd85070c7" } -- Useful lua functions used by lots of plugins
   use { "windwp/nvim-autopairs", commit = "4fc96c8f3df89b6d23e5092d31c866c53a346347" } -- Autopairs, integrates with both cmp and treesitter
   use { "numToStr/Comment.nvim", commit = "97a188a98b5a3a6f9b1b850799ac078faa17ab67" }

   use { "JoosepAlviste/nvim-ts-context-commentstring", commit = "32d9627123321db65a4f158b72b757bcaef1a3f4" }
   use { "kyazdani42/nvim-web-devicons", commit = "563f3635c2d8a7be7933b9e547f7c178ba0d4352" }
   use { "kyazdani42/nvim-tree.lua", commit = "7282f7de8aedf861fe0162a559fc2b214383c51c" }
   use { "akinsho/bufferline.nvim", commit = "83bf4dc7bff642e145c8b4547aa596803a8b4dc4" }
   use { "moll/vim-bbye", commit = "25ef93ac5a87526111f43e5110675032dbcacf56" } -- Bbye allows you to do delete buffers (close files) without closing your windows or messing up your layout.
   use { "nvim-lualine/lualine.nvim", commit = "a52f078026b27694d2290e34efa61a6e4a690621" }
   use { "akinsho/toggleterm.nvim", commit = "2a787c426ef00cb3488c11b14f5dcf892bbd0bda" }
   use { "ahmedkhalf/project.nvim", commit = "628de7e433dd503e782831fe150bb750e56e55d6" }
   use { "lewis6991/impatient.nvim", commit = "b842e16ecc1a700f62adb9802f8355b99b52a5a6" }
   use { "lukas-reineke/indent-blankline.nvim", commit = "db7cbcb40cc00fc5d6074d7569fb37197705e7f6" }
   use { "goolord/alpha-nvim", commit = "0bb6fc0646bcd1cdb4639737a1cee8d6e08bcc31" }

   -- Colorschemes
   use { "folke/tokyonight.nvim", commit = "66bfc2e8f754869c7b651f3f47a2ee56ae557764" }

   -- cmp plugins
   use { "hrsh7th/nvim-cmp", commit = "b0dff0ec4f2748626aae13f011d1a47071fe9abc" } -- The completion plugin
   use { "hrsh7th/cmp-buffer", commit = "3022dbc9166796b644a841a02de8dd1cc1d311fa" } -- buffer completions
   use { "hrsh7th/cmp-path", commit = "447c87cdd6e6d6a1d2488b1d43108bfa217f56e1" } -- path completions
   use { "saadparwaiz1/cmp_luasnip", commit = "a9de941bcbda508d0a45d28ae366bb3f08db2e36" } -- snippet completions
   use { "hrsh7th/cmp-nvim-lsp", commit = "affe808a5c56b71630f17aa7c38e15c59fd648a8" }
   use { "hrsh7th/cmp-nvim-lua", commit = "d276254e7198ab7d00f117e88e223b4bd8c02d21" }

   -- snippets
   use { "L3MON4D3/LuaSnip", commit = "8f8d493e7836f2697df878ef9c128337cbf2bb84" } --snippet engine
   use { "rafamadriz/friendly-snippets", commit = "2be79d8a9b03d4175ba6b3d14b082680de1b31b1" } -- a bunch of snippets to use

   -- LSP
   use { "neovim/nvim-lspconfig", commit = "f11fdff7e8b5b415e5ef1837bdcdd37ea6764dda" } -- enable LSP
   use { "williamboman/mason.nvim", commit = "c2002d7a6b5a72ba02388548cfaf420b864fbc12" }
   use { "williamboman/mason-lspconfig.nvim", commit = "0eb7cfefbd3a87308c1875c05c3f3abac22d367c" }
   use { "jose-elias-alvarez/null-ls.nvim", commit = "c0c19f32b614b3921e17886c541c13a72748d450" } -- for formatters and linters
   -- vscode lightbulb for code actions
   use {
      "kosayoda/nvim-lightbulb",
      commit = "56b9ce31ec9d09d560fe8787c0920f76bc208297",
      config = function()
         vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            callback = function()
               require("nvim-lightbulb").update_lightbulb()
            end,
         })
      end,
   }
   use {
      "lvimuser/lsp-inlayhints.nvim",
      commit = "439b4811276a149e3fccb226cc9a43ff2fb0e33b",
      config = function()
         require "user.lsp.inlayhints"
      end,
   }

   -- Telescope
   use { "nvim-telescope/telescope.nvim", commit = "76ea9a898d3307244dce3573392dcf2cc38f340f" }

   -- Treesitter
   use {
      "nvim-treesitter/nvim-treesitter",
      commit = "8e763332b7bf7b3a426fd8707b7f5aa85823a5ac",
   }
   -- rainbow parentheses
   use {
      "p00f/nvim-ts-rainbow",
      commit = "064fd6c0a15fae7f876c2c6dd4524ca3fad96750",
      after = "nvim-treesitter",
   }

   -- extra functionality, such as argument swapping and navigating functions,classes,conditionals,loops
   use {
      "nvim-treesitter/nvim-treesitter-textobjects",
      commit = "04c61332a3cb78e56f7455d17d7878b0b7e66270",
      after = "nvim-treesitter",
   }

   -- version control
   use {
      "lewis6991/gitsigns.nvim",
      commit = "f98c85e7c3d65a51f45863a34feb4849c82f240f",
      config = function()
         require "user.gitsigns"
      end,
   }

   use {
      "mhinz/vim-signify",
      commit = "8bc268c79d4053c2f5ccaadcf0b666dd16ed3a58",
      config = function()
         vim.cmd [[ let g:signify_skip = { 'vcs': { 'allow': ['hg'] } }
      ]]
      end,
   }

   -- DAP
   use { "mfussenegger/nvim-dap", commit = "6b12294a57001d994022df8acbe2ef7327d30587" }
   use { "rcarriga/nvim-dap-ui", commit = "1cd4764221c91686dcf4d6b62d7a7b2d112e0b13" }
   use { "ravenxrz/DAPInstall.nvim", commit = "8798b4c36d33723e7bba6ed6e2c202f84bb300de" }

   -- better cut-delete-copy-paste logic
   use { "svermeulen/vim-cutlass", commit = "7afd649415541634c8ce317fafbc31cd19d57589" }
   -- surround words and such
   use {
      "kylechui/nvim-surround",
      commit = "6b45fbffdabb2d8cd80d310006c92e59cec8fd74",
      config = function()
         require("nvim-surround").setup {}
      end,
   }
   -- motion plugin (move with s)
   use {
      "ggandor/lightspeed.nvim",
      commit = "299eefa6a9e2d881f1194587c573dad619fdb96f",
   }

   -- better repeat logic (e.g. hit . to repeat some commands)
   use {
      "tpope/vim-repeat",
      commit = "24afe922e6a05891756ecf331f39a1f6743d3d5a",
   }

   -- better increment/decrement logic
   use {
      "monaqa/dial.nvim",
      commit = "9ba17c2ee636a8e7fdef5b69d6aac54dd26f4384",
   }

   -- yank with osc, which allows yanking from remote machines
   use {
      "ojroques/vim-oscyank",
      commit = "e6298736a7835bcb365dd45a8e8bfe86d935c1f8",
   }

   -- copy vim statusline into tmux statusline
   use {
      "vimpostor/vim-tpipeline",
      commit = "776026d7311001495095f0b49dd2f0ebf33c3604",
      -- disable if tmux is not running
      cond = function()
         -- there has to be a less stupid way to do this,
         -- but calling if vim.fn.system... wasn't working
         -- no matter what I tried - I think it didn't capture output
         return vim.api.nvim_exec(
            [[
          if system('pgrep tmux')
            " prevent statusline duplication when tmux is running
            autocmd BufRead,BufNewFile,BufEnter,BufWinEnter * set laststatus=0
            echo v:true
          else
            " set global statusline otherwise
            autocmd BufRead,BufNewFile,BufEnter,BufWinEnter * set laststatus=3
            echo v:false
          endif
         ]],
            -- capture the output
            true
         )
      end,
   }

   use {
      "folke/trouble.nvim",
      commit = "897542f90050c3230856bc6e45de58b94c700bbf",
      requires = "kyazdani42/nvim-web-devicons",
      after = "nvim-lspconfig",
      config = function()
         require("trouble").setup {}
      end,
   }
   use {
      "rcarriga/nvim-notify",
      commit = "e7cffd0e8c3beaa0df7d06567620afa964bc2963",
      config = function()
         require("notify").setup {
            background_colour = "#000000",
         }
         vim.notify = require "notify"
      end,
   }

   -- UI for LSP progress
   use {
      "j-hui/fidget.nvim",
      commit = "44585a0c0085765195e6961c15529ba6c5a2a13b",
      config = function()
         require("fidget").setup {
            window = {
               blend = 0, -- make it transparent
            },
         }
      end,
   }

   -- Automatically set up your configuration after cloning packer.nvim
   -- Put this at the end after all plugins
   if PACKER_BOOTSTRAP then
      require("packer").sync()
   end
end)
