-- Keymap discovery popup.
-- Individual mappings are documented by the `desc` on the mapping itself
-- (vim.keymap.set / lazy `keys`) — which-key picks those up automatically.
-- Only group names for leader prefixes need to be declared here.
return {
   "folke/which-key.nvim",
   event = "VeryLazy",
   opts = {
      preset = "modern",
      delay = function(ctx)
         return ctx.plugin and 0 or 500
      end,
      plugins = {
         marks = true,
         registers = true,
         spelling = {
            enabled = true,
            suggestions = 20,
         },
         presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
         },
      },
      win = {
         border = "rounded",
         padding = { 1, 2 },
      },
      icons = {
         breadcrumb = "»",
         separator = "→",
         group = "+",
         -- Disable nerd font icons since they don't render properly
         mappings = false,
         -- Use simple text-based icons for keys
         keys = {
            Up = "↑",
            Down = "↓",
            Left = "←",
            Right = "→",
            C = "Ctrl+",
            M = "Alt+",
            D = "Cmd+",
            S = "Shift+",
            CR = "Enter",
            Esc = "Esc",
            ScrollWheelDown = "ScrollDown",
            ScrollWheelUp = "ScrollUp",
            NL = "Enter",
            BS = "Backspace",
            Space = "Space",
            Tab = "Tab",
         },
      },
      spec = {
         { "<leader>a", group = "AI/Sidekick", mode = { "n", "x" } },
         { "<leader>c", group = "Code" },
         { "<leader>d", group = "Diagnostics" },
         { "<leader>f", group = "Find", mode = { "n", "v" } },
         { "<leader>g", group = "Git" },
         { "<leader>h", group = "Haunt (Bookmarks)" },
         { "<leader>l", group = "LSP" },
         -- <leader>n holds notification history plus "next textobject" motions
         { "<leader>n", group = "Notifications / Next object" },
         { "<leader>n", group = "Next object", mode = { "x", "o" } },
         -- <leader>p holds "previous textobject" motions
         { "<leader>p", group = "Previous object", mode = { "n", "x", "o" } },
         { "<leader>r", group = "Rename" },
         { "<leader>s", group = "Search/Substitute", mode = { "n", "v" } },
         { "<leader>t", group = "Terminal" },
         { "g", group = "Go to" },
         -- Created by toggleterm's open_mapping, which doesn't set a desc
         { "<C-\\>", desc = "Toggle terminal", mode = { "n", "t" } },
      },
   },
   keys = {
      {
         "<leader>?",
         function()
            require("which-key").show { global = false }
         end,
         desc = "Buffer keymaps (which-key)",
      },
      {
         "<leader>K",
         function()
            require("which-key").show { global = true }
         end,
         desc = "Show all keymaps (which-key)",
      },
   },
}
