# Neovim [![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.12-blueviolet.svg?style=flat-square&logo=Neovim&color=90E59A&logoColor=white)](https://github.com/neovim/neovim)

Modern, modular Neovim configuration with environment-aware plugin loading, AI integration, and graceful degradation.

![nvim-basic](https://user-images.githubusercontent.com/35352333/204195025-4e037788-d400-4e88-b73d-97d6b49225c8.png)

## Features

- **Modular Architecture**: Plugins organized by category (core/editing/files/lsp/scm/ui/utilities), imported per-directory
- **Provider Pattern**: Environment-specific config with graceful fallbacks
- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim)
- **LSP Support**: Full language server integration with nvim-lspconfig, none-ls, and blink.cmp completion
- **Modern UI**: Alpha dashboard, bufferline, lualine, which-key, and more
- **Git Integration**: Gitsigns, resolve.nvim for conflict resolution
- **File Navigation**: Snacks picker, Oil.nvim, TV (fuzzy finder)
- **Editing Enhancements**: Autopairs, surround, comment, abolish, dial, flash
- **AI Integration**: Sidekick.nvim for Claude Code integration
- **Code Annotations**: Haunt.nvim for bookmarks and notes with AI integration
- **Keymap Discovery**: Which-key popup for interactive keymap exploration
- **Environment Aware**: Automatically adapts based on environment (dotgk-based detection)

## Requirements

- Neovim >= 0.12 (uses `pumborder`, `pummaxwidth`, and the bundled `nvim.undotree`)
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (optional, for better icons - config works without it)

## Install

If you already have a neovim config, make a backup:

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim/ ~/.local/share/nvim.bak
```

Clone the repository:

```bash
git clone https://github.com/jrodal98/nvim ~/.config/nvim
```

Start Neovim:

```bash
nvim
```

Lazy.nvim will automatically:

1. Clone itself on first run
2. Install all plugins
3. Set up LSP servers via Mason

Optional: Install additional tools via Mason:

```
:Mason
```

Then install formatters and linters you want (e.g., `prettierd`, `stylua`, `black`, `isort`, `shfmt`, `shellcheck`).

## Architecture

### Plugin Organization

Plugins are organized into logical categories in `lua/user/plugins/`:

```
lua/user/plugins/
├── core/           # Essential plugins (snacks, treesitter, plenary, flash)
├── editing/        # Editing enhancements (autopairs, surround, comment, dial)
├── files/          # File management (oil, tv)
├── lsp/            # LSP and completion (nvim-lspconfig, blink-cmp, none-ls)
├── scm/            # Source control (gitsigns, resolve.nvim)
├── ui/             # UI plugins (colorscheme, lualine, bufferline, which-key)
└── utilities/      # Utility plugins (toggleterm, sidekick, haunt, flatten)
```

Each category directory is imported wholesale in `init.lua` via lazy.nvim's
`{ import = "user.plugins.<category>" }`, so every `.lua` file in a category is
automatically picked up as a plugin spec.

### Environment Detection

The config uses [dotgk](https://github.com/jrodal98/dotgk) via a dotgk-wrapper (see `lua/init-utils/dotgk-wrapper.lua`) to detect the environment:

- If dotgk is available, it uses it for environment checks
- Otherwise, it provides a mock with sensible defaults
- Meta-specific config is loaded via optional `meta-private` plugin
- Public config works standalone without any Meta dependencies

### Local Plugins

Local plugin code lives in `lua/local_plugins/` and is `require`d directly
(the config directory is on the runtime path). Current residents:

```
lua/local_plugins/
├── blink-claude/        # blink.cmp source: Claude Code /skill + /command completion
├── blink-pi/            # blink.cmp source: pi /skill: + prompt-template completion
└── blink-agent-common/  # Shared infrastructure for the two sources (+ test harness)
```

The blink sources are registered in `lua/user/plugins/lsp/blink-cmp.lua`
(only when the corresponding CLI is installed). Their test suites run headlessly:

```bash
timeout 120 nvim --headless -c "lua require('local_plugins.blink-claude.tests.test_blink_claude').run_all_tests()"
timeout 120 nvim --headless -c "lua require('local_plugins.blink-pi.tests.test_blink_pi').run_all_tests()"
```

### Provider Pattern

Environment-specific config is loaded via providers that use `pcall` for graceful fallbacks:

```lua
-- Try to load Meta-specific LSP servers
local ok, lsp_servers = pcall(require, "meta-private.lsp.servers")
if ok then
   -- Use Meta servers
