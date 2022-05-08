local M = {}

local plugin_conf = require "custom.plugins.configs"
local userPlugins = require "custom.plugins"

M.options = {
   -- NeoVim/Vim options
   clipboard = "unnamedplus",
   cmdheight = 1,
   ruler = false,
   hidden = true,
   ignorecase = true,
   smartcase = true,
   mapleader = " ",
   mouse = "a",
   number = true,
   -- relative numbers in normal mode tool at the bottom of options.lua
   numberwidth = 2,
   relativenumber = true,
   expandtab = true,
   shiftwidth = 2,
   smartindent = true,
   tabstop = 8, -- Number of spaces that a <Tab> in the file counts for
   timeoutlen = 400,
   -- interval for writing swap file to disk, also used by gitsigns
   updatetime = 250,
   undofile = true, -- keep a permanent undo (across restarts)
   fillchars = { eob = " " },
   shadafile = vim.opt.shadafile,
   -- NvChad options
   nvChad = {
      copy_cut = false, -- copy cut text ( x key ), visual and normal mode
      copy_del = false, -- copy deleted text ( dd key ), visual and normal mode
      insert_nav = true, -- navigation in insertmode
      window_nav = true,
      terminal_numbers = false,
      -- used for updater
      update_url = "https://github.com/jrodal98/nvim",
      update_branch = "main",
   },

   terminal = {
      behavior = {
         close_on_exit = true,
      },
      window = {
         vsplit_ratio = 0.5,
         split_ratio = 0.4,
      },
      location = {
         horizontal = "rightbelow",
         vertical = "rightbelow",
         float = {
            relative = "editor",
            row = 0.3,
            col = 0.25,
            width = 0.5,
            height = 0.4,
            border = "single",
         },
      },
   },
}

-- ui configs
M.ui = {
   hl_override = "", -- path of your file that contains highlights
   colors = "", -- path of your file that contains colors
   italic_comments = true,
   -- theme to be used, check available themes with `<leader> + t + h`
   theme = "tokyonight",
   -- Enable this only if your terminal has the colorscheme set which nvchad uses
   -- For Ex : if you have onedark set in nvchad, set onedark's bg color on your terminal
   transparency = true,
}

-- these are plugin related options
M.plugins = {

   -- builtin nvim plugins are disabled
   builtins = {
      "2html_plugin",
      "getscript",
      "getscriptPlugin",
      "gzip",
      "logipat",
      "netrw",
      "netrwPlugin",
      "netrwSettings",
      "netrwFileHandlers",
      "matchit",
      "tar",
      "tarPlugin",
      "rrhelper",
      "spellfile_plugin",
      "vimball",
      "vimballPlugin",
      "zip",
      "zipPlugin",
   },
   -- enable and disable plugins (false for disable)
   status = {
      blankline = true, -- show code scope with symbols
      bufferline = true, -- list open buffers up the top, easy switching too
      colorizer = false, -- color RGB, HEX, CSS, NAME color codes
      comment = true, -- easily (un)comment code, language aware
      alpha = true, -- NeoVim 'home screen' on open
      better_escape = true, -- map to <ESC> with no lag
      feline = true, -- statusline
      gitsigns = false, -- gitsigns in statusline
      lspsignature = true, -- lsp enhancements
      vim_matchup = true, -- % operator enhancements
      snippets = true,
      cmp = true,
      nvimtree = true,
      autopairs = true,
   },
   options = {
      packer = {
         init_file = "plugins.packerInit",
      },
      autopairs = { loadAfter = "nvim-cmp" },
      cmp = {
         lazy_load = true,
      },
      lspconfig = {
         setup_lspconf = "custom.plugins.lspconfig", -- path of file containing setups of different lsps
      },
      nvimtree = {
         -- packerCompile required after changing lazy_load
         lazy_load = true,
      },
      luasnip = {
         snippet_path = { "./lua/custom/snippets" },
      },
      statusline = {
         hide_disable = false,
         -- hide, show on specific filetypes
         hidden = {
            "help",
            "NvimTree",
            "terminal",
            "alpha",
         },
         shown = {},

         -- truncate statusline on small screens
         shortline = true,
         style = "default", -- default, round , slant , block , arrow
      },
      esc_insertmode_timeout = 300,
   },
   default_plugin_config_replace = {
      nvim_treesitter = plugin_conf.treesitter,
   },
   default_plugin_remove = {},
   install = userPlugins,
}

