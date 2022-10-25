local present, bufferline = pcall(require, "bufferline")
if not present then
   return
end

local default = {
   colors = require("colors").get(),
}
default = {
   options = {
      offsets = { { filetype = "NvimTree", text = "", padding = 1 } },
      buffer_close_icon = "",
      modified_icon = "",
      close_icon = "",
      show_close_icon = true,
      left_trunc_marker = "",
      right_trunc_marker = "",
      max_name_length = 14,
      max_prefix_length = 13,
      tab_size = 20,
      show_tab_indicators = true,
      enforce_regular_tabs = false,
      view = "multiwindow",
      show_buffer_close_icons = true,
      separator_style = "thin",
      always_show_bufferline = true,
      diagnostics = false,
      custom_filter = function(buf_number)
         -- Func to filter out our managed/persistent split terms
         local present_type, type = pcall(function()
            return vim.api.nvim_buf_get_var(buf_number, "term_type")
         end)

         if present_type then
            if type == "vert" then
               return false
            elseif type == "hori" then
               return false
            end
            return true
         end

         return true
      end,
   },

   highlights = {
      background = {
         fg = default.colors.grey_fg,
         bg = default.colors.black2,
      },

      -- buffers
      buffer_selected = {
         fg = default.colors.white,
         bg = default.colors.black,
         bold = true,
      },
      buffer_visible = {
         fg = default.colors.light_grey,
         bg = default.colors.black2,
      },

      -- for diagnostics = "nvim_lsp"
      error = {
         fg = default.colors.light_grey,
         bg = default.colors.black2,
      },
      error_diagnostic = {
         fg = default.colors.light_grey,
         bg = default.colors.black2,
      },

      -- close buttons
      close_button = {
         fg = default.colors.light_grey,
         bg = default.colors.black2,
      },
      close_button_visible = {
         fg = default.colors.light_grey,
         bg = default.colors.black2,
      },
      close_button_selected = {
         fg = default.colors.red,
         bg = default.colors.black,
      },
      fill = {
         fg = default.colors.grey_fg,
         bg = default.colors.black2,
      },
      indicator_selected = {
         fg = default.colors.black,
         bg = default.colors.black,
      },

      -- modified
      modified = {
         fg = default.colors.red,
         bg = default.colors.black2,
      },
      modified_visible = {
         fg = default.colors.red,
         bg = default.colors.black2,
      },
      modified_selected = {
         fg = default.colors.green,
         bg = default.colors.black,
      },

      -- separators
      separator = {
         fg = default.colors.black2,
         bg = default.colors.black2,
      },
      separator_visible = {
         fg = default.colors.black2,
         bg = default.colors.black2,
      },
      separator_selected = {
         fg = default.colors.black2,
         bg = default.colors.black2,
      },

      -- tabs
      tab = {
         fg = default.colors.light_grey,
         bg = default.colors.one_bg3,
      },
      tab_selected = {
         fg = default.colors.black2,
         bg = default.colors.nord_blue,
      },
      tab_close = {
         fg = default.colors.red,
         bg = default.colors.black,
      },
   },
}

local M = {}
M.setup = function(override_flag)
   if override_flag then
      default = require("core.utils").tbl_override_req("bufferline", default)
   end
   bufferline.setup(default)
end

return M