else
   -- Use public servers (pyright, rust_analyzer, etc.)
end
```

This allows the same config to work in multiple environments without modification.

## Plugin System

### Creating a Plugin Spec

Create a file in `lua/user/plugins/<category>/<name>.lua`:

```lua
return {
   "owner/plugin-name",
   event = { "BufReadPost", "BufNewFile" },
   dependencies = { "other/plugin" },
   opts = {
      -- Plugin options passed to setup()
   },
}
```

That's it — the category directories are imported automatically in `init.lua`,
so a new file in the right category is all a new plugin needs.

## Key Features

### Keymap Discovery with Which-Key

Interactive keymap popup that shows available commands as you type:

- **Modern preset** with clean UI and rounded borders
- **Automatic grouping** by functionality (AI, Code, Diagnostics, Find, Git, etc.)
- **Smart delay** - 500ms for discovery, instant for plugin triggers
- Press `<leader>` to explore all available commands
- Press `<leader>?` for buffer-local keymaps
- Press `<leader>K` to show all keymaps

Which-key picks up the `desc` set on each keymap automatically — individual
mappings don't need to be registered anywhere. Only *group names* for new
leader prefixes need an entry in the `spec` table of
`lua/user/plugins/ui/which-key.lua`.

### AI Integration with Sidekick

Claude Code integration for AI-assisted development:

- **Send code to AI**: `<leader>at` (selection), `<leader>af` (file)
- **Haunt integration**: Send bookmarked code with annotations to AI via `haunt_all` and `haunt_buffer` prompts
- **Quick access**: `<leader>ac` toggles Claude, `<leader>ap` selects prompts

### Code Annotations with Haunt

Personal code bookmarks and annotations with AI integration:

- **Annotate lines**: `<leader>ha` - Add notes to code without modifying files
- **Navigate bookmarks**: `<leader>hn/hp` - Jump between annotations
- **Search annotations**: `<leader>hl` - Fuzzy search your notes
- **Git-aware**: Different annotations per branch
- **AI integration**: Send annotations to Sidekick for AI assistance

### LSP Configuration

LSP servers are configured in `lua/user/plugins/lsp/nvim-lspconfig.lua` with:

- Auto-installation via Mason
- Environment-specific server lists (Meta vs public)
- Custom handlers and keymaps
- Inline diagnostics with tiny-inline-diagnostic
- Format on save with async formatting

### Completion with Blink

Modern completion via blink.cmp with:

- LSP source
- Buffer source
- Path source
- Luasnip snippets
- Fuzzy matching
- Ghost text support

### File Navigation

Multiple navigation options:

- **Snacks Picker**: Fast fuzzy finder for files, grep, buffers, git, LSP, diagnostics
- **Oil.nvim**: Edit directories like buffers (`<leader>E`)
- **TV**: Alternative fast fuzzy finder CLI integration

### Notifications

Snacks notifier with history:

- **Notification history**: `<leader>nh` - Review all past notifications
- **Auto-dismiss**: Press `<Esc>` to hide active notifications
- **3-second timeout** for most notifications
- Great for reviewing LSP messages and errors

### UI Customization

- **Colorscheme**: Tokyonight (night) with transparent background
- **Lualine**: Status line with git, diagnostics, LSP status
- **Bufferline**: Tab-like buffer navigation
- **Alpha**: Custom dashboard
- **Indentline**: Indent guides
- **Render-markdown**: Live markdown preview
- **Which-key**: Interactive keymap discovery

## Keybindings

Leader key: `<Space>`

**Discovery**: Press `<leader>` and wait 500ms to see all available commands grouped by category. Press `<leader>?` for buffer-local keymaps or `<leader>K` for all keymaps.

### Quick Reference

| Prefix | Group | Description |
|--------|-------|-------------|
| `<leader>a` | **AI/Sidekick** | Claude integration, send code/files to AI |
| `<leader>c` | **Code** | Code actions (LSP) |
| `<leader>d` | **Diagnostics** | View and navigate diagnostics |
| `<leader>f` | **Find** | File/text search (Snacks picker) |
| `<leader>g` | **Git** | Git operations (branches, log, status) |
| `<leader>h` | **Haunt** | Bookmarks and annotations |
| `<leader>l` | **LSP** | Language server commands |
| `<leader>n` | **Notifications** | Notification history |
| `<leader>r` | **Rename** | Symbol renaming |
| `<leader>s` | **Search/Substitute** | Text search and replace |
| `<leader>t` | **Terminal** | Toggle terminals |

### Essential Keybindings

**General**:
- `<leader>w` - Save file
- `<leader>e` - File explorer (Snacks)
- `<leader>E` - Oil file explorer
- `<leader>x` - Delete buffer
- `<leader><space>` - Toggle fold

**AI Integration**:
- `<leader>ac` - Toggle Claude
- `<leader>at` - Send this (selection/word)
- `<leader>af` - Send file
- `<leader>ap` - Select prompt

**Find/Search**:
- `<leader>ff` - Find files
- `<leader>fw` - Find word (grep)
- `<leader>fb` - Find buffers
- `<leader>fg` - Find git files
- `<leader>fh` - Find help
- `<leader>fk` - Find keymaps

**LSP**:
- `gd` - Go to definition
- `gD` - Go to declaration
- `gr` - Go to references
- `gI` - Go to implementation
- `gy` - Go to type definition
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>fm` - Format buffer
- `gl` - Show line diagnostics
- `<C-n>` / `<C-p>` - Next/previous diagnostic

