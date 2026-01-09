return {
   "folke/snacks.nvim",
   priority = 1000,
   lazy = false,
   ---@type snacks.Config
   opts = {
      bigfile = { enabled = true },
      bufdelete = { enabled = true },
      explorer = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      picker = { enabled = true },
      quickfile = { enabled = true },
      lazygit = { enabled = true },
   },
   keys = {
      -- Buffer delete
      {
         "<leader>x",
         function()
            Snacks.bufdelete()
         end,
         desc = "Delete buffer",
      },

      -- Explorer
      {
         "<leader>e",
         function()
            Snacks.explorer()
         end,
         desc = "File explorer",
      },

      -- File finding (matches previous telescope keymaps)
      {
         "<leader>ff",
         function()
            Snacks.picker.files()
         end,
         desc = "Find files",
      },
      {
         "<leader>fa",
         function()
            Snacks.picker.files { hidden = true, ignored = true }
         end,
         desc = "Find all files",
      },
      {
         "<leader>fo",
         function()
            Snacks.picker.recent()
         end,
         desc = "Find recent files",
      },
      {
         "<leader>fw",
         function()
            Snacks.picker.grep()
         end,
         desc = "Find word (grep)",
      },
      {
         "<leader>fb",
         function()
            Snacks.picker.buffers()
         end,
         desc = "Find buffers",
      },

      -- Additional useful pickers
      {
         "<leader>fc",
         function()
            Snacks.picker.files { cwd = vim.fn.stdpath "config" }
         end,
         desc = "Find config file",
      },
      {
         "<leader>fg",
         function()
            Snacks.picker.git_files()
         end,
         desc = "Find git files",
      },
      {
         "<leader>fh",
         function()
            Snacks.picker.help()
         end,
         desc = "Find help",
      },
      {
         "<leader>fk",
         function()
            Snacks.picker.keymaps()
         end,
         desc = "Find keymaps",
      },

      -- Git
      {
         "<leader>gb",
         function()
            Snacks.picker.git_branches()
         end,
         desc = "Git branches",
      },
      {
         "<leader>gl",
         function()
            Snacks.picker.git_log()
         end,
         desc = "Git log",
      },
      {
         "<leader>gs",
         function()
            Snacks.picker.git_status()
         end,
         desc = "Git status",
      },

      -- LSP
      {
         "gd",
         function()
            Snacks.picker.lsp_definitions()
         end,
         desc = "Goto definition",
      },
      {
         "gD",
         function()
            Snacks.picker.lsp_declarations()
         end,
         desc = "Goto declaration",
      },
      {
         "gr",
         function()
            Snacks.picker.lsp_references()
         end,
         nowait = true,
         desc = "References",
      },
      {
         "gI",
         function()
            Snacks.picker.lsp_implementations()
         end,
         desc = "Goto implementation",
      },
      {
         "gy",
         function()
            Snacks.picker.lsp_type_definitions()
         end,
         desc = "Goto type definition",
      },

      -- Diagnostics
      {
         "<leader>dd",
         function()
            Snacks.picker.diagnostics()
         end,
         desc = "Diagnostics",
      },
      {
         "<leader>db",
         function()
            Snacks.picker.diagnostics_buffer()
         end,
         desc = "Buffer diagnostics",
      },
   },
   init = function()
      -- Dismiss notifications on Esc
      vim.keymap.set("n", "<Esc>", function()
         Snacks.notifier.hide()
         vim.cmd.nohlsearch()
         vim.cmd.echo()
      end, { desc = "Clear notifications and highlights" })
   end,
}
