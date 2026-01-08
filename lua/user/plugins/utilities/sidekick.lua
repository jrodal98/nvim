return {
   "folke/sidekick.nvim",
   opts = {
      -- Disable NES (Next Edit Suggestions) since it requires Copilot
      nes = { enabled = false },
      cli = {
         picker = "snacks",
         win = {
            layout = "right",
            split = {
               width = 80,
            },
         },
         -- prompts = {
         --    refactor = "Please refactor {this} to be more maintanable",
         --    security = "Review {file} for security vulnerabilities",
         --    custom = function(ctx)
         --       return "Current file: " .. ctx.buf .. " at line " .. ctx.row
         --    end,
         -- },
      },
   },
   keys = {
      {
         "<leader>aa",
         function()
            require("sidekick.cli").toggle()
         end,
         desc = "Sidekick Toggle CLI",
      },
      {
         "<leader>as",
         function()
            require("sidekick.cli").select()
         end,
         desc = "Select CLI",
      },
      {
         "<leader>ac",
         function()
            require("sidekick.cli").toggle { name = "claude", focus = true }
         end,
         desc = "Sidekick Toggle Claude",
      },
      {
         "<leader>at",
         function()
            require("sidekick.cli").send { msg = "{this}" }
         end,
         mode = { "x", "n" },
         desc = "Send This",
      },
      {
         "<leader>af",
         function()
            require("sidekick.cli").send { msg = "{file}" }
         end,
         desc = "Send File",
      },
      {
         "<leader>av",
         function()
            require("sidekick.cli").send { msg = "{selection}" }
         end,
         mode = { "x" },
         desc = "Send Visual Selection",
      },
      {
         "<leader>ap",
         function()
            require("sidekick.cli").prompt()
         end,
         mode = { "n", "x" },
         desc = "Sidekick Select Prompt",
      },
      {
         "<leader>ad",
         function()
            require("sidekick.cli").close()
         end,
         desc = "Detach a CLI Session",
      },
   },
}