**Git**:
- `<leader>gb` - Git branches
- `<leader>gl` - Git log
- `<leader>gs` - Git status

**Haunt (Bookmarks)**:
- `<leader>ha` - Annotate line
- `<leader>hl` - Show picker
- `<leader>hn` / `<leader>hp` - Next/previous bookmark

**Terminal**:
- `<leader>tf` - Toggle float terminal
- `<leader>th` - Toggle horizontal terminal
- `<leader>tv` - Toggle vertical terminal
- `<C-\>` - Quick toggle terminal

**Navigation**:
- `H` - First non-blank character
- `L` - End of line
- `<Tab>` / `<S-Tab>` - Next/previous buffer
- `<C-h/j/k/l>` - Navigate windows
- `s` - Flash jump
- `S` - Flash treesitter

**Notifications**:
- `<leader>nh` - Notification history
- `<Esc>` - Clear notifications and highlights

See `lua/user/keymaps.lua` and `lua/user/plugins/ui/which-key.lua` for the complete keybinding list.

## Customization

### Adding a Plugin

1. Create a spec file in `lua/user/plugins/<category>/<name>.lua`
2. Restart Neovim (the category directories are imported automatically)

### Modifying Options

Edit `lua/user/options.lua` for Neovim options.

### Custom Keybindings

1. **Define the keymap** with a `desc`:
   - Edit `lua/user/keymaps.lua` for global keybindings
   - OR add a `keys` table in the plugin spec file for plugin-specific keybindings

   Which-key shows the `desc` automatically — no separate registration needed.

2. **Only if you introduce a new leader prefix**, name its group in
   `lua/user/plugins/ui/which-key.lua`:
   ```lua
   { "<leader>x", group = "Group Name" }
   ```

### LSP Servers

Edit `lua/user/plugins/lsp/nvim-lspconfig.lua` to add/remove LSP servers in the `servers` table.

### Formatters/Linters

Edit `lua/user/plugins/lsp/none-ls.lua` to configure null-ls sources.

## Showcase

![nvim-basic](https://user-images.githubusercontent.com/35352333/204195025-4e037788-d400-4e88-b73d-97d6b49225c8.png)
![nvim-inlayhints](https://user-images.githubusercontent.com/35352333/204195065-4c8d32b6-5188-4654-a36b-54220af6f0e3.png)
![nvim-diagnostic](https://user-images.githubusercontent.com/35352333/204195098-380b2db8-aa14-4356-b72a-47a361ad3643.png)

## Inspiration

- [nvim-basic-ide](https://github.com/LunarVim/nvim-basic-ide)
- [Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch)
- [NvChad](https://github.com/NvChad/NvChad)

## Notes

- **WSL Clipboard**: Install win32yank with `winget install --id=equalsraf.win32yank -e` for clipboard support
- **Dotgk**: The config uses dotgk for environment detection but gracefully falls back if not available
- **Meta Integration**: Meta-specific config can be added via the `meta-private` plugin pattern without modifying the public config
- **Nerd Fonts**: The config works without Nerd Fonts - which-key and other UI elements use simple text icons as fallback
- **Formatting**: Lua sources are formatted with stylua; enable the pre-commit hook with `git config core.hooksPath .githooks`
- **Haunt Bookmarks**: Annotations are stored in `~/.local/share/nvim/haunt/` and are scoped per Git branch
- **Notification History**: Press `<leader>nh` to review all notifications including LSP messages that disappeared
