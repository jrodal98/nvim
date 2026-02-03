-- ============================================================================
-- Test Suite for blink-claude
-- ============================================================================
-- Run with: nvim --headless -c "lua require('local_plugins.blink-claude.tests.test_blink_claude').run_all_tests()"
-- ============================================================================

local M = {}

-- Test fixtures directory
local FIXTURES_DIR = "/tmp/blink-claude-test-fixtures"

-- ============================================================================
-- Test Fixtures Setup
-- ============================================================================

local function setup_fixtures()
  -- Clean up any existing fixtures
  vim.fn.delete(FIXTURES_DIR, "rf")
  vim.fn.mkdir(FIXTURES_DIR, "p")

  -- Create .claude directories structure
  local home_claude = FIXTURES_DIR .. "/home/.claude"
  local project_claude = FIXTURES_DIR .. "/project/.claude"

  -- Create user skills
  vim.fn.mkdir(home_claude .. "/skills/test-skill", "p")
  vim.fn.writefile({
    "---",
    "name: test-skill",
    "description: A test skill for unit testing",
    "---",
    "",
    "# Test Skill",
  }, home_claude .. "/skills/test-skill/SKILL.md")

  vim.fn.mkdir(home_claude .. "/skills/multiline-desc", "p")
  vim.fn.writefile({
    "---",
    "name: multiline-desc",
    "description:",
    "  This is a multi-line description",
    "  that spans several lines",
    "  for testing purposes",
    "allowed-tools: Bash",
    "---",
  }, home_claude .. "/skills/multiline-desc/SKILL.md")

  -- Create user commands
  vim.fn.mkdir(home_claude .. "/commands", "p")
  vim.fn.writefile({
    "---",
    'description: "A quoted description"',
    "---",
    "",
    "# Test Command",
  }, home_claude .. "/commands/test-cmd.md")

  vim.fn.writefile({
    "This is a command without frontmatter.",
    "",
    "It should use the first line as description.",
  }, home_claude .. "/commands/no-frontmatter.md")

  vim.fn.writefile({
    "---",
    "description: Command with arguments",
    'argument-hint: "PROMPT [--option VALUE]"',
    "---",
  }, home_claude .. "/commands/with-args.md")

  vim.fn.writefile({
    "---",
    "description: Command with multiple optional args for testing nested snippets",
    'argument-hint: "TASK [--max-iterations N] [--completion-promise TEXT] [--auto-fix]"',
    "---",
  }, home_claude .. "/commands/nested-args.md")

  vim.fn.writefile({
    "---",
    "description: Command with very long argument hint that should be truncated in the menu",
    'argument-hint: "VERY_LONG_ARGUMENT_NAME [--very-long-option VERY_LONG_VALUE] [--another-option MORE_VALUES]"',
    "---",
  }, home_claude .. "/commands/long-hint.md")

  -- Create project-local skills
  vim.fn.mkdir(project_claude .. "/skills/project-skill", "p")
  vim.fn.writefile({
    "---",
    "name: project-skill",
    "description: A project-local skill",
    "---",
  }, project_claude .. "/skills/project-skill/SKILL.md")

  -- Create plugins directory and installed_plugins.json
  vim.fn.mkdir(home_claude .. "/plugins", "p")
  local plugins_json = {
    version = 2,
    plugins = {
      ["test-plugin@test-source"] = {
        {
          scope = "user",
          installPath = FIXTURES_DIR .. "/plugins/test-plugin/1.0.0",
          version = "1.0.0",
        }
      },
      ["project-plugin@meta"] = {
        {
          scope = "project",
          projectPath = FIXTURES_DIR .. "/project",
          installPath = FIXTURES_DIR .. "/plugins/project-plugin/1.0.0",
          version = "1.0.0",
        }
      },
    }
  }

  vim.fn.writefile(
    { vim.json.encode(plugins_json) },
    home_claude .. "/plugins/installed_plugins.json"
  )

  -- Create plugin skills and commands
  vim.fn.mkdir(FIXTURES_DIR .. "/plugins/test-plugin/1.0.0/commands", "p")
  vim.fn.writefile({
    "---",
    'description: "Plugin command description"',
    "---",
  }, FIXTURES_DIR .. "/plugins/test-plugin/1.0.0/commands/plugin-cmd.md")

  vim.fn.mkdir(FIXTURES_DIR .. "/plugins/test-plugin/1.0.0/skills/plugin-skill", "p")
  vim.fn.writefile({
    "---",
    "name: plugin-skill",
    "description: Plugin skill description",
    "---",
  }, FIXTURES_DIR .. "/plugins/test-plugin/1.0.0/skills/plugin-skill/SKILL.md")

  vim.fn.mkdir(FIXTURES_DIR .. "/plugins/project-plugin/1.0.0/skills/proj-skill", "p")
  vim.fn.writefile({
    "---",
    "name: proj-skill",
    "description: Project plugin skill",
    "---",
  }, FIXTURES_DIR .. "/plugins/project-plugin/1.0.0/skills/proj-skill/SKILL.md")

  return {
    home = FIXTURES_DIR .. "/home",
    project = FIXTURES_DIR .. "/project",
  }
