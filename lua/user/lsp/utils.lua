local M = {}

-- Formatters to skip when formatting
local formatters_to_skip = {
   hhvm = true,
   lua_ls = true,
   pyright = true,
   bashls = true,
}

local ok, skip_list = pcall(require, "meta-private.formatters.skip-list")
if ok then
   local meta_skip = skip_list.get()
   if meta_skip then
      formatters_to_skip = vim.tbl_extend("force", formatters_to_skip, meta_skip)
   end
end

-- Organize imports via code action
local function organize_imports(bufnr)
   local clients = vim.lsp.get_clients { bufnr = bufnr, method = "textDocument/codeAction" }
   if #clients == 0 then
      return
   end

   local params = vim.lsp.util.make_range_params()
   params.context = { diagnostics = vim.diagnostic.get() }

   local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params)
   if not results then
      return
   end

   for _, result in pairs(results) do
      for _, action in pairs(result.result or {}) do
         if action.kind == "source.organizeImports" then
            vim.lsp.buf.code_action { context = { only = { "source.organizeImports" } }, apply = true }
            vim.wait(100)
            break
         end
      end
   end
end

-- Async format buffer
M.async_format = function(bufnr)
   bufnr = bufnr or vim.api.nvim_get_current_buf()

   -- Organize imports first (adds 100ms for ruff but worth it)
   organize_imports(bufnr)

   vim.lsp.buf_request(bufnr, "textDocument/formatting", vim.lsp.util.make_formatting_params {}, function(err, res, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if not client then
         return
      end

      if formatters_to_skip[client.name] then
         vim.notify("Formatting: skipping " .. client.name, vim.log.levels.DEBUG)
         return
      end

      if err then
         local err_msg = type(err) == "string" and err or err.message
         vim.notify("Formatting: " .. err_msg, vim.log.levels.WARN)
         return
      end

      -- Don't apply results if buffer is unloaded or modified
      if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].modified then
         return
      end

      if res then
         vim.notify("Formatting: using " .. client.name, vim.log.levels.DEBUG)
         vim.lsp.util.apply_text_edits(res, bufnr, client.offset_encoding or "utf-16")
         vim.api.nvim_buf_call(bufnr, function()
            vim.cmd "silent noautocmd update"
         end)
      end
   end)
end

-- Setup LSP keymaps for buffer
local function lsp_keymaps(bufnr)
   local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
   end

   -- Navigation
   map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
   map("n", "gd", vim.lsp.buf.definition, "Go to definition")
   map("n", "gI", vim.lsp.buf.implementation, "Go to implementation")
   map("n", "gr", vim.lsp.buf.references, "Show references")
   map("n", "K", vim.lsp.buf.hover, "Show hover documentation")

   -- Diagnostics
   map("n", "gl", vim.diagnostic.open_float, "Show line diagnostics")
   map("n", "<C-n>", function()
      vim.diagnostic.goto_next { buffer = 0 }
   end, "Next diagnostic")
   map("n", "<C-p>", function()
      vim.diagnostic.goto_prev { buffer = 0 }
   end, "Previous diagnostic")
   map("n", "<leader>lq", vim.diagnostic.setloclist, "Diagnostics to loclist")

   -- Actions
   map("n", "<F3>", vim.lsp.buf.code_action, "Code action")
   map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
   map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
   map("n", "<leader>fm", function()
      require("user.lsp.utils").async_format()
   end, "Format buffer")

   -- Info
   map("n", "<leader>li", "<cmd>LspInfo<CR>", "LSP info")
   map("n", "<leader>ls", vim.lsp.buf.signature_help, "Signature help")
end

-- LSP attach callback
local format_augroup = vim.api.nvim_create_augroup("LspFormatting", {})

M.on_attach = function(client, bufnr)
   lsp_keymaps(bufnr)

   -- Client-specific configurations
   if client.name == "ruff" then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
   end

   -- Enable inlay hints if supported
   if client.supports_method "textDocument/inlayHint" then
      vim.lsp.inlay_hint.enable(true, { bufnr })
   end

   -- Setup format on save if supported
   if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = format_augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePost", {
         group = format_augroup,
         buffer = bufnr,
         desc = "LSP format on save",
         callback = function()
            -- Don't format oil buffers to prevent interference with confirmation windows
            local ft = vim.bo[bufnr].filetype
            if ft ~= "oil" and ft ~= "oil_preview" then
               M.async_format(bufnr)
            end
         end,
      })
   end
end

return M
