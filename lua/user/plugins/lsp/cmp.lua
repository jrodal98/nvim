return {
   "hrsh7th/nvim-cmp",
   event = { "InsertEnter", "CmdlineEnter" },
   dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "saadparwaiz1/cmp_luasnip",
      {
         "L3MON4D3/LuaSnip",
         dependencies = "rafamadriz/friendly-snippets",
      },
   },
   config = function()
      local cmp = require "cmp"
      local luasnip = require "luasnip"

      -- Load snippets
      require("luasnip.loaders.from_vscode").lazy_load { paths = "./snippets" }
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Check for metamate if available
      local metamate = nil
      local ok, metamate_provider = pcall(require, "meta-private.cmp.metamate")
      if ok then
         metamate = metamate_provider.get()
      end

      local check_backspace = function()
         local col = vim.fn.col "." - 1
         return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
      end

      local kind_icons = {
         Text = "󰉿",
         Method = "󰆧",
         Function = "󰆧",
         Constructor = "󰆧",
         Field = "",
         Variable = "",
         Class = "󰌗",
         Interface = "",
         Module = "󰅩",
         Property = "",
         Unit = "",
         Value = "󰎠",
         Enum = "",
         Keyword = "󰉨",
         Snippet = "󰃐",
         Color = "󰏘",
         File = "󰈙",
         Reference = "",
         Folder = "󰉋",
         EnumMember = "",
         Constant = "󰇽",
         Struct = "",
         Event = "",
         Operator = "󰆕",
         TypeParameter = "󰊄",
      }

      cmp.setup {
         snippet = {
            expand = function(args)
               luasnip.lsp_expand(args.body)
            end,
         },
         mapping = cmp.mapping.preset.insert {
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-1),
            ["<C-f>"] = cmp.mapping.scroll_docs(1),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<C-y>"] = cmp.mapping(function(fallback)
               if metamate and metamate.is_visible() then
                  metamate.accept()
               elseif cmp.visible() then
                  cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true }
               else
                  fallback()
               end
            end),
            ["<Tab>"] = cmp.mapping(function(fallback)
               if cmp.visible() then
                  cmp.select_next_item()
               elseif luasnip.expandable() then
                  luasnip.expand()
               elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
               elseif check_backspace() then
                  fallback()
               else
                  fallback()
               end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
               if cmp.visible() then
                  cmp.select_prev_item()
               elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
               else
                  fallback()
               end
            end, { "i", "s" }),
         },
         formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, vim_item)
               vim_item.kind = kind_icons[vim_item.kind]
               vim_item.menu = ({
                  nvim_lsp = "",
                  nvim_lua = "",
                  luasnip = "",
                  buffer = "",
                  path = "",
                  emoji = "",
               })[entry.source.name]
               return vim_item
            end,
         },
         sources = {
            { name = "codeium" },
            { name = "nvim_lsp" },
            { name = "nvim_lua" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
         },
         confirm_opts = {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
         },
         window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
         },
         experimental = {
            ghost_text = true,
         },
      }

      -- Cmdline setup for `/` (search)
      cmp.setup.cmdline("/", {
         mapping = cmp.mapping.preset.cmdline(),
         sources = {
            { name = "buffer" },
         },
      })

      -- Cmdline setup for `:` (commands)
      cmp.setup.cmdline(":", {
         mapping = cmp.mapping.preset.cmdline(),
         sources = cmp.config.sources({
            { name = "path" },
         }, {
            {
               name = "cmdline",
               option = {
                  ignore_cmds = { "Man", "!" },
               },
            },
         }),
      })

      -- Disable completion for oil.nvim
      cmp.setup.filetype("oil", {
         sources = {
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
         },
      })
   end,
}
