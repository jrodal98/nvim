local M = {}

-- overriding default plugin configs!
M.treesitter = {
   ensure_installed = {
      "bash",
      "cpp",
      "css",
      "dockerfile",
      "html",
      "json",
      "lua",
      "markdown",
      "python",
      "rust",
      "toml",
      "vim",
      "yaml",
   },
   -- configuration for the nvim-ts-rainbow plugin
   rainbow = {
      enable = true,
      -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
      extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
      max_file_lines = nil, -- Do not enable for files with more than n lines, int
      -- colors = {}, -- table of hex strings
      -- termcolors = {} -- table of colour name strings
   },
}

return M
