local status_ok, inlayhints = pcall(require, "lsp-inlayhints")
if not status_ok then
   return
end

-- get rid of block effect on inlayhint
vim.cmd [[highlight! link LspInlayHint Comment]]

inlayhints.setup()
vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
vim.api.nvim_create_autocmd("LspAttach", {
   group = "LspAttach_inlayhints",
   callback = function(args)
      if not (args.data and args.data.client_id) then
         return
      end

      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      inlayhints.on_attach(client, bufnr)
   end,
})
