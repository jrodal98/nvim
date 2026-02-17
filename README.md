# Neovim [![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.11.4-blueviolet.svg?style=flat-square&logo=Neovim&color=90E59A&logoColor=white)](https://github.com/neovim/neovim)

Modern, modular Neovim configuration with environment-aware plugin loading, AI integration, and graceful degradation.

![nvim-basic](https://user-images.githubusercontent.com/35352333/204195025-4e037788-d400-4e88-b73d-97d6b49225c8.png)

## Features

- **Modular Architecture**: Plugins organized by category (core/editing/files/lsp/scm/ui/utilities)
- **Provider Pattern**: Environment-specific config with graceful fallbacks
- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) with custom spec system
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

- Neovim >= 0.11.4
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

### Environment Detection

The config uses [dotgk](https://github.com/jrodal98/dotgk) via a dotgk-wrapper (see `lua/init-utils/dotgk-wrapper.lua`) to detect the environment:

- If dotgk is available, it uses it for environment checks
- Otherwise, it provides a mock with sensible defaults
- Meta-specific config is loaded via optional `meta-private` plugin
- Public config works standalone without any Meta dependencies

### Local Plugins

Local plugins can be stored in `lua/local_plugins/` with this structure:

```
lua/local_plugins/
├── plugin_name/
│   ├── init.lua      # Main plugin code with setup() function
│   ├── config.lua    # Configuration and defaults
│   └── ...           # Additional modules
```

The `add_spec` function automatically detects local plugins and configures them just like other lazy plugins.

You don't need this unless you want to lazy load some local configs. I used to have some stuff here, but it's empty at the time of writing.

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

### Using add_spec

Plugins are loaded using `add_spec()` in `init.lua`:

```lua
add_spec "user.plugins.core.treesitter"
add_spec "user.plugins.files.telescope"
add_spec "user.plugins.lsp.nvim-lspconfig"
```

Each call loads a plugin specification from the corresponding lua file.

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

For local plugins, just create the directory in `lua/local_plugins/` and a spec file - auto-detection handles the rest.

## Key Features

### Keymap Discovery with Which-Key

Interactive keymap popup that shows available commands as you type:

- **Modern preset** with clean UI and rounded borders
- **Automatic grouping** by functionality (AI, Code, Diagnostics, Find, Git, etc.)
- **Smart delay** - 200ms for discovery, instant for plugin triggers
- Press `<leader>` to explore all available commands
- Press `<leader>?` for buffer-local keymaps
- Press `<leader>K` to show all keymaps

**Important**: When adding new keybindings, always update `lua/user/plugins/ui/which-key.lua` to keep the documentation in sync. Add new mappings to the appropriate group in the `spec` table.

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

- **Colorscheme**: Catppuccin with transparent background support
- **Lualine**: Status line with git, diagnostics, LSP status
- **Bufferline**: Tab-like buffer navigation
- **Alpha**: Custom dashboard
- **Indentline**: Indent guides
- **Render-markdown**: Live markdown preview
- **Which-key**: Interactive keymap discovery

## Keybindings

Leader key: `<Space>`

**Discovery**: Press `<leader>` and wait 200ms to see all available commands grouped by category. Press `<leader>?` for buffer-local keymaps or `<leader>K` for all keymaps.

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
2. Add `add_spec "user.plugins.<category>.<name>"` to `init.lua`
3. Restart Neovim

### Modifying Options

Edit `lua/user/options.lua` for Neovim options.

### Custom Keybindings

**Important**: When adding new keybindings, you must update **both** files:

1. **Define the keymap**:
   - Edit `lua/user/keymaps.lua` for global keybindings
   - OR add `keys` table in the plugin spec file for plugin-specific keybindings

2. **Document in which-key**:
   - Edit `lua/user/plugins/ui/which-key.lua`
   - Add the keybinding to the appropriate group in the `spec` table
   - If creating a new group, add it with `{ "<leader>x", group = "Group Name" }`
   - Example:
     ```lua
     { "<leader>xy", desc = "Your new command" }
     ```

This ensures the keymap appears in the which-key popup with proper documentation.

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
- **Which-Key**: Always update `which-key.lua` when adding new keybindings to keep documentation in sync
- **Haunt Bookmarks**: Annotations are stored in `~/.local/share/nvim/haunt/` and are scoped per Git branch
- **Notification History**: Press `<leader>nh` to review all notifications including LSP messages that disappeared
