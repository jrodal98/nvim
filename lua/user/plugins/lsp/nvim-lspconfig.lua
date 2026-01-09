return {
   "neovim/nvim-lspconfig",
   event = { "BufReadPre", "BufNewFile" },
   cmd = "Mason",
   dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
   },
   config = function()
      -- Setup diagnostic signs and configuration
      local handlers = require "user.lsp.handlers"
      handlers.setup()

      -- Base LSP servers for all environments
      local servers = {
         "bashls",
         "dockerls",
         "docker_compose_language_service",
         "lua_ls",
         "stylua",
      }

      local install_args = {}

      -- Try to load Meta-specific servers (provider handles dotgk check)
      local ok, lsp_servers = pcall(require, "meta-private.lsp.servers")
      if ok then
         local meta_servers = lsp_servers.get()
         if meta_servers and #meta_servers > 0 then
            servers = vim.list_extend(servers, meta_servers)

            -- Also load Meta-specific install args
            local ok_args, lsp_install_args = pcall(require, "meta-private.lsp.install-args")
            if ok_args then
               local args = lsp_install_args.get()
               if args then
                  install_args = args
               end
            end
         else
            -- No Meta servers, add public LSP servers
            servers = vim.list_extend(servers, {
               "pyright",
               "rust_analyzer",
               "ruff",
            })
         end
      else
         -- Private plugin not available, add public LSP servers
         servers = vim.list_extend(servers, {
            "pyright",
            "rust_analyzer",
            "ruff",
         })
      end

      -- Mason settings
      local mason_settings = {
         pip = {
            upgrade_pip = false,
            install_args = install_args,
         },
         ui = {
            border = "none",
            icons = {
               package_installed = "◍",
               package_pending = "◍",
               package_uninstalled = "◍",
            },
         },
         log_level = vim.log.levels.INFO,
         max_concurrent_installers = 4,
      }

      -- Filter servers to exclude Meta-specific or special ones from auto-install
      local ensure_installed = {}
      for _, server in ipairs(servers) do
         if not server:find "@meta" and server ~= "hhvm" then
            table.insert(ensure_installed, server)
         end
      end

      local mason_lspconfig_settings = {
         ensure_installed = ensure_installed,
         automatic_enable = false,
      }

      -- Setup Mason and mason-lspconfig
      require("mason").setup(mason_settings)
      require("mason-lspconfig").setup(mason_lspconfig_settings)

      -- Configure and enable LSP servers
      for _, server in ipairs(servers) do
         local opts = {
            capabilities = handlers.capabilities,
         }

         -- Load server-specific settings if available
         local has_custom_config, custom_config = pcall(require, "user.lsp.settings." .. server)
         if has_custom_config then
            opts = vim.tbl_deep_extend("force", custom_config, opts)
         end

         -- Merge blink.cmp capabilities if available
         local ok, blink = pcall(require, "blink.cmp")
         if ok then
            opts.capabilities = blink.get_lsp_capabilities(opts.capabilities)
         end

         vim.lsp.config(server, opts)
         vim.lsp.enable(server)
      end

      -- Setup LspAttach autocmd
      local lsp_augroup = vim.api.nvim_create_augroup("jrodal.cfg", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
         group = lsp_augroup,
         desc = "LSP attach handler",
         callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client then
               handlers.on_attach(client, ev.buf)
            end
         end,
      })
   end,
}
