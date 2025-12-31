return {
   "coder/claudecode.nvim",
   event = { "BufReadPre", "BufNewFile" },
   dependencies = {
      "folke/snacks.nvim",
   },
   opts = {
      terminal = {
         split_side = "right",
         split_width_percentage = 0.30,
      },
   },
   keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
      { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude Code" },
      { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude Code" },
      { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
   },
   config = function(_, opts)
      require("claudecode").setup(opts)
   end,
}
