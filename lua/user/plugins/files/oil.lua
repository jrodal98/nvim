return {
   "stevearc/oil.nvim",
   opts = {},
   config = function()
      require("oil").setup {
         columns = {
            "icon",
         },
         keymaps = {
            ["g?"] = { "actions.show_help", mode = "n" },
            ["<CR>"] = "actions.select",
            ["<C-s>"] = { "actions.select", opts = { vertical = true } },
            ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
            ["<C-t>"] = { "actions.select", opts = { tab = true } },
            ["<C-p>"] = "actions.preview",
            ["<C-c>"] = { "actions.close", mode = "n" },
            ["<C-l>"] = "actions.refresh",
            ["-"] = { "actions.parent", mode = "n" },
            ["_"] = { "actions.open_cwd", mode = "n" },
            ["`"] = { "actions.cd", mode = "n" },
            -- ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
            ["~"] = false, -- Interferes with changing cases
            ["gs"] = { "actions.change_sort", mode = "n" },
            ["gx"] = "actions.open_external",
            ["g."] = { "actions.toggle_hidden", mode = "n" },
            ["g\\"] = { "actions.toggle_trash", mode = "n" },
         },
      }
      -- note, I also have some config in cmp.lua - not sure if that's the
      -- best home for it, but it will do for now.
      -- cmp.lua reference: https://github.com/Exafunction/windsurf.nvim/issues/277#issuecomment-2867762247
   end,
   lazy = false,
}
