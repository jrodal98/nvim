-- Automatically install lazy.nvim

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
   vim.fn.system {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
   }
end
vim.opt.rtp:prepend(lazypath)

local hostname = vim.fn.hostname()
local is_meta = (
   hostname == "jrodal-mbp"
   or hostname == "jrodal-850"
   or hostname == "jrodal-257"
   or hostname == "PW08WPZH"
)

local Event = require "lazy.core.handler.event"
Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
Event.mappings["User LazyFile"] = Event.mappings.LazyFile

return require("lazy").setup({
   { "nvim-lua/plenary.nvim" }, -- Useful lua functions used by lots of plugins
   { "windwp/nvim-autopairs", event = "LazyFile" }, -- Autopairs, integrates with both cmp and treesitter
   { "numToStr/Comment.nvim" },

   { "kyazdani42/nvim-web-devicons", lazy = true },
   { "kyazdani42/nvim-tree.lua" },
   { "akinsho/bufferline.nvim" },
   { "moll/vim-bbye", event = "LazyFile" }, -- Bbye allows you to do delete buffers (close files) without closing your windows or messing up your layout.
   { "nvim-lualine/lualine.nvim" },
   { "akinsho/toggleterm.nvim" },
   { "lewis6991/impatient.nvim", lazy = false },
   { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {}, event = "LazyFile" },
   { "goolord/alpha-nvim", event = "VimEnter" },

   -- Colorschemes
   {
      "folke/tokyonight.nvim",
      lazy = false, -- make sure we load this during startup if it is your main colorscheme
      priority = 1000, -- make sure to load this before all the other start plugins
      config = function()
         -- load the colorscheme here
         vim.cmd [[colorscheme tokyonight]]
      end,
   },

   -- cmp plugins
   {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
         { "hrsh7th/cmp-buffer", event = "InsertEnter" }, -- buffer completions
         { "hrsh7th/cmp-path", event = "InsertEnter" }, -- path completions
         { "saadparwaiz1/cmp_luasnip", event = "InsertEnter" }, -- snippet completions
         { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
         { "hrsh7th/cmp-nvim-lua", event = "InsertEnter" },
         { "hrsh7th/cmp-cmdline", event = "InsertEnter" },
      },
   },

   -- codeium
   {
      "Exafunction/codeium.nvim",
      enabled = not is_meta,
      dependencies = {
         "nvim-lua/plenary.nvim",
         "hrsh7th/nvim-cmp",
      },
      event = "InsertEnter",
      config = function()
         require("codeium").setup {}
      end,
   },
   -- snippets
   { "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" } }, --snippet engine

   -- LSP
   {
      "neovim/nvim-lspconfig",
      event = "LazyFile",
      dependencies = {

         { "williamboman/mason.nvim" },
         { "williamboman/mason-lspconfig.nvim" },
         {
            "lvimuser/lsp-inlayhints.nvim",
            config = function()
               require "user.lsp.inlayhints"
            end,
         },
      },
   }, -- enable LSP
   { "jose-elias-alvarez/null-ls.nvim", event = "LazyFile" }, -- for formatters and linters
   -- vscode lightbulb for code actions
   {
      "kosayoda/nvim-lightbulb",
      event = "LazyFile",
      config = function()
         vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            callback = function()
               require("nvim-lightbulb").update_lightbulb()
            end,
         })
      end,
   },
   -- Telescope
   { "nvim-telescope/telescope.nvim" },

   -- Treesitter
   {
      "nvim-treesitter/nvim-treesitter",
      event = "LazyFile",
      dependencies = {
         -- extra functionality, such as argument swapping and navigating functions,classes,conditionals,loops
         { "nvim-treesitter/nvim-treesitter-textobjects" },
      },
   },

   -- version control
   {
      "lewis6991/gitsigns.nvim",
      event = "LazyFile",
      config = function()
         require "user.gitsigns"
      end,
   },

   {
      "mhinz/vim-signify",
      event = "LazyFile",
      config = function()
         vim.cmd [[ let g:signify_skip = { 'vcs': { 'allow': ['hg'] } }
      ]]
      end,
   },

   {
      "akinsho/git-conflict.nvim",
      event = "LazyFile",
      opts = {},
   },

   -- DAP
   { "mfussenegger/nvim-dap" },
   { "rcarriga/nvim-dap-ui" },
   { "ravenxrz/DAPInstall.nvim" },

   -- better cut-delete-copy-paste logic
   { "svermeulen/vim-cutlass", event = "LazyFile" },
   -- surround words and such
   {
      "kylechui/nvim-surround",
      opts = {},
      event = "LazyFile",
   },
   -- motion plugin (move with s)
   {
      "ggandor/lightspeed.nvim",
      lazy = false,
   },

   -- better repeat logic (e.g. hit . to repeat some commands)
   {
      "tpope/vim-repeat",
      event = "LazyFile",
   },

   -- better increment/decrement logic
   {
      "monaqa/dial.nvim",
      event = "LazyFile",
   },

   -- yank with osc, which allows yanking from remote machines
   {
      "ojroques/vim-oscyank",
      config = function()
         -- Execute OSCYankReg on any yank
         vim.cmd [[
        autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankRegister "' | endif
      ]]
      end,
      event = "LazyFile",
   },

   -- copy vim statusline into tmux statusline
   {
      "vimpostor/vim-tpipeline",
      lazy = false,
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
   },

   {
      "folke/trouble.nvim",
      event = "LazyFile",
      dependencies = { "kyazdani42/nvim-web-devicons" },
   },
   {
      "rcarriga/nvim-notify",
      config = function()
         require("notify").setup {
            background_colour = "#000000",
         }
         vim.notify = require "notify"
      end,
   },

   -- UI for LSP progress
   {
      "j-hui/fidget.nvim",
      event = "LazyFile",
   },
}, { defaults = { lazy = true } })
