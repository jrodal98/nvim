require("nvim-treesitter.configs").setup {
   textobjects = {
      select = {
         enable = true,

         -- Automatically jump forward to textobj, similar to targets.vim
         lookahead = true,

         keymaps = {
            -- You can use the capture groups defined in textobjects.scm
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
         set_jumps = true, -- whether to set jumps in the jumplist
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
