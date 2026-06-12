-- Make lua_ls aware of installed plugin sources so their LuaCATS type
-- annotations resolve (e.g. `snacks.Config`, `blink.cmp.*`, `render.md.UserConfig`).
-- lazydev.nvim would normally do this lazily, but it can't be fetched in this
-- (proxied, github-blocked) environment, so we point at the lazy dirs directly.
local lazy_root = vim.fn.stdpath "data" .. "/lazy"
local plugin_types = {
   "snacks.nvim",
   "blink.cmp",
   "render-markdown.nvim",
}

local library = {
   vim.fn.expand "$VIMRUNTIME/lua",
   vim.fn.stdpath "config" .. "/lua",
}
for _, name in ipairs(plugin_types) do
   table.insert(library, lazy_root .. "/" .. name .. "/lua")
end

return {
   settings = {
      Lua = {
         diagnostics = {
            -- `Snacks` is a runtime global set by snacks.nvim (`_G.Snacks`)
            globals = { "vim", "Snacks" },
         },
         workspace = {
            library = library,
            -- We add plugin libs explicitly; skip the "third party" prompt
            checkThirdParty = false,
         },
         telemetry = {
            enable = false,
         },
      },
   },
}
