return {
    {
        "karb94/neoscroll.nvim",
         opt = true,
         config = function()
            require("neoscroll").setup()
         end,

         -- lazy loading
         setup = function()
           require("core.utils").packer_lazy_load "neoscroll.nvim"
         end,
  },

  {
    "blackCauldron7/surround.nvim",
    config = function()
      require"surround".setup {mappings_style = "sandwich"}
    end
  },

   {
       "svermeulen/vim-cutlass"
  },

   {
      "jose-elias-alvarez/null-ls.nvim",
      after = "nvim-lspconfig",
      config = function()
         require("custom.plugins.null-ls").setup()
      end,
   },
}
