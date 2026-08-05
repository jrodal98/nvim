-- ============================================================================
-- Test Suite for blink-pi
-- ============================================================================
-- Run with: nvim --headless -c "lua require('local_plugins.blink-pi.tests.test_blink_pi').run_all_tests()"
-- ============================================================================

local M = {}

-- Test fixtures directory
local FIXTURES_DIR = "/tmp/blink-pi-test-fixtures"

-- ============================================================================
-- Test Fixtures Setup
-- ============================================================================

local function setup_fixtures()
   -- Clean up any existing fixtures
   vim.fn.delete(FIXTURES_DIR, "rf")
   vim.fn.mkdir(FIXTURES_DIR, "p")

   local home = FIXTURES_DIR .. "/home"
   local project = FIXTURES_DIR .. "/project"

   -- ==========================================================================
   -- Global prompt templates: ~/.pi/agent/prompts/*.md
   -- ==========================================================================
   vim.fn.mkdir(home .. "/.pi/agent/prompts", "p")

   vim.fn.writefile({
      "---",
      "description: Review staged git changes",
      "---",
      "Review the staged changes.",
   }, home .. "/.pi/agent/prompts/review.md")

   vim.fn.writefile({
      "This prompt has no frontmatter.",
      "",
      "More content.",
   }, home .. "/.pi/agent/prompts/no-frontmatter.md")

   vim.fn.writefile({
      "---",
      "description: Create a component",
      'argument-hint: "<NAME> [--variant STYLE]"',
      "---",
      "Create a component named $1",
   }, home .. "/.pi/agent/prompts/component.md")

   vim.fn.writefile({
      "",
      "---",
      "description: 'Single quoted with leading blank line'",
      "---",
      "Body",
   }, home .. "/.pi/agent/prompts/quoted.md")

   -- ==========================================================================
   -- Global skills: ~/.pi/agent/skills/ (dirs with SKILL.md + root .md files)
   -- ==========================================================================
   vim.fn.mkdir(home .. "/.pi/agent/skills/test-skill", "p")
   vim.fn.writefile({
      "---",
      "name: test-skill",
      "description: A test skill for unit testing",
      "---",
      "",
      "# Test Skill",
   }, home .. "/.pi/agent/skills/test-skill/SKILL.md")

   -- Root .md file as an individual skill
   vim.fn.writefile({
      "---",
      "name: root-md-skill",
      "description: A root markdown skill",
      "---",
   }, home .. "/.pi/agent/skills/root-md-skill.md")

   -- Nested skill (recursive discovery)
   vim.fn.mkdir(home .. "/.pi/agent/skills/group/nested-skill", "p")
   vim.fn.writefile({
      "---",
      "name: nested-skill",
      "description: A nested skill",
      "---",
   }, home .. "/.pi/agent/skills/group/nested-skill/SKILL.md")

   -- Frontmatter name overrides directory name
   vim.fn.mkdir(home .. "/.pi/agent/skills/dir-name", "p")
   vim.fn.writefile({
      "---",
      "name: renamed-skill",
      "description: Frontmatter name differs from directory",
      "---",
   }, home .. "/.pi/agent/skills/dir-name/SKILL.md")

   -- ==========================================================================
   -- Global agents skills: ~/.agents/skills/ (SKILL.md dirs only, root .md ignored)
   -- ==========================================================================
   vim.fn.mkdir(home .. "/.agents/skills/agents-skill", "p")
   vim.fn.writefile({
      "---",
      "name: agents-skill",
      "description: From agents dir",
      "---",
   }, home .. "/.agents/skills/agents-skill/SKILL.md")

   -- Root .md in .agents/skills should be IGNORED
   vim.fn.writefile({
      "---",
      "name: ignored-root-md",
      "description: Should not appear",
      "---",
   }, home .. "/.agents/skills/ignored-root-md.md")

   -- ==========================================================================
   -- Project: .pi/prompts and .pi/skills
   -- ==========================================================================
   vim.fn.mkdir(project .. "/.pi/prompts", "p")
   vim.fn.writefile({
      "---",
      "description: A project-local prompt",
      "---",
   }, project .. "/.pi/prompts/project-prompt.md")

   vim.fn.mkdir(project .. "/.pi/skills/project-skill", "p")
   vim.fn.writefile({
      "---",
      "name: project-skill",
      "description: A project-local skill",
      "---",
   }, project .. "/.pi/skills/project-skill/SKILL.md")

   -- Project .agents/skills
   vim.fn.mkdir(project .. "/.agents/skills/project-agents-skill", "p")
   vim.fn.writefile({
      "---",
      "name: project-agents-skill",
      "description: From project agents dir",
      "---",
   }, project .. "/.agents/skills/project-agents-skill/SKILL.md")

   -- ==========================================================================
   -- Settings-configured skills (e.g. ~/.claude/skills), with a SYMLINKED dir
   -- ==========================================================================
   vim.fn.mkdir(FIXTURES_DIR .. "/external-skills", "p")
   vim.fn.mkdir(FIXTURES_DIR .. "/actual-skill-storage/linked-skill", "p")
   vim.fn.writefile({
      "---",
      "name: linked-skill",
      "description: Reached through a symlink",
      "---",
   }, FIXTURES_DIR .. "/actual-skill-storage/linked-skill/SKILL.md")
   vim.uv.fs_symlink(
      FIXTURES_DIR .. "/actual-skill-storage/linked-skill",
      FIXTURES_DIR .. "/external-skills/linked-skill"
   )

   vim.fn.mkdir(FIXTURES_DIR .. "/external-skills/settings-skill", "p")
   vim.fn.writefile({
      "---",
      "name: settings-skill",
      "description: From settings dir",
      "---",
   }, FIXTURES_DIR .. "/external-skills/settings-skill/SKILL.md")

   vim.fn.writefile({
      vim.json.encode {
         skills = { FIXTURES_DIR .. "/external-skills" },
      },
   }, home .. "/.pi/agent/settings.json")

   -- Project settings with a relative skills path (resolved against .pi/)
   vim.fn.mkdir(project .. "/.claude/skills/claude-project-skill", "p")
   vim.fn.writefile({
      "---",
      "name: claude-project-skill",
      "description: Claude skills via project settings",
      "---",
   }, project .. "/.claude/skills/claude-project-skill/SKILL.md")

   vim.fn.writefile({
      vim.json.encode {
         skills = { "../.claude/skills" },
      },
   }, project .. "/.pi/settings.json")

   return {
      home = home,
      project = project,
   }
end

local function teardown_fixtures()
   vim.fn.delete(FIXTURES_DIR, "rf")
end

-- ============================================================================
-- Helper Functions (shared harness)
-- ============================================================================

local harness = require "local_plugins.blink-agent-common.tests.harness"

local assert_eq = harness.assert_eq
local assert_true = harness.assert_true
local assert_contains = harness.assert_contains
local find_item = harness.find_item
local get_items = harness.get_items

local function create_test_buffer()
   return harness.create_test_buffer("pi-editor-", ".pi.md")
end

local function reset_module(fixtures)
   return harness.reset_module("local_plugins.blink-pi", fixtures)
end

-- ============================================================================
-- Test Cases
-- ============================================================================

function M.test_prompt_templates()
   print "Test: Prompt Templates"

   local fixtures = setup_fixtures()
   vim.cmd("cd " .. fixtures.home)

   local source = reset_module(fixtures)
   local bufnr = create_test_buffer()
   local ctx = { line = "/", cursor = { 1, 1 }, bufnr = bufnr }
   local items = get_items(source, ctx)

   local review = find_item(items, "/review")
   assert_true(review ~= nil, "Found /review prompt template")
   assert_contains(review.documentation.value, "Review staged git changes", "Description from frontmatter")
   assert_contains(review.documentation.value, "(user)", "User scope")
   assert_eq(review.insertText, "/review", "Plain insert text without hint")

   local no_fm = find_item(items, "/no-frontmatter")
   assert_true(no_fm ~= nil, "Found /no-frontmatter prompt template")
   assert_contains(no_fm.documentation.value, "This prompt has no frontmatter", "First line fallback description")

   local quoted = find_item(items, "/quoted")
   assert_true(quoted ~= nil, "Found /quoted prompt template")
   assert_contains(quoted.documentation.value, "Single quoted with leading blank line", "Single quotes stripped")
   assert_true(not quoted.documentation.value:find("'", 1, true), "No quote chars in description")

   print "  ✓ Global prompt templates found"
   print "  ✓ Frontmatter descriptions parsed"
   print "  ✓ First-line fallback for missing description"
   print "  ✓ Single quotes and leading blank lines tolerated"

   teardown_fixtures()
end

function M.test_skills()
   print "\nTest: Skills"

   local fixtures = setup_fixtures()
   vim.cmd("cd " .. fixtures.home)

   local source = reset_module(fixtures)
   local bufnr = create_test_buffer()
   local ctx = { line = "/", cursor = { 1, 1 }, bufnr = bufnr }
   local items = get_items(source, ctx)

   -- Skills use /skill:name format
   local skill = find_item(items, "/skill:test-skill")
   assert_true(skill ~= nil, "Found /skill:test-skill")
   assert_contains(skill.documentation.value, "A test skill for unit testing", "Skill description")
   assert_eq(skill.insertText, "/skill:test-skill", "Skill inserts /skill:name")

   -- Root .md skill in ~/.pi/agent/skills
   assert_true(find_item(items, "/skill:root-md-skill") ~= nil, "Found root .md skill")

   -- Nested skill (recursive discovery)
   assert_true(find_item(items, "/skill:nested-skill") ~= nil, "Found nested skill")

   -- Frontmatter name wins over directory name
   assert_true(find_item(items, "/skill:renamed-skill") ~= nil, "Frontmatter name used")
   assert_true(find_item(items, "/skill:dir-name") == nil, "Directory name not used when frontmatter name set")

   -- ~/.agents/skills: SKILL.md dirs found, root .md ignored
   assert_true(find_item(items, "/skill:agents-skill") ~= nil, "Found ~/.agents/skills skill")
   assert_true(find_item(items, "/skill:ignored-root-md") == nil, "Root .md ignored in .agents/skills")

   print "  ✓ Skills complete as /skill:name"
   print "  ✓ Root .md skills in ~/.pi/agent/skills"
   print "  ✓ Recursive SKILL.md discovery"
   print "  ✓ Frontmatter name overrides directory name"
   print "  ✓ ~/.agents/skills scanned (root .md ignored)"

   teardown_fixtures()
end

function M.test_symlinked_skills()
   print "\nTest: Symlinked Skills"

   local fixtures = setup_fixtures()
   vim.cmd("cd " .. fixtures.home)

   local source = reset_module(fixtures)
   local bufnr = create_test_buffer()
   local ctx = { line = "/", cursor = { 1, 1 }, bufnr = bufnr }
   local items = get_items(source, ctx)

   local linked = find_item(items, "/skill:linked-skill")
   assert_true(linked ~= nil, "Found skill behind a symlinked directory")
   assert_contains(linked.documentation.value, "Reached through a symlink", "Symlinked skill description")

   print "  ✓ Symlinked skill directories are followed"

   teardown_fixtures()
end

function M.test_settings_skills()
   print "\nTest: Settings-Configured Skills"

   local fixtures = setup_fixtures()
   vim.cmd("cd " .. fixtures.home)

   local source = reset_module(fixtures)
   local bufnr = create_test_buffer()
   local ctx = { line = "/", cursor = { 1, 1 }, bufnr = bufnr }
   local items = get_items(source, ctx)

   local settings_skill = find_item(items, "/skill:settings-skill")
   assert_true(settings_skill ~= nil, "Found skill from global settings.json skills array")
   assert_contains(settings_skill.documentation.value, "(settings)", "Settings scope label")

   -- Project settings with relative path: only when inside the project
   assert_true(find_item(items, "/skill:claude-project-skill") == nil, "Project settings skill absent outside project")

   vim.cmd("cd " .. fixtures.project)
   source = reset_module(fixtures)
   create_test_buffer()
   items = get_items(source, ctx)

   assert_true(find_item(items, "/skill:claude-project-skill") ~= nil, "Project settings skill found via relative path")

   print "  ✓ Global settings.json skills array scanned"
   print "  ✓ Project .pi/settings.json relative paths resolved"

   teardown_fixtures()
end

function M.test_project_locations()
   print "\nTest: Project Locations"

   local fixtures = setup_fixtures()

   -- Test from a nested directory to verify ancestor walking
   vim.fn.mkdir(fixtures.project .. "/src/deep", "p")
   vim.cmd("cd " .. fixtures.project .. "/src/deep")

   local source = reset_module(fixtures)
   local bufnr = create_test_buffer()
   local ctx = { line = "/", cursor = { 1, 1 }, bufnr = bufnr }
   local items = get_items(source, ctx)

   local project_prompt = find_item(items, "/project-prompt")
   assert_true(project_prompt ~= nil, "Found project prompt from nested cwd")
   assert_contains(project_prompt.documentation.value, "(project)", "Project scope label")

   assert_true(find_item(items, "/skill:project-skill") ~= nil, "Found project .pi/skills skill")
   assert_true(find_item(items, "/skill:project-agents-skill") ~= nil, "Found project .agents/skills skill")

   -- Global items still present
   assert_true(find_item(items, "/review") ~= nil, "Global prompts still found")
   assert_true(find_item(items, "/skill:test-skill") ~= nil, "Global skills still found")

   print "  ✓ Walks up directory tree from cwd"
   print "  ✓ Project .pi/prompts, .pi/skills, .agents/skills found"
   print "  ✓ Global and project items merged"

   teardown_fixtures()
end

function M.test_trigger_logic()
   print "\nTest: Trigger Logic"

   local fixtures = setup_fixtures()
   vim.cmd("cd " .. fixtures.home)

   local source = reset_module(fixtures)
   local bufnr = create_test_buffer()

   local test_cases = {
      { line = "/", col = 1, should_trigger = true, desc = "/ at start" },
      { line = "/rev", col = 4, should_trigger = true, desc = "/rev at start" },
      { line = "/skill:", col = 7, should_trigger = true, desc = "/skill: continuation" },
      { line = "/skill:test-sk", col = 14, should_trigger = true, desc = "/skill:name with hyphen" },
      { line = "Try /cmd", col = 8, should_trigger = true, desc = "/ after space" },
      { line = "  /", col = 3, should_trigger = true, desc = "/ after indent" },
      { line = "path/to", col = 7, should_trigger = false, desc = "/ in path" },
      { line = "abc/def", col = 7, should_trigger = false, desc = "/ in middle" },
   }

   for _, test in ipairs(test_cases) do
      local ctx = { line = test.line, cursor = { 1, test.col }, bufnr = bufnr }
      local items = get_items(source, ctx)
      local triggered = #items > 0
      assert_eq(triggered, test.should_trigger, test.desc)
   end

   print "  ✓ Triggers at word start and after whitespace"
   print "  ✓ Triggers through /skill: continuation"
   print "  ✓ Does not trigger in paths"

   teardown_fixtures()
end

function M.test_filename_filtering()
   print "\nTest: Filename Filtering"

   local fixtures = setup_fixtures()
   vim.cmd("cd " .. fixtures.home)

   local source = reset_module(fixtures)

   -- pi-editor buffer: should show
   local bufnr1 = create_test_buffer()
   local ctx1 = { line = "/", cursor = { 1, 1 }, bufnr = bufnr1 }
   assert_true(#get_items(source, ctx1) > 0, "Shows completions in pi-editor file")

   -- Regular markdown buffer: should not show
   local bufnr2 = harness.create_test_buffer "regular-"

   local ctx2 = { line = "/", cursor = { 1, 1 }, bufnr = bufnr2 }
   assert_eq(#get_items(source, ctx2), 0, "No completions in regular markdown file")

   -- claude-prompt buffer: should not show (that's blink-claude's turf)
   local bufnr3 = harness.create_test_buffer "claude-prompt-"

   local ctx3 = { line = "/", cursor = { 1, 1 }, bufnr = bufnr3 }
   assert_eq(#get_items(source, ctx3), 0, "No completions in claude-prompt file")

   print "  ✓ Shows in pi-editor* files"
   print "  ✓ Hides in other markdown files"

   teardown_fixtures()
end

function M.test_deduplication()
   print "\nTest: Deduplication"

   local fixtures = setup_fixtures()

   -- Same skill name in global and project locations
   vim.fn.mkdir(fixtures.home .. "/.pi/agent/skills/duplicate", "p")
   vim.fn.writefile({
      "---",
      "name: duplicate",
      "description: Original",
      "---",
   }, fixtures.home .. "/.pi/agent/skills/duplicate/SKILL.md")

   vim.fn.mkdir(fixtures.project .. "/.pi/skills/duplicate", "p")
   vim.fn.writefile({
      "---",
      "name: duplicate",
      "description: Duplicate",
      "---",
   }, fixtures.project .. "/.pi/skills/duplicate/SKILL.md")

   vim.cmd("cd " .. fixtures.project)

   local source = reset_module(fixtures)
   local bufnr = create_test_buffer()
   local ctx = { line = "/", cursor = { 1, 1 }, bufnr = bufnr }
   local items = get_items(source, ctx)

   local count = 0
   for _, item in ipairs(items) do
      if item.label == "/skill:duplicate" then
         count = count + 1
      end
   end

   assert_eq(count, 1, "Duplicate labels deduplicated")

   print "  ✓ Deduplicates same label from multiple sources"

   teardown_fixtures()
end

function M.test_argument_hints()
   print "\nTest: Argument Hints"

   local fixtures = setup_fixtures()
   vim.cmd("cd " .. fixtures.home)

   local source = reset_module(fixtures)
   local bufnr = create_test_buffer()
   local ctx = { line = "/", cursor = { 1, 1 }, bufnr = bufnr }
   local items = get_items(source, ctx)

   local has_luasnip = pcall(require, "luasnip")

   local component = find_item(items, "/component")
   assert_true(component ~= nil, "Found /component with argument hint")
   assert_eq(component.kind, vim.lsp.protocol.CompletionItemKind.Snippet, "Kind is Snippet")
   assert_eq(component.insertTextFormat, vim.lsp.protocol.InsertTextFormat.Snippet, "Uses Snippet format")
   assert_contains(component.documentation.value, "Usage:", "Hint shown in documentation")
   assert_contains(component.documentation.value, "<NAME> [--variant STYLE]", "Full hint in documentation")

   -- <NAME> angle brackets stripped in placeholder
   assert_contains(component.insertText, "${1:NAME}", "Required arg as tab stop 1 without angle brackets")

   if has_luasnip then
      assert_contains(component.insertText, "${2:--variant ${3:STYLE}}", "Nested snippet for optional flag")
   else
      assert_contains(component.insertText, "${2:--variant STYLE}", "Simple placeholder for optional flag")
   end

   -- Template without hint: plain text
   local review = find_item(items, "/review")
   assert_eq(review.insertTextFormat, vim.lsp.protocol.InsertTextFormat.PlainText, "PlainText without hint")
   assert_true(not review.insertText:match "%$%{", "No snippet syntax without hint")
   assert_true(not review.documentation.value:match "Usage:", "No usage section without hint")

   print "  ✓ argument-hint converted to snippet tab stops"
   print "  ✓ <angle brackets> stripped from placeholders"
   print "  ✓ Plain text fallback without hint"

   teardown_fixtures()
end

function M.test_sorting_and_caching()
   print "\nTest: Sorting and Caching"

   local fixtures = setup_fixtures()
   vim.cmd("cd " .. fixtures.home)

   local source = reset_module(fixtures)
   local bufnr = create_test_buffer()
   local ctx = { line = "/", cursor = { 1, 1 }, bufnr = bufnr }

   local items = get_items(source, ctx)
   for i = 2, #items do
      assert_true(items[i].label >= items[i - 1].label, "Items sorted alphabetically at position " .. i)
   end

   local second = get_items(source, ctx)
   assert_eq(#items, #second, "Cache returns same count")
   assert_true(#items > 0, "Cache has items")

   print "  ✓ All items sorted alphabetically"
   print "  ✓ Subsequent calls use cache"

   teardown_fixtures()
end

-- ============================================================================
-- Test Runner
-- ============================================================================

function M.run_all_tests()
   harness.run("BLINK-PI TEST SUITE", {
      M.test_prompt_templates,
      M.test_skills,
      M.test_symlinked_skills,
      M.test_settings_skills,
      M.test_project_locations,
      M.test_trigger_logic,
      M.test_filename_filtering,
      M.test_deduplication,
      M.test_argument_hints,
      M.test_sorting_and_caching,
   })
end

return M
