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
}

return M
