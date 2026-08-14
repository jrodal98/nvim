# blink-pi

A blink.cmp completion source for [pi](https://github.com/badlogic/pi-mono) skills and prompt templates.

## Features

- ✅ Autocomplete `/prompt-template` and `/skill:name` in `pi-editor-*/prompt.md` files (pi's external editor buffers, e.g. `/tmp/pi-editor-dTmIUN/prompt.md`)
- ✅ **Pi-native syntax**: prompt templates insert as `/name`, skills as `/skill:name`
- ✅ Scans all pi discovery locations:
  - `~/.pi/agent/prompts/*.md` and project `.pi/prompts/*.md` (prompt templates)
  - `~/.pi/agent/skills/` — recursive `SKILL.md` dirs + root `*.md` skills
  - `~/.agents/skills/` — recursive `SKILL.md` dirs (root `*.md` ignored, per pi spec)
  - Project `.pi/skills/` and `.agents/skills/` in cwd and ancestors
  - `skills` array from `~/.pi/agent/settings.json` and project `.pi/settings.json` (e.g. `~/.claude/skills`), with `~` and relative-path resolution
- ✅ **Follows symlinked skill directories** (vim's `**` glob does not — and skill dirs are commonly symlinked), with realpath loop guarding and a depth cap
- ✅ Frontmatter `name:` overrides directory name (pi allows this)
- ✅ `argument-hint` frontmatter → snippet tab stops (`<required>` brackets stripped, `[--flag VALUE]` gets nested placeholders with LuaSnip)
- ✅ Description from frontmatter; prompt templates fall back to first content line (per pi docs)
- ✅ Tolerant frontmatter parsing: leading blank lines, single or double quotes
- ✅ First-found-wins deduplication (matches pi's collision rule)
- ✅ Session-scoped caching, alphabetical sorting, silent fallback for missing dirs

## Usage

1. Hit pi's external-editor keybind — the prompt opens as a `pi-editor-*/prompt.md` buffer
2. Type `/` for prompt templates, `/skill:` for skills
3. Docs popup shows description, scope (`user` / `project` / `settings`), and usage hint

## Architecture

Built on `local_plugins/blink-agent-common` (shared with `blink-claude`), which provides frontmatter parsing, argument-hint→snippet conversion, the session cache, trigger/context logic, and the blink.cmp provider protocol via a source factory.

This module contains only pi's discovery logic: location collection (global, ancestor walk, settings JSON with `~`/relative resolution), the symlink-following recursive `SKILL.md` walker, and pi-specific completion item formatting (`/name` vs `/skill:name`, scope labels).

## Configuration

Registered in `lua/user/plugins/lsp/blink-cmp.lua` (only when `pi` is executable):

```lua
config.sources.providers.pi = {
   name = "Pi",
   module = "local_plugins.blink-pi",
   score_offset = 10, -- Prioritize over buffer completions
}
```

## Testing

```bash
cd ~/.config/nvim
timeout 120 nvim --headless -c "lua require('local_plugins.blink-pi.tests.test_blink_pi').run_all_tests()"
```

Covers: prompt templates, skills (root `.md`, recursive, renamed via frontmatter), symlinked skill dirs, settings-configured dirs (global + project relative paths), ancestor walking, trigger logic (incl. `/skill:` continuation), filename filtering, dedup, argument hints, sorting, caching.
