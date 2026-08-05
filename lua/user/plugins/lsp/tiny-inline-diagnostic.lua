-- Inline diagnostics; virtual_text is disabled in user.lsp.handlers so the
-- two don't overlap.
return {
   "rachartier/tiny-inline-diagnostic.nvim",
   event = "LspAttach",
   opts = {},
}
