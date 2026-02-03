# blink-claude

A blink.cmp completion source for Claude Code skills and commands.

## Features

- ✅ Autocomplete `/skill-name` and `/command-name` in claude-prompt* markdown files
- ✅ **Plugin format**: `/plugin-name:skill` or `/plugin-name:command` for plugin items
- ✅ **Shows "Claude" hint** in completion menu (not "Text")
- ✅ Scans `~/.claude/skills/`, `~/.claude/commands/`, and plugin directories
- ✅ Triggers only after typing `/` in markdown buffers with `claude-prompt` prefix
- ✅ Session-scoped caching (loads once per Neovim session)
- ✅ Alphabetically sorted completions
- ✅ Silent fallback for missing directories
- ✅ **Tested and working** - finds 50+ skills/commands

## Testing Results

✅ Module loads successfully
✅ Scans 50 skills/commands from all configured directories
✅ Alphabetical sorting works
✅ Context filtering works (only in claude-prompt*.md files)
✅ Cache initialization works
✅ All expected items found (/buck, /commit-changes, /unslop-code, etc.)
✅ Plugin items properly formatted (/cache:away, /cache:browser, etc.)
✅ Hint displays "Claude" in completion menu

## Usage

1. Open a markdown file named `claude-prompt-*.md` (e.g., `claude-prompt-test.md`)
2. Type `/` to trigger completions
3. Select from available skills and commands

### Example Completions

**Core skills/commands** (no prefix):
```
/amend-changes        Claude
/bisect               Claude
/buck                 Claude
/commit-changes       Claude
/unslop-code          Claude
```

**Plugin skills/commands** (with `plugin:` prefix):
```
/cache:away           Claude
/cache:browser        Claude
/cache:feature-dev    Claude
/tomacco:prd-schema   Claude
```

## Architecture

The source is organized into three clean sections:

### 1. File Scanner Module (Pure Functions)
- `scan_skills_and_commands()` - Scans all Claude directories
- `extract_completion_name()` - Extracts names from file paths

### 2. Cache Manager (Stateful)
- Session-scoped cache with lazy initialization
- `should_initialize_cache()` - Checks if cache needs loading
- `get_cached_items()` - Returns cached items with error handling

### 3. Blink.cmp Provider (Protocol Implementation)
- `get_trigger_characters()` - Returns `{"/"}`
- `get_completions()` - Main completion handler
- `should_show_completions()` - Context-aware filtering

## Scanned Directories

- `~/.claude/skills/*/SKILL.md` - Skill definitions (uses directory name)
- `~/.claude/commands/*.md` - Command definitions (uses filename)
- `~/.claude/plugins/**/commands/*.md` - Plugin commands
- `~/.claude/plugins/**/skills/*/SKILL.md` - Plugin skills

## Configuration

Registered in `lua/user/plugins/lsp/blink-cmp.lua`:

```lua
sources = {
   default = { "lsp", "path", "snippets", "buffer", "claude" },
   providers = {
      claude = {
         name = "Claude",
         module = "local_plugins.blink-claude",
         score_offset = 10, -- Prioritize over buffer completions
      },
   },
}
```

## Testing

```bash
# Create test file
echo "# Test\n\n/" > ~/claude-prompt-test.md

# Open in Neovim
nvim ~/claude-prompt-test.md

# Type / and you should see completions
```
