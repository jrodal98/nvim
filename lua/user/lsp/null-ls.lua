local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
   return
end

-- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
-- local diagnostics = null_ls.builtins.diagnostics
-- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/code_actions
-- local code_actions = null_ls.builtins.code_actions

-- MasonInstall prettierd stylua shfmt
null_ls.setup {
   debug = false,
   sources = {
      -- formatters
      formatting.prettierd,
      formatting.stylua,
      formatting.shfmt.with { extra_args = { "-i", "2", "-ci", "-bn" } },
      -- diagnostics
      -- code_actions
   },
   on_attach = require("user.lsp.utils").on_attach,
}
