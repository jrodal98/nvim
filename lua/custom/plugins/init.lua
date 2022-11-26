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
    -- swap arguments
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
    config = function()
      require "custom.plugins.nvim-treesitter-textobjects"
    end,
  },
  -- A pretty list for showing diagnostics, references, telescope results, quickfix and location lists to help you solve all the trouble your code is causing.
  {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    after = "nvim-lspconfig",
    config = function()
      require("trouble").setup {}
    end,
  },
  {
    "rcarriga/nvim-notify",
    after = "nvim-lspconfig",
    config = function()
      require("notify").setup {
        background_colour = "#000000",
      }
      vim.notify = require "notify"
    end,
  },
  {
    "lvimuser/lsp-inlayhints.nvim",
    after = "nvim-lspconfig",
    config = function()
      require("lsp-inlayhints").setup()
      vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
      vim.api.nvim_create_autocmd("LspAttach", {
        group = "LspAttach_inlayhints",
        callback = function(args)
          if not (args.data and args.data.client_id) then
            return
          end

          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          require("lsp-inlayhints").on_attach(client, bufnr)
        end,
      })
    end,
  },
}