end

local function teardown_fixtures()
  vim.fn.delete(FIXTURES_DIR, "rf")
end

-- ============================================================================
-- Helper Functions
-- ============================================================================

local test_counter = 0

local function create_test_buffer()
  test_counter = test_counter + 1
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(bufnr, "/tmp/claude-prompt-test-" .. test_counter .. ".md")
  vim.api.nvim_set_current_buf(bufnr)
  vim.bo[bufnr].filetype = "markdown"
  return bufnr
end

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    error(string.format("FAIL: %s\nExpected: %s\nActual: %s", message, tostring(expected), tostring(actual)))
  end
end

local function assert_true(condition, message)
  if not condition then
    error("FAIL: " .. message)
  end
end

local function assert_contains(haystack, needle, message)
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

local function reset_module(fixtures)
  package.loaded['local_plugins.blink-claude'] = nil
  local blink_claude = require('local_plugins.blink-claude')
  blink_claude.configure({ home_dir = fixtures.home })
  blink_claude.reset_cache()
  -- Also reset nested placeholder support cache
  blink_claude.configure({ nested_placeholders_supported = nil })
  return blink_claude.new()
end

-- ============================================================================
-- Test Cases
-- ============================================================================

function M.test_yaml_parsing()
  print("Test: YAML Parsing")

  local fixtures = setup_fixtures()
  vim.cmd("cd " .. fixtures.home)

  local source = reset_module(fixtures)
  local bufnr = create_test_buffer()
  local ctx = { line = "/", cursor = {1, 1}, bufnr = bufnr }

  source:get_completions(ctx, function(response)
    local items = response.items

    -- Find test-skill (single-line description)
    local found_single = false
    for _, item in ipairs(items) do
      if item.label == "/test-skill" then
        found_single = true
        assert_contains(item.documentation.value, "A test skill for unit testing", "Single-line description")
        break
      end
    end
    assert_true(found_single, "Found test-skill with single-line description")

    -- Find multiline-desc (multi-line description)
    local found_multi = false
    for _, item in ipairs(items) do
      if item.label == "/multiline-desc" then
        found_multi = true
        assert_contains(item.documentation.value, "multi-line description", "Multi-line description")
        assert_contains(item.documentation.value, "spans several lines", "Multi-line description continuation")
        break
      end
    end
    assert_true(found_multi, "Found multiline-desc with multi-line description")

    -- Find test-cmd (quoted description)
    local found_quoted = false
    for _, item in ipairs(items) do
      if item.label == "/test-cmd" then
        found_quoted = true
        assert_contains(item.documentation.value, "A quoted description", "Quoted description")
        -- Should not contain quotes
        assert_true(not item.documentation.value:match('^"'), "Quotes removed from description")
        break
      end
    end
    assert_true(found_quoted, "Found test-cmd with quoted description")

    -- Find no-frontmatter (fallback to first line)
    local found_no_fm = false
    for _, item in ipairs(items) do
      if item.label == "/no-frontmatter" then
        found_no_fm = true
        assert_contains(item.documentation.value, "This is a command without frontmatter", "No frontmatter fallback")
        break
      end
    end
    assert_true(found_no_fm, "Found no-frontmatter with first line as description")

    print("  ✓ Single-line YAML descriptions")
    print("  ✓ Multi-line YAML descriptions")
    print("  ✓ Quoted descriptions (quotes removed)")
    print("  ✓ Fallback to first content line")
  end)

  teardown_fixtures()
