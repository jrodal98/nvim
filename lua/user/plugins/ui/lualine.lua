local M = {
   "nvim-lualine/lualine.nvim",
   event = "VeryLazy",
}

function M.config()
   local status_ok, lualine = pcall(require, "lualine")
   if not status_ok then
      return
   end

   local hide_in_width = function()
      return vim.fn.winwidth(0) > 80
   end

   local diagnostics = {
      "diagnostics",
      sources = { "nvim_diagnostic" },
      sections = { "error", "warn" },
      symbols = { error = " ", warn = " " },
      colored = false,
      always_visible = true,
   }

   local diff = {
      "diff",
      colored = false,
      symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
      cond = hide_in_width,
   }

   local filetype = {
      "filetype",
      icons_enabled = false,
   }

   local location = {
      "location",
      padding = 0,
   }

   local spaces = function()
      return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
   end
   local filepath = {
      "filename",
      path = 1,
      symbols = {
         modified = "[+]", -- Text to show when the file is modified.
         readonly = "[-]", -- Text to show when the file is non-modifiable or readonly.
         unnamed = "[No Name]", -- Text to show for unnamed buffers.
         newfile = "[New]", -- Text to show for newly created file before first write
      },
      colored = false,
   }
   lualine.setup {
      options = {
         globalstatus = true,
         icons_enabled = true,
         theme = "auto",
         disabled_filetypes = { "alpha", "dashboard" },
         always_divide_middle = true,
      },
      sections = {
         lualine_a = { "mode" },
         lualine_b = { "branch", filepath },
         lualine_c = {},
         lualine_x = { diagnostics, diff, spaces, "encoding", filetype },
         lualine_y = { location },
         lualine_z = { "progress" },
      },
   }
end

return M
