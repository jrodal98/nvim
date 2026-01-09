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
      -- Check if we're on a Meta device
      local dotgk = require("init-utils.dotgk-wrapper").get()
      local is_meta = dotgk.check "meta"

      -- Check for metamate if available (Meta inline AI suggestions)
      local metamate = nil
      local ok, metamate_provider = pcall(require, "meta-private.cmp.metamate")
      if ok then
         metamate = metamate_provider.get()
      end

      -- Build sources list based on environment
      local sources = { "lsp", "path", "snippets", "buffer" }
      local providers = {}

      -- Add Meta-specific sources for hgcommit files
      if is_meta then
         table.insert(sources, "meta_title")
         table.insert(sources, "meta_tags")
         table.insert(sources, "meta_tasks")
         table.insert(sources, "meta_revsub")

         providers.meta_title = {
            name = "MetaTitle",
            module = "meta.cmp.title",
         }
         providers.meta_tags = {
            name = "MetaTags",
            module = "meta.cmp.tags",
         }
         providers.meta_tasks = {
            name = "MetaTasks",
            module = "meta.cmp.tasks",
         }
         providers.meta_revsub = {
            name = "MetaRevSub",
            module = "meta.cmp.revsub",
         }
      else
         -- Only add codeium on non-Meta devices
         table.insert(sources, "codeium")
         providers.codeium = {
            name = "Codeium",
            module = "codeium.blink",
            async = true,
         }
      end

      return {
         -- Fuzzy configuration with Meta proxy support
         fuzzy = is_meta and {
            prebuilt_binaries = {
               proxy = {
                  url = "http://fwdproxy:8080",
               },
            },
         } or {},

         keymap = {
            preset = "default", -- C-y to accept, Tab/S-Tab to navigate
            -- Additional keymaps matching your nvim-cmp config
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
            default = sources,
            providers = providers,
         },

         snippets = {
            preset = "luasnip",
         },

         -- Cmdline completion
         cmdline = {
            enabled = true,
            keymap = {
               preset = "cmdline", -- Tab to show/navigate
            },
            completion = {
               menu = {
                  auto_show = false, -- Default behavior, press Tab to show
               },
            },
         },

         -- Signature help
         signature = {
            enabled = false, -- Keep disabled for now, can enable later
         },
      }
   end,
   -- Extend sources.default instead of overwriting it
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
