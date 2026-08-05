# blink-agent-common

Shared infrastructure for the agent completion sources (`blink-claude`, `blink-pi`). Extracted after the two copies diverged — bug fixes here land in both plugins.

## Modules

### `frontmatter.lua`
YAML frontmatter helpers: `start`, `strip_quotes`, `skip`, `parse_description` (multi-line support), `parse_field`, `first_content_line`. Tolerant parsing: leading blank lines before the opening `---`, single- or double-quoted values.

`extract(file_path, opts)` reads a file (first 50 lines) and returns `{ name, description, argument_hint }`; `opts.first_line_fallback` falls back to the first content line when there is no frontmatter description.

### `util.lua`
`home_of(config)` resolves the home directory (honoring the `home_dir` test override) and `walk_ancestors(fn)` calls `fn` for the cwd and each ancestor directory.

### `items.lua`
`make(opts)` builds a `blink.cmp.CompletionItem` from `{ label, source_label, description, fallback_description, doc_suffix, argument_hint, file, data }` — owns snippet insertText, markdown docs with the **Usage:** section, kind, and label details.

### `snippet.lua`
`hint_to_snippet(hint)` converts `argument-hint` frontmatter into LSP snippet tab stops:
- `<REQUIRED>` → `${N:REQUIRED}` (angle brackets stripped)
- `[--flag VALUE]` → `${N:--flag ${N+1:VALUE}}` (nested, when LuaSnip is available)
- `[--flag]` / bare tokens → simple sequential placeholders

`set_nested_placeholders(bool|nil)` overrides LuaSnip detection for tests.

### `source.lua`
`make(opts)` factory returning a complete blink.cmp source:

```lua
return require("local_plugins.blink-agent-common.source").make {
   name = "blink-pi",                 -- error-notification prefix
   filename_pattern = "^pi%-editor",  -- basename pattern for target buffers
   scan = function(config)            -- config.home_dir is the test override
      return items                    -- blink.cmp.CompletionItem[]
   end,
}
```

Owns: session-scoped caching with pcall/notify error handling (items are sorted alphabetically after the scan), target-buffer detection (markdown + basename pattern), slash-context trigger logic (`/` at line start or after whitespace, continuing through `[%w:_-]`), the provider protocol (`new`, `get_trigger_characters` → `{"/", ":"}`, `get_completions`), and test hooks (`configure`, `reset_cache`).

### `tests/harness.lua`
Shared test utilities for both suites: `assert_eq`/`assert_true`/`assert_contains`, `create_test_buffer(prefix, suffix)`, `reset_module(module_name, fixtures)`, `find_item`, `get_items`, and the `run(suite_name, tests)` runner. Fixture setup stays in each suite.

## Adding a new source

Write a scanner that returns completion items, pick a buffer filename pattern, and call `make`. See `blink-pi/init.lua` for the minimal shape; use `frontmatter` and `snippet` for `.md` metadata and argument hints.

## Testing

No dedicated suite; both consumers exercise every module (via `tests/harness.lua`):

```bash
cd ~/.config/nvim
timeout 120 nvim --headless -c "lua require('local_plugins.blink-claude.tests.test_blink_claude').run_all_tests()"
timeout 120 nvim --headless -c "lua require('local_plugins.blink-pi.tests.test_blink_pi').run_all_tests()"
```
