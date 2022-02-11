local null_ls = require "null-ls"
local b = null_ls.builtins

local sources = {

   -- things like html, markdown, json (web oriented stuff)
   -- sudo npm install -g prettier @fsouza/prettierd
   b.formatting.prettierd,

   -- Lua
   -- cargo install stylua
   b.formatting.stylua,

   -- python
   -- pip install --user black
   b.formatting.black,

   -- Shell
   -- sudo pacman -Syu shfmt
   -- brew install shfmt
   -- closely follows Google's standards
   b.formatting.shfmt.with { extra_args = { "-i", "2", "-ci", "-bn"} },

   -- sudo pacman -Syu shellcheck
   -- brew install shellcheck
   b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
}

local M = {}

M.setup = function()
   null_ls.setup {
      debug = true,
      sources = sources,
   }
end

return M