-- mappings -- don't use a single keymap twice --
-- non plugin mappings
M.mappings = {
   -- custom = {}, -- all custom user mappings
   -- close current focused buffer
   misc = {
      cheatsheet = "<leader>ch",
      close_buffer = "<leader>x",
      cp_whole_file = "<C-c>", -- copy all contents of current buffer
      lineNR_toggle = "<leader>tl", -- toggle line number
      lineNR_rel_toggle = "<leader>rn",
      update_nvchad = "<leader>uu",
      new_buffer = "<S-t>",
      new_tab = "<C-t>b",
      save_file = "<leader>w", -- save file using :w
   },
   -- navigation in insert mode, only if enabled in options
   insert_nav = {
      backward = "<C-h>",
      end_of_line = "<C-e>",
      forward = "<C-l>",
      next_line = "<C-k>",
      prev_line = "<C-j>",
      top_of_line = "<C-a>",
   },
   --better window movement
   window_nav = {
      moveLeft = "<C-h>",
      moveRight = "<C-l>",
      moveUp = "<C-k>",
      moveDown = "<C-j>",
   },
   -- terminal related mappings
   terminal = {
      -- multiple mappings can be given for esc_termmode and esc_hide_termmode
      -- get out of terminal mode
      esc_termmode = { "jk" }, -- multiple mappings allowed
      -- get out of terminal mode and hide it
      esc_hide_termmode = { "JK" }, -- multiple mappings allowed
      -- show & recover hidden terminal buffers in a telescope picker
      pick_term = "<leader>tw",
      -- below three are for spawning terminals
      new_horizontal = "<leader>th",
      new_vertical = "<leader>tv",
      new_float = "<leader>tf",

      -- spawn new terminals
      spawn_horizontal = "<A-h>",
      spawn_vertical = "<A-v>",
      spawn_window = "<leader>tt",
   },
}

-- all plugins related mappings
M.mappings.plugins = {
   -- list open buffers up the top, easy switching too
   bufferline = {
      next_buffer = "<TAB>", -- next buffer
      prev_buffer = "<S-Tab>", -- previous buffer
   },
   -- easily (un)comment code, language aware
   comment = {
      toggle = "gc", -- toggle comment (works on multiple lines)
   },
   -- map to <ESC> with no lag
   better_escape = { -- <ESC> will still work
      esc_insertmode = { "jk" }, -- multiple mappings allowed
   },

   lspconfig = {
      declaration = "gD",
      definition = "gd",
      hover = "K",
      implementation = "gi",
      signature_help = "gk",
      add_workspace_folder = "<leader>wa",
      remove_workspace_folder = "<leader>wr",
      list_workspace_folders = "<leader>wl",
      type_definition = "<leader>D",
      rename = "<leader>rn",
      code_action = "<leader>ca",
      references = "gr",
      float_diagnostics = "ge",
      goto_prev = "[d",
      goto_next = "]d",
      set_loclist = "<leader>q",
      formatting = "<leader>fm",
   },
   -- file explorer/tree
   nvimtree = {
      toggle = "<C-n>",
      focus = "<leader>e",
   },
   -- multitool for finding & picking things
   telescope = {
      buffers = "<leader>fb",
      find_files = "<leader>ff",
      find_hiddenfiles = "<leader>fa",
      git_commits = "<leader>cm",
      git_status = "<leader>gt",
      help_tags = "<leader>fh",
      live_grep = "<leader>fw",
      oldfiles = "<leader>fo",
      themes = "<leader>ts", -- NvChad theme picker
   },
}

return M
