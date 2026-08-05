-- ============================================================================
-- blink-agent-common/frontmatter: YAML frontmatter helpers
-- ============================================================================
-- Shared by blink-claude and blink-pi. Tolerant parsing: leading blank lines
-- before the opening delimiter, single- or double-quoted values.
-- ============================================================================

local M = {}

--- Find the opening frontmatter delimiter, tolerating leading blank lines
--- @param lines string[] File lines
--- @return number|nil Index of the opening "---" or nil if no frontmatter
function M.start(lines)
   local i = 1
   while lines[i] and lines[i]:match "^%s*$" do
      i = i + 1
   end

   if lines[i] == "---" then
      return i
   end

   return nil
end

--- Strip surrounding single or double quotes from a YAML value
--- @param value string
--- @return string
function M.strip_quotes(value)
   return value:match '^"(.*)"$' or value:match "^'(.*)'$" or value
end

--- Skip YAML frontmatter and return the line number after it
--- @param lines string[] File lines
--- @return number Line number after frontmatter (1-indexed), or 1 if no frontmatter
function M.skip(lines)
   local start = M.start(lines)
   if not start then
      return 1
   end

   for i = start + 1, #lines do
      if lines[i] == "---" then
         return i + 1
      end
   end

   return 1 -- Malformed frontmatter
end

--- Extract description from YAML frontmatter (supports multi-line values)
--- @param lines string[] File lines
--- @return string|nil Description or nil
function M.parse_description(lines)
   local start = M.start(lines)
   if not start then
      return nil
   end

   local in_description = false
   local description_parts = {}

   for i = start + 1, #lines do
      local line = lines[i]

      if line == "---" then
         break
      end

      if line:match "^description:%s*(.*)$" then
         local inline_desc = line:match "^description:%s*(.+)$"
         if inline_desc then
            return M.strip_quotes(inline_desc)
         end
         in_description = true
      elseif in_description then
         if line:match "^%w+:" then
            break
         elseif line:match "^%s+(.+)$" then
            local content = line:match "^%s+(.+)$"
            table.insert(description_parts, content)
         end
      end
   end

   if #description_parts > 0 then
      return table.concat(description_parts, " ")
   end

   return nil
end

--- Extract a single-line YAML frontmatter field
--- @param lines string[] File lines
--- @param field string Field name as a Lua pattern (escape hyphens, e.g. "argument%-hint")
--- @return string|nil Field value (quotes stripped) or nil
function M.parse_field(lines, field)
   local start = M.start(lines)
   if not start then
      return nil
   end

   for i = start + 1, #lines do
      local line = lines[i]
      if line == "---" then
         break
      end

      local value = line:match("^" .. field .. ":%s*(.+)$")
      if value then
         return M.strip_quotes(value)
      end
   end

   return nil
end

--- Read a file and extract its frontmatter metadata
--- @param file_path string Path to the .md file
--- @param opts {first_line_fallback: boolean|nil}|nil Fall back to the first
---   content line when the frontmatter has no description
--- @return {name: string|nil, description: string|nil, argument_hint: string|nil}
function M.extract(file_path, opts)
   opts = opts or {}

   local ok, lines = pcall(vim.fn.readfile, file_path, "", 50)
   if not ok or not lines then
      return {}
   end

   local meta = {
      name = M.parse_field(lines, "name"),
      description = M.parse_description(lines),
      argument_hint = M.parse_field(lines, "argument%-hint"),
   }

   if not meta.description and opts.first_line_fallback then
      meta.description = M.first_content_line(lines)
   end

   return meta
end

--- Extract first non-empty, non-heading content line after frontmatter
--- @param lines string[] File lines
--- @return string|nil First content line or nil
function M.first_content_line(lines)
   local start_line = M.skip(lines)

   for i = start_line, #lines do
      local trimmed = lines[i]:match "^%s*(.-)%s*$"
      if trimmed and #trimmed > 0 and not trimmed:match "^#" then
         return trimmed
      end
   end

   return nil
end

return M