end

function M.test_scope_detection()
  print("\nTest: Scope Detection")

  local fixtures = setup_fixtures()
  vim.cmd("cd " .. fixtures.project)

  local source = reset_module(fixtures)
  local bufnr = create_test_buffer()
  local ctx = { line = "/", cursor = {1, 1}, bufnr = bufnr }

  source:get_completions(ctx, function(response)
    local items = response.items

    -- test-skill should be (user) - from ~/.claude
    for _, item in ipairs(items) do
      if item.label == "/test-skill" then
        assert_contains(item.documentation.value, "(user)", "test-skill marked as user")
        break
      end
    end

    -- project-skill should be (project) - from project/.claude
    for _, item in ipairs(items) do
      if item.label == "/project-skill" then
        assert_contains(item.documentation.value, "(project)", "project-skill marked as project")
        break
      end
    end

    print("  ✓ User scope for ~/.claude items")
    print("  ✓ Project scope for tree-walk items")
  end)

  teardown_fixtures()
end

function M.test_plugin_parsing()
  print("\nTest: Plugin Parsing")

  local fixtures = setup_fixtures()
  vim.cmd("cd " .. fixtures.home)

  local source = reset_module(fixtures)
  local bufnr = create_test_buffer()
  local ctx = { line = "/", cursor = {1, 1}, bufnr = bufnr }

  source:get_completions(ctx, function(response)
    local items = response.items

    -- Find user-scoped plugin
    local found_user_plugin = false
    for _, item in ipairs(items) do
      if item.label == "/test-plugin:plugin-skill" then
        found_user_plugin = true
        assert_contains(item.documentation.value, "(plugin:test-plugin@test-source)", "Plugin source attribution")
        break
      end
    end
    assert_true(found_user_plugin, "Found user-scoped plugin")

    -- Project-scoped plugin should NOT appear when in home dir
    local found_project_plugin = false
    for _, item in ipairs(items) do
      if item.label:match("^/project%-plugin:") then
        found_project_plugin = true
        break
      end
    end
    assert_true(not found_project_plugin, "Project plugin filtered out when not in project")

    print("  ✓ User-scoped plugins loaded")
    print("  ✓ Project-scoped plugins filtered by path")
    print("  ✓ Plugin source attribution correct")
  end)

  -- Now test from project directory
  vim.cmd("cd " .. fixtures.project)
  source = reset_module(fixtures)
  bufnr = create_test_buffer()

  source:get_completions(ctx, function(response)
    local items = response.items

    -- Project plugin should appear now
    local found_in_project = false
    for _, item in ipairs(items) do
      if item.label == "/project-plugin:proj-skill" then
        found_in_project = true
        assert_contains(item.documentation.value, "(plugin:project-plugin@meta)", "Project plugin source")
        break
      end
    end
    assert_true(found_in_project, "Project plugin appears when in project dir")

    print("  ✓ Project plugins appear when cwd matches")
  end)

  teardown_fixtures()
end

function M.test_trigger_logic()
  print("\nTest: Trigger Logic")

  local fixtures = setup_fixtures()
  vim.cmd("cd " .. fixtures.home)

  local source = reset_module(fixtures)
  local bufnr = create_test_buffer()

  local test_cases = {
    { line = "/", col = 1, should_trigger = true, desc = "/ at start" },
    { line = "/test", col = 5, should_trigger = true, desc = "/test at start" },
    { line = "Try /cmd", col = 8, should_trigger = true, desc = "/ after space" },
    { line = "  /", col = 3, should_trigger = true, desc = "/ after indent" },
    { line = "path/to", col = 7, should_trigger = false, desc = "/ in path" },
    { line = "abc/def", col = 7, should_trigger = false, desc = "/ in middle" },
  }

  for _, test in ipairs(test_cases) do
    local ctx = { line = test.line, cursor = {1, test.col}, bufnr = bufnr }

    local item_count = 0
    source:get_completions(ctx, function(response)
      item_count = #response.items
    end)

    local triggered = item_count > 0
    assert_eq(triggered, test.should_trigger, test.desc)
  end

  print("  ✓ Triggers at word start")
  print("  ✓ Triggers after whitespace")
  print("  ✓ Does not trigger in middle of word")

  teardown_fixtures()
