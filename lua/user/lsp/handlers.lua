local M = {}

-- Setup base LSP capabilities
M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Setup diagnostic signs and configuration
M.setup = function()
   local signs = {
      { severity = vim.diagnostic.severity.ERROR, text = "" },
      { severity = vim.diagnostic.severity.WARN, text = "" },
      { severity = vim.diagnostic.severity.HINT, text = "󰌵" },
      { severity = vim.diagnostic.severity.INFO, text = "" },
   }

   local sign_config = {}
   for _, sign in ipairs(signs) do
      sign_config[sign.severity] = sign.text
   end

   vim.diagnostic.config {
      virtual_text = false,
      signs = {
         text = sign_config,
      },
      update_in_insert = true,
      underline = true,
      severity_sort = true,
      float = {
         focusable = true,
         style = "minimal",
         border = "rounded",
         source = true,
         header = "",
         prefix = "",
      },
   }
end

M.on_attach = require("user.lsp.utils").on_attach

return M
