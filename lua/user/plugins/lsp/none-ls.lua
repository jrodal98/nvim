return {
   "nvimtools/none-ls.nvim",
   event = { "BufReadPre", "BufNewFile" },
   config = function()
      local null_ls = require "null-ls"

      -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/
      -- MasonInstall prettierd shfmt shellharden
      local sources = {
         null_ls.builtins.formatting.prettierd,
         null_ls.builtins.formatting.shfmt.with { extra_args = { "-i", "2", "-ci", "-bn" } },
         null_ls.builtins.formatting.shellharden,
      }

      -- Try to load Meta-specific sources (provider handles dotgk check)
      local ok, none_ls_sources = pcall(require, "meta-private.none-ls.sources")
      if ok then
         local meta_sources = none_ls_sources.get()
         if meta_sources then
            sources = vim.list_extend(sources, meta_sources)
         end
      end

      null_ls.setup {
         debug = false,
         sources = sources,
         on_attach = require("user.lsp.utils").on_attach,
      }
   end,
}
