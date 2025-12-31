-- Enable faster Lua module loading
vim.loader.enable()

-- Load dotgk (with wrapper for graceful degradation)
local dotgk = require("init-utils.dotgk-wrapper").get()

-- Add meta-private plugin to package path and runtime path if on Meta device
if dotgk.check "meta" then
   local meta_private_base = vim.fn.expand "~/.config/nvim-meta-private"
   local meta_private_lua = meta_private_base .. "/lua"

   if vim.fn.isdirectory(meta_private_base) == 1 then
      -- Add to runtime path for ftplugin files
      vim.opt.rtp:prepend(meta_private_base)

      -- Add to package path for require() calls
      package.path = package.path .. ";" .. meta_private_lua .. "/?.lua;" .. meta_private_lua .. "/?/init.lua"

      local ok, meta_private = pcall(require, "meta-private")
      if ok then
         meta_private.setup()
      else
         vim.notify("Meta-private plugin failed to load: " .. tostring(meta_private), vim.log.levels.WARN)
      end
   end
end

-- Build plugin spec table for lazy.nvim
local spec = {}

-- Load add_spec helper
local add_spec_module = require "init-utils.add-spec"
local function add_spec(item)
   add_spec_module.add_spec(spec, item)
end

-- General settings
require "user.options"
require "user.keymaps"
require "user.autocommands"
require "user.filetypes"

-- Load plugins conditionally based on environment
if not vim.g.vscode then
   -- UI & Theming
   add_spec "user.plugins.ui.colorscheme"
   add_spec "user.plugins.ui.alpha"
   add_spec "user.plugins.ui.lualine"
   add_spec "user.plugins.ui.bufferline"
   add_spec "user.plugins.ui.webdevicons"
   add_spec "user.plugins.ui.indentline"
   add_spec "user.plugins.ui.tpipeline"
   add_spec "user.plugins.ui.render-markdown"

   -- File Management
   add_spec "user.plugins.files.nvim-tree"
   add_spec "user.plugins.files.oil"
   add_spec "user.plugins.files.telescope"
   add_spec "user.plugins.files.tv"
   add_spec "user.plugins.files.bbye"

   -- Editing
   add_spec "user.plugins.editing.autopairs"
   add_spec "user.plugins.editing.comment"
   add_spec "user.plugins.editing.cutlass"
   add_spec "user.plugins.editing.surround"
   add_spec "user.plugins.editing.abolish"
   add_spec "user.plugins.editing.repeat"
   add_spec "user.plugins.editing.dial"

   -- LSP & Diagnostics
   add_spec "user.plugins.lsp.nvim-lspconfig"
   add_spec "user.plugins.lsp.none-ls"
   add_spec "user.plugins.lsp.nvim-lightbulb"
   add_spec "user.plugins.lsp.trouble"
   add_spec "user.plugins.lsp.fidget"
   add_spec "user.plugins.lsp.tiny-inline-diagnostic"
   add_spec "user.plugins.lsp.cmp"

   -- SCM (Source Control Management)
   add_spec "user.plugins.scm.gitsigns"
   add_spec "user.plugins.scm.git-conflict"

   -- Utilities
   add_spec "user.plugins.utilities.flatten"
   add_spec "user.plugins.utilities.toggleterm"
   add_spec "user.plugins.utilities.notify"

   -- Try to load all Meta-specific plugins at once
   local ok_meta, meta_specs = pcall(require, "meta-private.plugins")
   if ok_meta and meta_specs then
      for _, plugin_spec in ipairs(meta_specs) do
         table.insert(spec, plugin_spec)
      end
   else
      -- Non-Meta fallback plugins
      add_spec "user.plugins.utilities.codeium"
   end
else
   -- VSCode integration
   local vscode = require "vscode"
   vim.notify = vscode.notify
   vim.g.clipboard = vim.g.vscode_clipboard
end

-- Core plugins (always loaded)
add_spec "user.plugins.core.plenary"
add_spec "user.plugins.core.treesitter"
add_spec "user.plugins.core.flash"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
   local lazyrepo = "https://github.com/folke/lazy.nvim.git"
   local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
   if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
         { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
         { out, "WarningMsg" },
         { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
   end
end
vim.opt.rtp:prepend(lazypath)

-- Determine lockfile based on environment
local lockfile = dotgk.check "meta/devserver" and "lazy-lock-meta-devserver.json"
   or dotgk.check "meta" and "lazy-lock-meta.json"
   or "lazy-lock.json"

-- Setup lazy.nvim
require("lazy").setup {
   spec = spec,
   defaults = {
      lazy = false, -- Don't lazy-load by default (plugins opt-in to lazy loading)
   },
   lockfile = lockfile,
   performance = {
      rtp = {
         disabled_plugins = {
            "gzip",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
         },
      },
   },
}
