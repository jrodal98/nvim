return {
   "nvim-treesitter/nvim-treesitter",
   branch = "master",
   event = { "BufReadPre", "BufNewFile" },
   build = ":TSUpdate",
   dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
   },
   config = function()
      local configs = require "nvim-treesitter.configs"
      local install = require "nvim-treesitter.install"

      -- Configure treesitter parsers
      configs.setup {
         ensure_installed = {
            "bash",
            "cpp",
            "css",
            "dockerfile",
            "hack",
            "html",
            "json",
            "lua",
            "markdown",
            "php",
            "python",
            "rust",
            "toml",
            "vim",
            "yaml",
         },
         sync_install = false,
         ignore_install = {},
         highlight = {
            enable = not vim.g.vscode,
            disable = {},
         },
         autopairs = {
            enable = not vim.g.vscode,
         },
         indent = {
            enable = not vim.g.vscode,
            disable = {},
         },
         textobjects = {
            select = {
               enable = true,
               lookahead = true,
               keymaps = {
                  ["af"] = "@function.outer",
                  ["if"] = "@function.inner",
                  ["ac"] = "@class.outer",
                  ["ic"] = "@class.inner",
                  ["ai"] = "@conditional.outer",
                  ["ii"] = "@conditional.inner",
                  ["al"] = "@loop.outer",
                  ["il"] = "@loop.inner",
               },
            },
            swap = {
               enable = true,
               swap_next = {
                  ["<leader>j"] = "@parameter.inner",
               },
               swap_previous = {
                  ["<leader>k"] = "@parameter.inner",
               },
            },
            move = {
               enable = true,
               set_jumps = true,
               goto_next_start = {
                  ["<leader>nf"] = "@function.outer",
                  ["<leader>nc"] = "@class.outer",
                  ["<leader>ni"] = "@conditional.outer",
                  ["<leader>nl"] = "@loop.outer",
               },
               goto_next_end = {
                  ["<leader>nF"] = "@function.outer",
                  ["<leader>nC"] = "@class.outer",
                  ["<leader>nI"] = "@conditional.outer",
                  ["<leader>nL"] = "@loop.outer",
               },
               goto_previous_start = {
                  ["<leader>pf"] = "@function.outer",
                  ["<leader>pc"] = "@class.outer",
                  ["<leader>pi"] = "@conditional.outer",
                  ["<leader>pl"] = "@loop.outer",
               },
               goto_previous_end = {
                  ["<leader>pF"] = "@function.outer",
                  ["<leader>pC"] = "@class.outer",
                  ["<leader>pI"] = "@conditional.outer",
                  ["<leader>pL"] = "@loop.outer",
               },
            },
         },
      }

      -- Installation settings
      install.prefer_git = true
      local ok, ts_install_args = pcall(require, "meta-private.treesitter.install-args")
      if ok then
         local args = ts_install_args.get()
         if args then
            install.command_extra_args = args
         end
      end
   end,
}
