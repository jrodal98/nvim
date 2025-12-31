return {
   "MeanderingProgrammer/render-markdown.nvim",
   ft = { "markdown", "yaml" }, -- Load for markdown and yaml files
   dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
   },
   ---@module 'render-markdown'
   ---@type render.md.UserConfig
   opts = {
      -- Enable LSP completions for markdown
      completions = {
         lsp = {
            enabled = true,
         },
      },
   },
}
