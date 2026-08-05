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

-- General settings
require "user.options"
require "user.keymaps"
require "user.autocommands"
require "user.filetypes"

-- Build plugin spec table for lazy.nvim. Each category directory under
-- lua/user/plugins/ is imported wholesale, so adding a plugin is just adding
-- a file to the right category.
local spec = {
   -- Core plugins (always loaded, including in VSCode)
   { import = "user.plugins.core" },
}

if not vim.g.vscode then
   for _, category in ipairs { "ui", "files", "editing", "lsp", "scm", "utilities" } do
      table.insert(spec, { import = "user.plugins." .. category })
   end

   -- Meta-specific plugins (optional)
   local ok_meta, meta_specs = pcall(require, "meta-private.plugins")
   if ok_meta and meta_specs then
      for _, plugin_spec in ipairs(meta_specs) do
         table.insert(spec, plugin_spec)
      end
   end
else
   -- VSCode integration
   local vscode = require "vscode"
   vim.notify = vscode.notify
   vim.g.clipboard = vim.g.vscode_clipboard
end

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
   lockfile = vim.fn.stdpath "config" .. "/" .. lockfile,
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
