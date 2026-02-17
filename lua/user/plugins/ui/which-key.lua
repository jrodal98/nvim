return {
   "folke/which-key.nvim",
   event = "VeryLazy",
   opts = {
      preset = "modern",
      delay = function(ctx)
         return ctx.plugin and 0 or 200
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
         -- ========================================
         -- Leader key groups
         -- ========================================
         { "<leader>w", desc = "Save file" },
         { "<leader>E", desc = "Open Oil file explorer" },
         { "<leader>e", desc = "File explorer (Snacks)" },
         { "<leader>x", desc = "Delete buffer" },
         { "<leader><space>", desc = "Toggle fold" },

         -- ========================================
         -- AI / Sidekick group
         -- ========================================
         { "<leader>a", group = "AI/Sidekick" },
         { "<leader>aa", desc = "Toggle CLI" },
         { "<leader>as", desc = "Select CLI" },
         { "<leader>ac", desc = "Toggle Claude" },
         { "<leader>at", desc = "Send this", mode = { "n", "x" } },
         { "<leader>af", desc = "Send file" },
         { "<leader>av", desc = "Send visual selection", mode = { "x" } },
         { "<leader>ap", desc = "Select prompt", mode = { "n", "x" } },
         { "<leader>ad", desc = "Detach CLI session" },

         -- ========================================
         -- Code actions group
         -- ========================================
         { "<leader>c", group = "Code" },
         { "<leader>ca", desc = "Code action" },

         -- ========================================
         -- Diagnostics group
         -- ========================================
         { "<leader>d", group = "Diagnostics" },
         { "<leader>dd", desc = "Diagnostics (workspace)" },
         { "<leader>db", desc = "Buffer diagnostics" },

         -- ========================================
         -- Find/Search group
         -- ========================================
         { "<leader>f", group = "Find" },
         { "<leader>ff", desc = "Find files" },
         { "<leader>fa", desc = "Find all files (hidden)" },
         { "<leader>fo", desc = "Find recent files" },
         { "<leader>fw", desc = "Find word (grep)" },
         { "<leader>fb", desc = "Find buffers" },
         { "<leader>fc", desc = "Find config files" },
         { "<leader>fg", desc = "Find git files" },
         { "<leader>fh", desc = "Find help" },
         { "<leader>fk", desc = "Find keymaps" },
         { "<leader>fj", desc = "Format JSON", mode = "v" },

         -- ========================================
         -- Git group
         -- ========================================
         { "<leader>g", group = "Git" },
         { "<leader>gb", desc = "Git branches" },
         { "<leader>gl", desc = "Git log" },
         { "<leader>gs", desc = "Git status" },

         -- ========================================
         -- Haunt/Bookmarks group
         -- ========================================
         { "<leader>h", group = "Haunt (Bookmarks)" },
         { "<leader>ha", desc = "Annotate line" },
         { "<leader>ht", desc = "Toggle annotation" },
         { "<leader>hT", desc = "Toggle all annotations" },
         { "<leader>hd", desc = "Delete bookmark" },
         { "<leader>hC", desc = "Clear all bookmarks" },
         { "<leader>hp", desc = "Previous bookmark" },
         { "<leader>hn", desc = "Next bookmark" },
         { "<leader>hl", desc = "Show picker" },
         { "<leader>hq", desc = "Send to quickfix (buffer)" },
         { "<leader>hQ", desc = "Send to quickfix (all)" },
         { "<leader>hy", desc = "Yank locations (buffer)" },
         { "<leader>hY", desc = "Yank locations (all)" },

         -- ========================================
         -- LSP group
         -- ========================================
         { "<leader>l", group = "LSP" },
         { "<leader>li", desc = "LSP info" },
         { "<leader>ls", desc = "Signature help" },
         { "<leader>lq", desc = "Diagnostics to loclist" },

         -- ========================================
         -- Rename group
         -- ========================================
         { "<leader>r", group = "Rename" },
         { "<leader>rn", desc = "Rename symbol" },

         -- ========================================
         -- Search/Substitute group
         -- ========================================
         { "<leader>s", group = "Search/Substitute" },
         { "<leader>so", desc = "Substitute word once (repeat with .)" },
         { "<leader>sw", desc = "Substitute word globally", mode = { "n", "v" } },
         { "<leader>sc", desc = "Toggle spellcheck" },

         -- ========================================
         -- Terminal group
         -- ========================================
         { "<leader>t", group = "Terminal" },
         { "<leader>tf", desc = "Toggle float terminal" },
         { "<leader>th", desc = "Toggle horizontal terminal" },
         { "<leader>tv", desc = "Toggle vertical terminal" },
         { "<leader>tt", desc = "Toggle tab terminal" },
         { "<leader>tp", desc = "Toggle Python REPL" },

         -- ========================================
         -- Format group
         -- ========================================
         { "<leader>fm", desc = "Format buffer" },

         -- ========================================
         -- Non-leader mappings
         -- ========================================

         -- Navigation
         { "H", desc = "First non-blank character" },
         { "L", desc = "End of line" },
         { "J", desc = "Move selection down", mode = "v" },
         { "K", desc = "Move selection up (visual) / Hover (normal)", mode = { "n", "v" } },

         -- Flash
         { "s", desc = "Flash jump", mode = { "n", "x", "o" } },
         { "S", desc = "Flash treesitter", mode = { "n", "x", "o" } },
         { "r", desc = "Remote flash", mode = "o" },
         { "R", desc = "Treesitter search", mode = { "o", "x" } },

         -- LSP go-to mappings
         { "g", group = "Go to" },
         { "gd", desc = "Go to definition" },
         { "gD", desc = "Go to declaration" },
         { "gr", desc = "Go to references" },
         { "gI", desc = "Go to implementation" },
         { "gy", desc = "Go to type definition" },
         { "gl", desc = "Show line diagnostics" },

         -- Diagnostics navigation
         { "<C-n>", desc = "Next diagnostic" },
         { "<C-p>", desc = "Previous diagnostic" },

         -- Function keys
         { "<F3>", desc = "Code action" },

         -- Buffer navigation
         { "<Tab>", desc = "Next buffer" },
         { "<S-Tab>", desc = "Previous buffer" },

         -- Visual mode specific
         { "p", desc = "Paste without yanking", mode = "v" },
         { "<", desc = "Indent left", mode = "v" },
         { ">", desc = "Indent right", mode = "v" },

         -- Window navigation
         { "<C-h>", desc = "Move to left window", mode = { "n", "t" } },
         { "<C-j>", desc = "Move to bottom window", mode = { "n", "t" } },
         { "<C-k>", desc = "Move to top window", mode = { "n", "t" } },
         { "<C-l>", desc = "Move to right window", mode = { "n", "t" } },

         -- Window resizing
         { "<Up>", desc = "Increase window height" },
         { "<Down>", desc = "Decrease window height" },
         { "<Left>", desc = "Decrease window width" },
         { "<Right>", desc = "Increase window width" },

         -- Terminal toggle
         { "<C-\\>", desc = "Toggle terminal", mode = { "n", "t" } },

         -- Command mode
         { "<C-s>", desc = "Toggle flash search", mode = "c" },

         -- Escape
         { "<Esc>", desc = "Clear notifications and highlights" },

         -- ========================================
         -- Oil file explorer (shown in Oil buffers)
         -- ========================================
         -- These are documented for reference but configured in Oil itself
         -- When you press g? in Oil, it shows these:
         -- <CR>  - Select file/directory
         -- <C-s> - Open in vertical split
         -- <C-h> - Open in horizontal split
         -- <C-t> - Open in new tab
         -- <C-p> - Preview
         -- <C-c> - Close Oil
         -- <C-l> - Refresh
         -- -     - Go to parent directory
         -- _     - Open cwd
         -- `     - cd to current directory
         -- g.    - Toggle hidden files
         -- g\    - Toggle trash
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
