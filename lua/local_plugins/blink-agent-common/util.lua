-- ============================================================================
-- blink-agent-common/util: filesystem/path helpers
-- ============================================================================
-- Shared by blink-claude and blink-pi.
-- ============================================================================

local M = {}

--- Resolve home directory from source config (supports test override)
--- @param config {home_dir: string|nil}
--- @return string Home directory path
function M.home_of(config)
   return config.home_dir or vim.env.HOME or vim.fn.expand "~"
end

--- Call fn with each ancestor directory of cwd (including cwd itself)
--- @param fn fun(dir: string)
function M.walk_ancestors(fn)
   local current = vim.fn.getcwd()

   while true do
      fn(current)

      if current == "/" then
         break
      end

      local parent = vim.fn.fnamemodify(current, ":h")
      if parent == current then
         break
      end
      current = parent
   end
end

return M
