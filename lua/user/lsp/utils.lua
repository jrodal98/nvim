local M = {}

-- these are formatters that should be skipped in favor of null-ls
local formatters_to_skip = {
   sumneko_lua = true,
}

-- adapted from https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#code-1
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

local function lsp_keymaps(bufnr)
   local opts = { noremap = true, silent = true }
   local keymap = vim.api.nvim_buf_set_keymap
   keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
   keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
   keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
   keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
   keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
   keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
   keymap(bufnr, "n", "<leader>fm", "<cmd>lua require 'user.lsp.utils'.async_format()<CR>", opts)
   keymap(bufnr, "n", "<F3>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
   keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
   keymap(bufnr, "n", "<C-n>", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", opts)
   keymap(bufnr, "n", "<C-p>", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", opts)
   keymap(bufnr, "n", "<leader>li", "<cmd>LspInfo<cr>", opts)
   keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
   keymap(bufnr, "n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
   keymap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
M.on_attach = function(client, bufnr)
   lsp_keymaps(bufnr)
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
