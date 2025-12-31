return {
   "nvim-telescope/telescope.nvim",
   cmd = "Telescope",
   keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", desc = "Find all files" },
      { "<leader>fo", "<cmd>Telescope oldfiles<CR>", desc = "Find recent files" },
      { "<leader>fw", "<cmd>Telescope live_grep<CR>", desc = "Find word" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
   },
   config = function()
      local telescope = require "telescope"
      local actions = require "telescope.actions"

      telescope.setup {
         defaults = {
            prompt_prefix = " ",
            selection_caret = " ",
            path_display = { "smart" },
            file_ignore_patterns = { ".git/", "node_modules" },
            sorting_strategy = "ascending",
            layout_strategy = "horizontal",
            layout_config = {
               horizontal = {
                  prompt_position = "top",
                  preview_width = 0.55,
                  results_width = 0.8,
               },
               vertical = {
                  mirror = false,
               },
               width = 0.87,
               height = 0.80,
               preview_cutoff = 120,
            },
            mappings = {
               i = {
                  ["<Down>"] = actions.cycle_history_next,
                  ["<Up>"] = actions.cycle_history_prev,
                  ["<C-n>"] = actions.move_selection_next,
                  ["<C-p>"] = actions.move_selection_previous,
               },
            },
         },
      }
   end,
}