end

function M.test_filename_filtering()
  print("\nTest: Filename Filtering")

  local fixtures = setup_fixtures()
  vim.cmd("cd " .. fixtures.home)

  local source = reset_module(fixtures)

  -- Test with claude-prompt file
  local bufnr1 = create_test_buffer()
  local ctx1 = { line = "/", cursor = {1, 1}, bufnr = bufnr1 }
  local should_show_count = 0
  source:get_completions(ctx1, function(response)
    should_show_count = #response.items
  end)

  assert_true(should_show_count > 0, "Shows completions in claude-prompt file")

  -- Test with regular markdown file
  test_counter = test_counter + 1
  local bufnr2 = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(bufnr2, "/tmp/regular-" .. test_counter .. ".md")
  vim.api.nvim_set_current_buf(bufnr2)
  vim.bo[bufnr2].filetype = "markdown"

  local ctx2 = { line = "/", cursor = {1, 1}, bufnr = bufnr2 }
  local should_not_show_count = 0
  source:get_completions(ctx2, function(response)
    should_not_show_count = #response.items
  end)

  assert_eq(should_not_show_count, 0, "No completions in regular file")

  print("  ✓ Shows in claude-prompt*.md files")
  print("  ✓ Hides in other markdown files")

  teardown_fixtures()
end

function M.test_deduplication()
  print("\nTest: Deduplication")

  local fixtures = setup_fixtures()

  -- Create duplicate skill (symlink simulation)
  local home_claude = FIXTURES_DIR .. "/home/.claude"
  vim.fn.mkdir(home_claude .. "/skills/duplicate", "p")
  vim.fn.writefile({
    "---",
    "name: duplicate",
    "description: Original",
    "---",
  }, home_claude .. "/skills/duplicate/SKILL.md")

  -- Create another with same name in project (should be deduplicated)
  local project_claude = FIXTURES_DIR .. "/project/.claude"
  vim.fn.mkdir(project_claude .. "/skills/duplicate", "p")
  vim.fn.writefile({
    "---",
    "name: duplicate",
    "description: Duplicate",
    "---",
  }, project_claude .. "/skills/duplicate/SKILL.md")

  vim.cmd("cd " .. fixtures.project)

  local source = reset_module(fixtures)
  local bufnr = create_test_buffer()
  local ctx = { line = "/", cursor = {1, 1}, bufnr = bufnr }

  source:get_completions(ctx, function(response)
    local items = response.items

    -- Count occurrences of /duplicate
    local count = 0
    for _, item in ipairs(items) do
      if item.label == "/duplicate" then
        count = count + 1
      end
    end

    assert_eq(count, 1, "Duplicate labels deduplicated")

    print("  ✓ Deduplicates same label from multiple sources")
  end)

  teardown_fixtures()
end

function M.test_tree_walking()
  print("\nTest: Tree Walking")

  local fixtures = setup_fixtures()

  -- Create nested .claude directories
  vim.fn.mkdir(FIXTURES_DIR .. "/project/nested/.claude/skills/nested-skill", "p")
  vim.fn.writefile({
    "---",
    "name: nested-skill",
    "description: From nested dir",
    "---",
  }, FIXTURES_DIR .. "/project/nested/.claude/skills/nested-skill/SKILL.md")

  vim.cmd("cd " .. FIXTURES_DIR .. "/project/nested")

  local source = reset_module(fixtures)
  local bufnr = create_test_buffer()
  local ctx = { line = "/", cursor = {1, 1}, bufnr = bufnr }

  source:get_completions(ctx, function(response)
    local items = response.items

    -- Should find items from all three levels:
    -- 1. ~/.claude (user)
    -- 2. project/.claude (project)
    -- 3. project/nested/.claude (project)

    local found = { user = false, project_root = false, project_nested = false }

    for _, item in ipairs(items) do
      if item.label == "/test-skill" and item.documentation.value:match("%(user%)") then
        found.user = true
      elseif item.label == "/project-skill" then
        found.project_root = true
      elseif item.label == "/nested-skill" then
        found.project_nested = true
      end
    end

    assert_true(found.user, "Found items from ~/.claude")
    assert_true(found.project_root, "Found items from project/.claude")
    assert_true(found.project_nested, "Found items from project/nested/.claude")

    print("  ✓ Walks up directory tree")
    print("  ✓ Includes all .claude directories found")
    print("  ✓ Correctly scopes ~/.claude as user")
  end)

  teardown_fixtures()
