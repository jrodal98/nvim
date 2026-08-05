-- ============================================================================
-- blink-agent-common/tests/harness: shared test utilities
-- ============================================================================
-- Used by the blink-claude and blink-pi test suites: assertions, target
-- buffer factory, source module reset, and the test runner. Fixture setup
-- stays in each suite (it is source-specific).
-- ============================================================================

local M = {}

-- ============================================================================
-- Assertions
-- ============================================================================

function M.assert_eq(actual, expected, message)
   if actual ~= expected then
      error(string.format("FAIL: %s\nExpected: %s\nActual: %s", message, tostring(expected), tostring(actual)))
   end
end

function M.assert_true(condition, message)
   if not condition then
      error("FAIL: " .. message)
   end
end

function M.assert_contains(haystack, needle, message)
   if type(haystack) == "table" then
      for _, v in ipairs(haystack) do
         if v == needle then
            return
         end
      end
      error(string.format("FAIL: %s\nNeedle '%s' not found in table", message, needle))
   elseif type(haystack) == "string" then
      if not haystack:find(needle, 1, true) then
         error(string.format("FAIL: %s\nNeedle '%s' not found in string", message, needle))
      end
   end
end

-- ============================================================================
-- Buffers and sources
-- ============================================================================

local buffer_counter = 0

--- Create a markdown buffer named /tmp/<prefix><N><suffix> and focus it
--- @param prefix string Basename prefix, e.g. "claude-prompt-test-"
--- @param suffix string|nil Basename suffix (default ".md")
--- @return number bufnr
function M.create_test_buffer(prefix, suffix)
   buffer_counter = buffer_counter + 1
   local bufnr = vim.api.nvim_create_buf(false, false)
   vim.api.nvim_buf_set_name(bufnr, "/tmp/" .. prefix .. buffer_counter .. (suffix or ".md"))
   vim.api.nvim_set_current_buf(bufnr)
   vim.bo[bufnr].filetype = "markdown"
   return bufnr
end

--- Reload a source module with a fixture home dir and cleared caches
--- @param module_name string e.g. "local_plugins.blink-pi"
--- @param fixtures {home: string}
--- @return blink.cmp.Source
function M.reset_module(module_name, fixtures)
   package.loaded[module_name] = nil
   local mod = require(module_name)
   mod.configure { home_dir = fixtures.home }
   mod.reset_cache()
   -- Also reset nested placeholder support cache
   mod.configure { nested_placeholders_supported = nil }
   ---@diagnostic disable-next-line: missing-parameter
   return mod.new()
end

--- Find a completion item by label
function M.find_item(items, label)
   for _, item in ipairs(items) do
      if item.label == label then
         return item
      end
   end
   return nil
end

--- Collect completion items synchronously
function M.get_items(source, ctx)
   local result
   source:get_completions(ctx, function(response)
      result = response.items
   end)
   return result or {}
end

-- ============================================================================
-- Runner
-- ============================================================================

--- Run a list of test functions, print a summary, and exit (0 or 1)
--- @param suite_name string e.g. "BLINK-PI TEST SUITE"
--- @param tests fun()[]
function M.run(suite_name, tests)
   print "═══════════════════════════════════════"
   print("  " .. suite_name)
   print "═══════════════════════════════════════\n"

   local passed = 0
   local failed = 0
   local errors = {}

   for _, test_fn in ipairs(tests) do
      local ok, err = pcall(test_fn)
      if ok then
         passed = passed + 1
      else
         failed = failed + 1
         table.insert(errors, err)
      end
   end

   print "\n═══════════════════════════════════════"
   print(string.format("  RESULTS: %d passed, %d failed", passed, failed))
   print "═══════════════════════════════════════"

   if #errors > 0 then
      print "\nFAILURES:\n"
      for i, err in ipairs(errors) do
         print(string.format("%d. %s\n", i, err))
      end
      os.exit(1)
   else
      print "\n✅ All tests passed!"
      os.exit(0)
   end
end

return M
