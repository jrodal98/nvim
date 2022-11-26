-- this file is adapted from https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#code-1
--
local M = {}

-- these are formatters that should be skipped in favor of null-ls
local formatters_to_skip = {}

formatters_to_skip["sumneko_lua"] = true

M.async_format = function(bufnr)
   bufnr = bufnr or vim.api.nvim_get_current_buf()

   vim.lsp.buf_request(bufnr, "textDocument/formatting", vim.lsp.util.make_formatting_params {}, function(err, res, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if formatters_to_skip[client.name] then
         vim.notify("Formatting: skipping " .. client.name, vim.log.levels.DEBUG)
         return
      end

      if err then
         local err_msg = type(err) == "string" and err or err.message
         -- you can modify the log message / level (or ignore it completely)
         vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
         return
      end

      -- don't apply results if buffer is unloaded or has been modified
      if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
         return
      end

      if res then
         vim.notify("Formatting: using " .. client.name, vim.log.levels.DEBUG)
         vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
         vim.api.nvim_buf_call(bufnr, function()
            vim.cmd "silent noautocmd update"
         end)
      end
   end)
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
M.on_attach = function(client, bufnr)
   if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePost", {
         group = augroup,
         buffer = bufnr,
         callback = function()
            M.async_format(bufnr)
         end,
      })
   end
end

return M
