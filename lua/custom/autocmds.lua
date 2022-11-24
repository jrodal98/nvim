vim.api.nvim_create_autocmd("BufWritePre", {
   pattern = "*",
   callback = function()
      -- vim.lsp.buf.format(nil, 3000)
      vim.lsp.buf.format { async = true }
   end,
   group = format_sync_grp,
})
