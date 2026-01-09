return {
   "saghen/blink.cmp",
   version = "1.*",
   dependencies = {
      "rafamadriz/friendly-snippets",
      {
         "L3MON4D3/LuaSnip",
         version = "v2.*",
         dependencies = "rafamadriz/friendly-snippets",
      },
      {
         "Exafunction/codeium.nvim",
         cmd = "Codeium",
         -- Only load codeium on non-Meta devices
         cond = function()
            local dotgk = require("init-utils.dotgk-wrapper").get()
            return not dotgk.check "meta"
         end,
         config = function()
            require("codeium").setup {
               -- Disable cmp source since we're using blink
               enable_cmp_source = false,
            }
         end,
      },
   },
   event = { "InsertEnter", "CmdlineEnter" },

   ---@module 'blink.cmp'
   ---@type blink.cmp.Config
   opts = function()
      -- Base configuration (works on all devices)
      local config = {
         keymap = {
            preset = "default",
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide", "fallback" },
         },

         appearance = {
            nerd_font_variant = "mono",
         },

         completion = {
            accept = {
               auto_brackets = {
                  enabled = true,
               },
            },
            menu = {
               draw = {
                  columns = {
                     { "kind_icon" },
                     { "label", "label_description", gap = 1 },
                     { "kind" },
                  },
               },
            },
            documentation = {
               auto_show = true,
               auto_show_delay_ms = 200,
            },
            ghost_text = {
               enabled = true,
            },
         },

         sources = {
            default = { "lsp", "path", "snippets", "buffer" },
            providers = {},
         },

         snippets = {
            preset = "luasnip",
         },

         cmdline = {
            enabled = true,
            keymap = {
               preset = "cmdline",
            },
            -- Cmdline-specific sources
            sources = { "buffer", "cmdline" },
            completion = {
               menu = {
                  auto_show = true,
               },
               ghost_text = {
                  enabled = true,
               },
            },
         },

         -- Terminal completion (requires Neovim 0.11+)
         term = {
            enabled = true,
            keymap = {
               preset = "inherit",
            },
         },

         signature = {
            enabled = false,
         },
      }

      -- Check if we're on a Meta device
      local dotgk = require("init-utils.dotgk-wrapper").get()
      local is_meta = dotgk.check "meta"

      -- Load Meta-specific configuration from meta-private
      if is_meta then
         local meta_ok, blink_config_provider = pcall(require, "meta-private.blink.config")
         if meta_ok then
            local meta_config = blink_config_provider.get()
            if meta_config then
               -- Merge fuzzy config and providers
               config.fuzzy = meta_config.fuzzy
               config.sources.providers =
                  vim.tbl_deep_extend("force", config.sources.providers, meta_config.sources.providers)
               -- Add meta source names to default list
               if meta_config.meta_source_names then
                  for _, source_name in ipairs(meta_config.meta_source_names) do
                     table.insert(config.sources.default, source_name)
                  end
               end
            end
         end
      else
         -- Add codeium on non-Meta devices
         table.insert(config.sources.default, "codeium")
         config.sources.providers.codeium = {
            name = "Codeium",
            module = "codeium.blink",
            async = true,
         }
      end

      return config
   end,

   opts_extend = { "sources.default" },

   -- Set up metamate integration after blink.cmp loads
   init = function()
      -- Check for metamate if available (Meta inline AI suggestions)
      local ok, metamate_provider = pcall(require, "meta-private.cmp.metamate")
      if ok then
         local metamate = metamate_provider.get()
         if metamate then
            -- Override <C-y> to prioritize metamate
            vim.keymap.set("i", "<C-y>", function()
               if metamate.is_visible() then
                  metamate.accept()
               else
                  -- Fall back to blink.cmp accept
                  local blink_ok, blink = pcall(require, "blink.cmp")
                  if blink_ok then
                     blink.accept()
                  else
                     -- Fallback to default behavior
                     return "<C-y>"
                  end
               end
            end, { expr = false, desc = "Accept metamate or blink completion" })
         end
      end
   end,
}