end

function M.test_alphabetical_sorting()
  print("\nTest: Alphabetical Sorting")

  local fixtures = setup_fixtures()
  vim.cmd("cd " .. fixtures.home)

  local source = reset_module(fixtures)
  local bufnr = create_test_buffer()
  local ctx = { line = "/", cursor = {1, 1}, bufnr = bufnr }

  source:get_completions(ctx, function(response)
    local items = response.items

    -- Verify items are sorted
    for i = 2, #items do
      assert_true(items[i].label >= items[i-1].label, "Items sorted alphabetically at position " .. i)
    end

    print("  ✓ All items sorted alphabetically")
  end)

  teardown_fixtures()
end

function M.test_caching()
  print("\nTest: Session Caching")

  local fixtures = setup_fixtures()
  vim.cmd("cd " .. fixtures.home)

  local source = reset_module(fixtures)
  local bufnr = create_test_buffer()
  local ctx = { line = "/", cursor = {1, 1}, bufnr = bufnr }

  local first_call_count = 0
  source:get_completions(ctx, function(response)
    first_call_count = #response.items
  end)

  -- Second call should use cache (without reset)
  local second_call_count = 0
  source:get_completions(ctx, function(response)
    second_call_count = #response.items
  end)

  assert_eq(first_call_count, second_call_count, "Cache returns same count")
  assert_true(first_call_count > 0, "Cache has items")

  print("  ✓ Cache initialized on first call")
  print("  ✓ Subsequent calls use cache")

  teardown_fixtures()
end

