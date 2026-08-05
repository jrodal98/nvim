-- TV fuzzy finder (https://github.com/alexpasmantier/television)
-- Snacks picker handles the main find/grep keymaps; these channels are for
-- manual use via :Tv (e.g. :Tv files, :Tv text).
return {
   "alexpasmantier/tv.nvim",
   cmd = "Tv",
   config = function()
      local h = require("tv").handlers
      require("tv").setup {
         channels = {
            files = {
               handlers = {
                  ["<CR>"] = h.open_as_files,
                  ["<C-q>"] = h.send_to_quickfix,
               },
            },
            text = {
               handlers = {
                  ["<CR>"] = h.open_at_line,
                  ["<C-q>"] = h.send_to_quickfix,
               },
            },
         },
      }
   end,
}
