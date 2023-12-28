local treesitter_status_ok, _ = pcall(require, "nvim-treesitter")
if not treesitter_status_ok then
   return
end

local treesitter_configs_status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not treesitter_configs_status_ok then
   return
end

configs.setup {
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
   -- ensure_installed = "all", -- one of "all" or a list of languages
   ignore_install = { "" }, -- List of parsers to ignore installing
   sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)

   highlight = {
      enable = true, -- false will disable the whole extension
      disable = { "css" }, -- list of language that will be disabled
   },
   autopairs = {
      enable = true,
   },
   indent = { enable = true, disable = { "python", "css" } },
}
