return {
   "TheNoeTrevino/haunt.nvim",
   ---@class HauntConfig
   opts = {
      sign = "󱙝",
      sign_hl = "DiagnosticInfo",
      virt_text_hl = "HauntAnnotation", -- links to DiagnosticVirtualTextHint
      annotation_prefix = " 󰆉 ",
      annotation_suffix = "",
      line_hl = nil,
      virt_text_pos = "eol",
      data_dir = nil,
      per_branch_bookmarks = true,
      picker = "snacks", -- Use snacks since you have it configured
      picker_keys = {
         delete = { key = "d", mode = { "n" } },
         edit_annotation = { key = "a", mode = { "n" } },
      },
   },
   keys = {
      -- Annotations
      {
         "<leader>ha",
         function()
            require("haunt.api").annotate()
         end,
         desc = "Haunt: Annotate line",
      },
      {
         "<leader>ht",
         function()
            require("haunt.api").toggle_annotation()
         end,
         desc = "Haunt: Toggle annotation",
      },
      {
         "<leader>hT",
         function()
            require("haunt.api").toggle_all_lines()
         end,
         desc = "Haunt: Toggle all annotations",
      },
      {
         "<leader>hd",
         function()
            require("haunt.api").delete()
         end,
         desc = "Haunt: Delete bookmark",
      },
      {
         "<leader>hC",
         function()
            require("haunt.api").clear_all()
         end,
         desc = "Haunt: Clear all bookmarks",
      },
      -- Navigation
      {
         "<leader>hp",
         function()
            require("haunt.api").prev()
         end,
         desc = "Haunt: Previous bookmark",
      },
      {
         "<leader>hn",
         function()
            require("haunt.api").next()
         end,
         desc = "Haunt: Next bookmark",
      },
      -- Picker
      {
         "<leader>hl",
         function()
            require("haunt.picker").show()
         end,
         desc = "Haunt: Show picker",
      },
      -- Quickfix
      {
         "<leader>hq",
         function()
            require("haunt.api").to_quickfix { current_buffer = true }
         end,
         desc = "Haunt: Send to quickfix (buffer)",
      },
      {
         "<leader>hQ",
         function()
            require("haunt.api").to_quickfix()
         end,
         desc = "Haunt: Send to quickfix (all)",
      },
      -- Yank locations
      {
         "<leader>hy",
         function()
            require("haunt.api").yank_locations { current_buffer = true }
         end,
         desc = "Haunt: Yank locations (buffer)",
      },
      {
         "<leader>hY",
         function()
            require("haunt.api").yank_locations()
         end,
         desc = "Haunt: Yank locations (all)",
      },
   },
}
