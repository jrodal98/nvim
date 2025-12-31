local M = {
   "kyazdani42/nvim-tree.lua",
   -- lazy load when the keys are hit and configures the binding
   keys = {
      { "<leader>e", ":NvimTreeToggle<CR>", mode = "n", noremap = true, silent = true },
   },
}

function M.config()
   local status_ok, nvim_tree = pcall(require, "nvim-tree")
   if not status_ok then
      return
   end

   nvim_tree.setup {
      update_focused_file = {
         enable = true,
         update_cwd = true,
      },
      renderer = {
         root_folder_modifier = ":t",
         icons = {
            glyphs = {
               default = "",
               symlink = "",
               folder = {
                  arrow_open = "",
                  arrow_closed = "",
                  default = "",
                  open = "",
                  empty = "",
                  empty_open = "",
                  symlink = "",
                  symlink_open = "",
               },
               git = {
                  unstaged = "",
                  staged = "S",
                  unmerged = "",
                  renamed = "➜",
                  untracked = "U",
                  deleted = "",
                  ignored = "◌",
               },
            },
         },
      },
      diagnostics = {
         enable = true,
         show_on_dirs = true,
         icons = {
            hint = "󰌵",
            info = "",
            warning = "",
            error = "",
         },
      },
      view = {
         width = 30,
         side = "left",
      },
   }

   -- Automatically quit Neovim if the only open window is the NvimTree file explorer
   vim.api.nvim_create_autocmd({ "BufEnter" }, {
      callback = function()
         -- Get the current buffer name and window count
         local bufname = vim.api.nvim_buf_get_name(0)
         local winnr = vim.fn.winnr "$"
         -- Check if only one window is open and it's an NvimTree buffer
         if winnr == 1 and bufname:match "NvimTree_%d*$" then
            vim.cmd "quit"
         end
      end,
   })
end

return M
