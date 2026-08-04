-- ============================================================================
-- blink-agent-common/snippet: argument-hint to LSP snippet conversion
-- ============================================================================
-- Shared by blink-claude and blink-pi.
-- ============================================================================

local M = {}

-- Test override (set via set_nested_placeholders) and cached detection
local nested_override = nil
local nested_detected = nil

--- Override nested placeholder support (for testing)
--- @param value boolean|nil true/false to force, nil to use detection
function M.set_nested_placeholders(value)
   nested_override = value
end

--- Check if LuaSnip supports nested placeholders
--- @return boolean True if nested placeholders are supported
local function supports_nested_placeholders()
   if nested_override ~= nil then
      return nested_override
   end

   if nested_detected ~= nil then
      return nested_detected
   end

   -- Requires parser_nested_assembler in LuaSnip config
   local ok, _ = pcall(require, "luasnip")
   nested_detected = ok
   return nested_detected
end

--- Convert argument hint to LSP snippet format with nested tab stops
--- @param hint string Argument hint text like "<PROMPT> [--option VALUE]"
--- @return string LSP snippet with tab stops (supports nesting if LuaSnip configured)
function M.hint_to_snippet(hint)
   local tokens = {}
   local current_token = ""
   local bracket_depth = 0

   for i = 1, #hint do
      local char = hint:sub(i, i)

      if char == "[" or char == "<" then
         bracket_depth = bracket_depth + 1
         current_token = current_token .. char
      elseif char == "]" or char == ">" then
         bracket_depth = math.max(0, bracket_depth - 1)
         current_token = current_token .. char
      elseif char:match "%s" and bracket_depth == 0 then
         if #current_token > 0 then
            table.insert(tokens, current_token)
            current_token = ""
         end
      else
         current_token = current_token .. char
      end
   end

   if #current_token > 0 then
      table.insert(tokens, current_token)
   end

   local snippet_parts = {}
   local tab_index = 1
   local use_nested = supports_nested_placeholders()

   for _, token in ipairs(tokens) do
      -- Strip <required> angle brackets: placeholder is just the inner text
      local angle_inner = token:match "^<(.+)>$"
      if angle_inner then
         table.insert(snippet_parts, string.format("${%d:%s}", tab_index, angle_inner))
         tab_index = tab_index + 1
      elseif token:match "^%[.+%]$" then
         local inner = token:sub(2, -2)

         if use_nested then
            -- Pattern: --flag VALUE creates ${N:--flag ${N+1:VALUE}} for two-level navigation
            local flag, value = inner:match "^(%-%-[%w%-]+)%s+([^%s]+)$"

            if flag and value then
               local snippet = string.format("${%d:%s ${%d:%s}}", tab_index, flag, tab_index + 1, value)
               table.insert(snippet_parts, snippet)
               tab_index = tab_index + 2
            else
               local snippet = string.format("${%d:%s}", tab_index, inner)
               table.insert(snippet_parts, snippet)
               tab_index = tab_index + 1
            end
         else
            -- LuaSnip unavailable - simple sequential placeholders
            local snippet = string.format("${%d:%s}", tab_index, inner)
            table.insert(snippet_parts, snippet)
            tab_index = tab_index + 1
         end
      else
         table.insert(snippet_parts, string.format("${%d:%s}", tab_index, token))
         tab_index = tab_index + 1
      end
   end

   return table.concat(snippet_parts, " ")
end

return M
