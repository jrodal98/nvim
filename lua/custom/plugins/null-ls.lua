local null_ls = require "null-ls"
local b = null_ls.builtins

local sources = {

   -- things like html, markdown, json (web oriented stuff)
   -- sudo npm install -g prettier @fsouza/prettierd
   b.formatting.prettierd,

   -- Lua
   -- cargo install stylua
   b.formatting.stylua,

   -- python code formatting
   -- pip install --user black
   b.formatting.black,

   -- python import sorting
   -- pip install --user usort
   b.formatting.usort,

   -- Shell
   -- sudo pacman -Syu shfmt
   -- brew install shfmt
   -- closely follows Google's standards
   b.formatting.shfmt.with { extra_args = { "-i", "2", "-ci", "-bn" } },

   -- sudo pacman -Syu shellcheck
   -- brew install shellcheck
   b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
   -- adding this causes an "exit 1" error notification on start-up
   -- when opening shell scripts, but it doesn't seem to have an effect.
   b.code_actions.shellcheck,

   -- Offers prose suggestions on markdown and tex
   -- pip install --user proselint
   b.diagnostics.proselint,
}

local M = {}

M.setup = function()
   null_ls.setup {
      debug = true,
      sources = sources,
      on_attach = require("custom.async_formatting").on_attach,
   }
end

return M
