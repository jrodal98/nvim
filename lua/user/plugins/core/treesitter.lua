return {
   {
      "nvim-treesitter/nvim-treesitter",
      branch = "main",
      lazy = false,
      build = function()
         -- Install tree-sitter-cli if not found
         if vim.fn.executable "tree-sitter" ~= 1 then
            vim.notify("tree-sitter-cli not found, installing via cargo...", vim.log.levels.INFO)
            local result = vim.fn.system "cargo install --locked tree-sitter-cli"
            if vim.v.shell_error ~= 0 then
               vim.notify("Failed to install tree-sitter-cli: " .. result, vim.log.levels.ERROR)
               return
            end
            vim.notify("tree-sitter-cli installed successfully", vim.log.levels.INFO)
         end
         -- Run TSUpdate
         vim.cmd "TSUpdate"
      end,
      config = function()
         local parsers = {
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
         }

         local function install_parsers()
            require("nvim-treesitter").install(parsers)
         end

         -- Ensure tree-sitter-cli is installed (async to not block UI)
         if vim.fn.executable "tree-sitter" ~= 1 then
            vim.notify("tree-sitter-cli not found, installing via cargo...", vim.log.levels.INFO)
            vim.system({ "cargo", "install", "--locked", "tree-sitter-cli" }, { text = true }, function(obj)
               vim.schedule(function()
                  if obj.code ~= 0 then
                     vim.notify("Failed to install tree-sitter-cli: " .. (obj.stderr or ""), vim.log.levels.ERROR)
                  else
                     vim.notify("tree-sitter-cli installed successfully", vim.log.levels.INFO)
                     install_parsers()
                  end
               end)
            end)
         else
            install_parsers()
         end

         -- Enable treesitter features via autocmd
         if not vim.g.vscode then
            vim.api.nvim_create_autocmd("FileType", {
               callback = function()
                  local buf = vim.api.nvim_get_current_buf()
                  local ok_start, _ = pcall(vim.treesitter.start, buf)
                  if ok_start then
                     -- Enable indentation
                     vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                  end
               end,
            })
         end
      end,
   },
   {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
      lazy = false,
      config = function()
         require("nvim-treesitter-textobjects").setup {
            select = {
               lookahead = true,
            },
            move = {
               set_jumps = true,
            },
         }

         -- Select keymaps
         local select = require "nvim-treesitter-textobjects.select"
         vim.keymap.set({ "x", "o" }, "af", function()
            select.select_textobject("@function.outer", "textobjects")
         end, { desc = "Select outer function" })
         vim.keymap.set({ "x", "o" }, "if", function()
            select.select_textobject("@function.inner", "textobjects")
         end, { desc = "Select inner function" })
         vim.keymap.set({ "x", "o" }, "ac", function()
            select.select_textobject("@class.outer", "textobjects")
         end, { desc = "Select outer class" })
         vim.keymap.set({ "x", "o" }, "ic", function()
            select.select_textobject("@class.inner", "textobjects")
         end, { desc = "Select inner class" })
         vim.keymap.set({ "x", "o" }, "ai", function()
            select.select_textobject("@conditional.outer", "textobjects")
         end, { desc = "Select outer conditional" })
         vim.keymap.set({ "x", "o" }, "ii", function()
            select.select_textobject("@conditional.inner", "textobjects")
         end, { desc = "Select inner conditional" })
         vim.keymap.set({ "x", "o" }, "al", function()
            select.select_textobject("@loop.outer", "textobjects")
         end, { desc = "Select outer loop" })
         vim.keymap.set({ "x", "o" }, "il", function()
            select.select_textobject("@loop.inner", "textobjects")
         end, { desc = "Select inner loop" })

         -- Swap keymaps
         local swap = require "nvim-treesitter-textobjects.swap"
         vim.keymap.set("n", "<leader>j", function()
            swap.swap_next "@parameter.inner"
         end, { desc = "Swap with next parameter" })
         vim.keymap.set("n", "<leader>k", function()
            swap.swap_previous "@parameter.inner"
         end, { desc = "Swap with previous parameter" })

         -- Move keymaps
         local move = require "nvim-treesitter-textobjects.move"
         vim.keymap.set({ "n", "x", "o" }, "<leader>nf", function()
            move.goto_next_start("@function.outer", "textobjects")
         end, { desc = "Next function start" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>nc", function()
            move.goto_next_start("@class.outer", "textobjects")
         end, { desc = "Next class start" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>ni", function()
            move.goto_next_start("@conditional.outer", "textobjects")
         end, { desc = "Next conditional start" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>nl", function()
            move.goto_next_start("@loop.outer", "textobjects")
         end, { desc = "Next loop start" })

         vim.keymap.set({ "n", "x", "o" }, "<leader>nF", function()
            move.goto_next_end("@function.outer", "textobjects")
         end, { desc = "Next function end" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>nC", function()
            move.goto_next_end("@class.outer", "textobjects")
         end, { desc = "Next class end" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>nI", function()
            move.goto_next_end("@conditional.outer", "textobjects")
         end, { desc = "Next conditional end" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>nL", function()
            move.goto_next_end("@loop.outer", "textobjects")
         end, { desc = "Next loop end" })

         vim.keymap.set({ "n", "x", "o" }, "<leader>pf", function()
            move.goto_previous_start("@function.outer", "textobjects")
         end, { desc = "Previous function start" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>pc", function()
            move.goto_previous_start("@class.outer", "textobjects")
         end, { desc = "Previous class start" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>pi", function()
            move.goto_previous_start("@conditional.outer", "textobjects")
         end, { desc = "Previous conditional start" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>pl", function()
            move.goto_previous_start("@loop.outer", "textobjects")
         end, { desc = "Previous loop start" })

         vim.keymap.set({ "n", "x", "o" }, "<leader>pF", function()
            move.goto_previous_end("@function.outer", "textobjects")
         end, { desc = "Previous function end" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>pC", function()
            move.goto_previous_end("@class.outer", "textobjects")
         end, { desc = "Previous class end" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>pI", function()
            move.goto_previous_end("@conditional.outer", "textobjects")
         end, { desc = "Previous conditional end" })
         vim.keymap.set({ "n", "x", "o" }, "<leader>pL", function()
            move.goto_previous_end("@loop.outer", "textobjects")
         end, { desc = "Previous loop end" })
      end,
   },
}
