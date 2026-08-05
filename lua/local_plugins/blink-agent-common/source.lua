-- ============================================================================
-- blink-agent-common/source: blink.cmp source factory
-- ============================================================================
-- Shared by blink-claude and blink-pi. Owns the pieces that are identical
-- across agent completion sources:
--   - session-scoped item cache with error handling (+ alphabetical sorting)
--   - target-buffer detection (markdown + basename pattern)
--   - slash-context trigger logic
--   - blink.cmp provider protocol (new/get_trigger_characters/get_completions)
--   - test hooks (configure/reset_cache)
--
-- Each plugin supplies only its scanner:
--
--   return require("local_plugins.blink-agent-common.source").make {
--      name = "blink-pi",
--      filename_pattern = "^pi%-editor",
--      scan = function(config) return items end, -- config has home_dir override
--   }
-- ============================================================================

---@module 'blink.cmp'

local M = {}

--- @class BlinkAgentSourceOpts
--- @field name string Plugin name for error notifications (e.g. "blink-pi")
--- @field filename_pattern string Lua pattern matched against the buffer basename
--- @field scan fun(config: {home_dir: string|nil}): blink.cmp.CompletionItem[]
--- @field trigger_characters string[]|nil Defaults to { "/", ":" }

--- Build a blink.cmp source module
--- @param opts BlinkAgentSourceOpts
--- @return blink.cmp.Source
function M.make(opts)
   --- @class blink.cmp.Source
   local source = {}

   -- Configuration for testing (home_dir override)
   local config = {
      home_dir = nil, -- Will use vim.env.HOME if nil
   }

   -- Session-scoped cache for completion items
   local cache = {
      items = nil,
      initialized = false,
   }

   --- Check if the buffer is a target markdown buffer for this source
   --- @param bufnr number Buffer number
   --- @return boolean
   local function is_target_buffer(bufnr)
      if vim.bo[bufnr].filetype ~= "markdown" then
         return false
      end

      local filename = vim.api.nvim_buf_get_name(bufnr)
      local basename = vim.fn.fnamemodify(filename, ":t")

      return basename:match(opts.filename_pattern) ~= nil
   end

   --- Get cached completion items, loading them if necessary
   --- @return blink.cmp.CompletionItem[] Completion items (may be empty on error)
   local function get_cached_items()
      if not cache.items then
         local ok, items_or_err = pcall(opts.scan, config)
         if ok then
            table.sort(items_or_err, function(a, b)
               return a.label < b.label
            end)
            cache.items = items_or_err
            cache.initialized = true
         else
            vim.notify(opts.name .. ": Error scanning files: " .. tostring(items_or_err), vim.log.levels.WARN)
            cache.items = {}
            cache.initialized = true
         end
      end
      return cache.items
   end

   --- Check if completions should be shown in current context
   --- @param ctx blink.cmp.Context Completion context
   --- @param bufnr number Buffer number
   --- @return boolean True if completions should be shown
   local function should_show_completions(ctx, bufnr)
      if not is_target_buffer(bufnr) then
         return false
      end

      -- Check if cursor is positioned after / that starts a word
      local line = ctx.line
      local col = ctx.cursor[2]

      if col > 0 then
         local before_cursor = line:sub(1, col)
         -- Match patterns like: "/", "/un", "/unslop-co", "/skill:", "/cache:aw"
         -- But NOT "path/to" - the / must be at start of line or after whitespace
         local slash_match = before_cursor:match "/[%w:_%-]*$"
         if slash_match then
            local slash_pos = col - #slash_match + 1

            if slash_pos == 1 then
               -- / is at start of line
               return true
            elseif slash_pos > 1 then
               -- Check character before /
               local char_before = line:sub(slash_pos - 1, slash_pos - 1)
               if char_before:match "%s" then
                  return true
               end
            end
         end
      end

      return false
   end

   --- Constructor for the source
   --- @return blink.cmp.Source
   function source.new()
      local self = setmetatable({}, { __index = source })
      return self
   end

   --- Get trigger characters for this source
   --- @return string[]
   function source:get_trigger_characters()
      return opts.trigger_characters or { "/", ":" }
   end

   --- Get completions for the current context
   --- @param ctx blink.cmp.Context
   --- @param callback fun(response: blink.cmp.CompletionResponse)
   --- @return (fun(): nil)? cancel Optional async cancellation callback
   function source:get_completions(ctx, callback)
      local bufnr = vim.api.nvim_get_current_buf()

      if not should_show_completions(ctx, bufnr) then
         callback {
            is_incomplete_forward = false,
            is_incomplete_backward = false,
            items = {},
         }
         return nil
      end

      callback {
         is_incomplete_forward = false,
         is_incomplete_backward = false,
         items = get_cached_items(),
      }

      -- No async work to cancel
      return nil
   end

   --- Configure the source (for testing)
   --- @param o table Options with optional home_dir and nested_placeholders_supported
   function source.configure(o)
      if o.home_dir then
         config.home_dir = o.home_dir
      end
      if o.nested_placeholders_supported ~= nil then
         require("local_plugins.blink-agent-common.snippet").set_nested_placeholders(o.nested_placeholders_supported)
      end
   end

   --- Reset cache (for testing)
   function source.reset_cache()
      cache.items = nil
      cache.initialized = false
   end

   return source
end

return M
