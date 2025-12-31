local M = {}

local notification_shown = false

-- Try to load real dotgk
local function load_real_dotgk()
   package.path = package.path .. ";" .. vim.fn.expand "~/.config/dotgk/caches/?.lua"
   local ok, dotgk = pcall(require, "dotgk")
   if ok then
      return dotgk
   end
   return nil
end

-- Create mock dotgk
local function create_mock_dotgk()
   -- Show notification once unless silenced
   if not notification_shown and not vim.g.dotgk_silence_notification then
      vim.notify(
         "dotgk not configured - using defaults (all checks return false)\n"
            .. "To silence: vim.g.dotgk_silence_notification = true\n"
            .. "To mock values: vim.g.dotgk_mock_values = { ['meta'] = true }",
         vim.log.levels.INFO
      )
      notification_shown = true
   end

   return {
      check = function(key)
         -- Check custom mock values first
         if vim.g.dotgk_mock_values and vim.g.dotgk_mock_values[key] ~= nil then
            return vim.g.dotgk_mock_values[key]
         end
         -- Default to false
         return false
      end,
   }
end

-- Load or create dotgk
function M.get()
   local real_dotgk = load_real_dotgk()
   if real_dotgk then
      return real_dotgk
   end
   return create_mock_dotgk()
end

return M
