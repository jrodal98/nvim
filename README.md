# Neovim [![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.11.4-blueviolet.svg?style=flat-square&logo=Neovim&color=90E59A&logoColor=white)](https://github.com/neovim/neovim)

Modern, modular Neovim configuration with environment-aware plugin loading and graceful degradation.

![nvim-basic](https://user-images.githubusercontent.com/35352333/204195025-4e037788-d400-4e88-b73d-97d6b49225c8.png)

## Features

- **Modular Architecture**: Plugins organized by category (core/editing/files/lsp/scm/ui/utilities)
- **Provider Pattern**: Environment-specific config with graceful fallbacks
- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) with custom spec system
- **LSP Support**: Full language server integration with nvim-lspconfig, none-ls, and completion
- **Modern UI**: Alpha dashboard, bufferline, lualine, and more
- **Git Integration**: Gitsigns, git-conflict, telescope-git integration
- **File Navigation**: Telescope, nvim-tree, oil.nvim, tv (fuzzy finder)
- **Editing Enhancements**: Autopairs, surround, comment, abolish, dial, flash
- **Environment Aware**: Automatically adapts based on environment (dotgk-based detection)

## Requirements

- Neovim >= 0.11.4
- A [Nerd Font](https://www.nerdfonts.com/) (optional, for icons)

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
├── core/           # Essential plugins (treesitter, plenary, flash)
├── editing/        # Editing enhancements (autopairs, surround, comment)
├── files/          # File management (telescope, nvim-tree, oil)
├── lsp/            # LSP and completion (nvim-lspconfig, cmp, none-ls)
├── scm/            # Source control (gitsigns, git-conflict)
├── ui/             # UI plugins (colorscheme, lualine, bufferline)
└── utilities/      # Utility plugins (toggleterm, notify, flatten)
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

### LSP Configuration

LSP servers are configured in `lua/user/plugins/lsp/nvim-lspconfig.lua` with:

- Auto-installation via Mason
- Environment-specific server lists (Meta vs public)
- Custom handlers and keymaps
- Inline diagnostics with tiny-inline-diagnostic

### Completion

Completion via nvim-cmp with:

- LSP source
- Buffer source
- Path source
- Luasnip snippets
- Optional metamate integration (Meta environments)

### File Navigation

Multiple navigation options:

- **Telescope**: Fuzzy finder for files, grep, buffers, git, and more
- **nvim-tree**: Traditional file tree sidebar
- **oil.nvim**: Edit directories like buffers
- **tv**: Fast fuzzy finder CLI integration

### UI Customization

- **Colorscheme**: Catppuccin with transparent background support
- **Lualine**: Status line with git, diagnostics, LSP status
- **Bufferline**: Tab-like buffer navigation
- **Alpha**: Custom dashboard
- **Indentline**: Indent guides
- **Render-markdown**: Live markdown preview

## Keybindings

Leader key: `<Space>`

### General

- `<leader>q` - Quit buffer (Bbye)
- `<leader>w` - Save file
- `<C-h/j/k/l>` - Navigate windows
- `<S-h/l>` - Navigate buffers
- `<leader>e` - Toggle nvim-tree
- `<leader>-` - Open oil.nvim

### LSP

- `gd` - Go to definition
- `gD` - Go to declaration
- `gr` - References
- `gi` - Implementation
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename
- `<leader>f` - Format
- `gl` - Show line diagnostics
- `[d` / `]d` - Previous/next diagnostic

### Telescope

- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Buffers
- `<leader>fh` - Help tags
- `<leader>fc` - Colorschemes
- `<leader>fk` - Keymaps

### Git

- `<leader>gg` - Lazygit (via toggleterm)
- `]c` / `[c` - Next/prev hunk
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hb` - Blame line

See `lua/user/keymaps.lua` for complete keybinding list.

## Customization

### Adding a Plugin

1. Create a spec file in `lua/user/plugins/<category>/<name>.lua`
2. Add `add_spec "user.plugins.<category>.<name>"` to `init.lua`
3. Restart Neovim

### Modifying Options

Edit `lua/user/options.lua` for Neovim options.

### Custom Keybindings

Edit `lua/user/keymaps.lua` for keybindings.

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
