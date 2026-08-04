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

Built on `local_plugins/blink-agent-common` (shared with `blink-pi`), which provides frontmatter parsing, argument-hint→snippet conversion, the session cache, trigger/context logic, and the blink.cmp provider protocol via a source factory.

This module contains only Claude Code's discovery logic:

- `scan_skills_and_commands()` - Scans all `.claude` directories (ancestor walk from cwd)
- `parse_installed_plugins()` - Plugin discovery from `installed_plugins.json`
- `extract_completion_name()` / `create_completion_item()` - Claude-specific naming (`/name`, `/plugin:name`) and docs

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