function M.test_argument_hints()
  print("\nTest: Argument Hints")

  local fixtures = setup_fixtures()
  vim.cmd("cd " .. fixtures.home)

  local source = reset_module(fixtures)
  local bufnr = create_test_buffer()
  local ctx = { line = "/", cursor = {1, 1}, bufnr = bufnr }

  -- Check if LuaSnip is available for nested placeholder support
  local has_luasnip = pcall(require, 'luasnip')

  source:get_completions(ctx, function(response)
    local items = response.items

    -- Test command with simple argument hint
    local found_with_args = false
    for _, item in ipairs(items) do
      if item.label == "/with-args" then
        found_with_args = true

        -- Should show hint in labelDetails.detail
        assert_true(item.labelDetails.detail ~= nil, "Argument hint present in labelDetails.detail")
        assert_contains(item.labelDetails.detail, "PROMPT", "Hint contains PROMPT")
        assert_contains(item.labelDetails.detail, "[--option VALUE]", "Hint contains option")

        -- Should use Snippet insertTextFormat
        assert_eq(item.insertTextFormat, vim.lsp.protocol.InsertTextFormat.Snippet, "Uses Snippet format")

        -- Should have correct tab stops based on LuaSnip availability
        assert_contains(item.insertText, "${1:PROMPT}", "Required arg as tab stop 1")

        if has_luasnip then
          -- With LuaSnip: nested placeholders
          assert_contains(item.insertText, "${2:--option ${3:VALUE}}", "Nested snippet for optional flag with value")
        else
          -- Without LuaSnip: simple sequential placeholders
          assert_contains(item.insertText, "${2:--option VALUE}", "Simple placeholder for optional flag")
        end

        break
      end
    end
    assert_true(found_with_args, "Found command with argument hint")

    -- Test multiple optional args
    local found_nested = false
    for _, item in ipairs(items) do
      if item.label == "/nested-args" then
        found_nested = true

        assert_contains(item.insertText, "${1:TASK}", "Required arg TASK")

        if has_luasnip then
          -- With LuaSnip: nested placeholders
          assert_contains(item.insertText, "${2:--max-iterations ${3:N}}", "Nested snippet for --max-iterations N")
          assert_contains(item.insertText, "${4:--completion-promise ${5:TEXT}}", "Nested snippet for --completion-promise TEXT")
          assert_contains(item.insertText, "${6:--auto-fix}", "Simple optional flag without value")
        else
          -- Without LuaSnip: simple sequential placeholders
          assert_contains(item.insertText, "${2:--max-iterations N}", "Simple placeholder for --max-iterations N")
          assert_contains(item.insertText, "${3:--completion-promise TEXT}", "Simple placeholder for --completion-promise TEXT")
          assert_contains(item.insertText, "${4:--auto-fix}", "Simple optional flag")
        end

        break
      end
    end
    assert_true(found_nested, "Found command with tab stops")

    -- Test long hint truncation
    local found_long_hint = false
    for _, item in ipairs(items) do
      if item.label == "/long-hint" then
        found_long_hint = true

        -- Detail should be truncated to 50 chars
        assert_true(#item.labelDetails.detail <= 50, "Long hint truncated in detail")
        assert_contains(item.labelDetails.detail, "...", "Truncation indicator present")

        -- InsertText should have full snippet (not truncated)
        assert_contains(item.insertText, "VERY_LONG_ARGUMENT_NAME", "Full hint in insertText")
        assert_contains(item.insertText, "${1:", "Tab stops in full snippet")

        break
      end
    end
    assert_true(found_long_hint, "Found command with long hint")

    -- Test command without hint (backward compatibility)
    local found_no_hint = false
    for _, item in ipairs(items) do
      if item.label == "/test-cmd" then
        found_no_hint = true

        -- Should NOT have detail
        assert_true(item.labelDetails.detail == nil, "No hint means no detail")

        -- Should use PlainText format
        assert_eq(item.insertTextFormat, vim.lsp.protocol.InsertTextFormat.PlainText, "Uses PlainText format")

        -- Should not have snippet syntax
        assert_true(not item.insertText:match("%$%{"), "No snippet syntax in insertText")

        break
      end
    end
    assert_true(found_no_hint, "Found command without hint")

    if has_luasnip then
      print("  ✓ Argument hints shown in labelDetails.detail")
      print("  ✓ Snippet format used for commands with hints")
      print("  ✓ Nested tab stops for optional args with values (LuaSnip)")
      print("  ✓ Simple tab stops for optional flags without values")
      print("  ✓ VSCode-style select mode with nested placeholders")
    else
      print("  ✓ Argument hints shown in labelDetails.detail")
      print("  ✓ Snippet format used for commands with hints")
      print("  ✓ Sequential tab stops (LuaSnip not available)")
      print("  ✓ Fallback to simple placeholders works correctly")
    end
    print("  ✓ Long hints truncated in display")
    print("  ✓ Full hints preserved in insertText")
    print("  ✓ Backward compatible with commands without hints")
  end)

  teardown_fixtures()
end

-- ============================================================================
-- Test Runner
-- ============================================================================

function M.run_all_tests()
  print("═══════════════════════════════════════")
  print("  BLINK-CLAUDE TEST SUITE")
  print("═══════════════════════════════════════\n")

  local tests = {
    M.test_yaml_parsing,
    M.test_scope_detection,
    M.test_plugin_parsing,
    M.test_trigger_logic,
    M.test_filename_filtering,
    M.test_deduplication,
    M.test_tree_walking,
    M.test_alphabetical_sorting,
    M.test_caching,
    M.test_argument_hints,
  }

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

  print("\n═══════════════════════════════════════")
  print(string.format("  RESULTS: %d passed, %d failed", passed, failed))
  print("═══════════════════════════════════════")

  if #errors > 0 then
    print("\nFAILURES:\n")
    for i, err in ipairs(errors) do
      print(string.format("%d. %s\n", i, err))
    end
    os.exit(1)
  else
    print("\n✅ All tests passed!")
    os.exit(0)
  end
end

return M
