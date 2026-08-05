-- ============================================================================
-- blink-agent-common/items: completion item builder
-- ============================================================================
-- Shared by blink-claude and blink-pi. Owns the parts of a completion item
-- that are identical across agent sources: snippet insertText from
-- argument-hints, markdown documentation with a **Usage:** section, kind,
-- and label details. Callers supply the label, doc suffix and data payload.
-- ============================================================================

---@module 'blink.cmp'

local snippet = require "local_plugins.blink-agent-common.snippet"

local M = {}

--- @class BlinkAgentItemOpts
--- @field label string Completion label, e.g. "/skill:foo" (also the plain insert text)
--- @field source_label string Menu label, e.g. "Claude" or "Pi"
--- @field description string|nil Description from frontmatter
--- @field fallback_description string Used when description is nil
--- @field doc_suffix string|nil Appended to the description (e.g. "\n\n(user)")
--- @field argument_hint string|nil Converted to snippet tab stops when present
--- @field file string Path to the source file (stored in item.data.file)
--- @field data table|nil Extra fields merged into item.data

--- Build a completion item
--- @param opts BlinkAgentItemOpts
--- @return blink.cmp.CompletionItem
function M.make(opts)
   local has_hint = opts.argument_hint and #opts.argument_hint > 0

   local insertText, insertTextFormat
   if has_hint then
      insertText = opts.label .. " " .. snippet.hint_to_snippet(opts.argument_hint)
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet
   else
      insertText = opts.label
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText
   end

   local doc_value = (opts.description or opts.fallback_description) .. (opts.doc_suffix or "")
   if has_hint then
      doc_value = doc_value .. "\n\n**Usage:** `" .. opts.argument_hint .. "`"
   end

   local data = { file = opts.file }
   for k, v in pairs(opts.data or {}) do
      data[k] = v
   end

   return {
      label = opts.label,
      kind = vim.lsp.protocol.CompletionItemKind.Snippet,
      insertTextFormat = insertTextFormat,
      insertText = insertText,
      labelDetails = {
         description = opts.source_label,
      },
      documentation = {
         kind = "markdown",
         value = doc_value,
      },
      data = data,
   }
end

return M
