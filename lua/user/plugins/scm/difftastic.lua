return {
   "difftastic.nvim",
   dir = "~/dev/difftastic.nvim",
   dependencies = {
      "MunifTanjim/nui.nvim",
      "folke/snacks.nvim",
   },
   config = function()
      require("difftastic-nvim").setup {
         download = false, -- Using local build
         vcs = "sl",
         snacks_picker = {
            enabled = true,
            limit = 200,
            sl_log_revset = nil, -- nil = show all commits
         },
         keymaps = {
            next_hunk = "<C-n>",
            prev_hunk = "<C-p>",
         },
      }
   end,
}
