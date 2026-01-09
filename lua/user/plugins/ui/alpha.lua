local M = {
   "goolord/alpha-nvim",
   event = "VimEnter",
}

function M.config()
   local status_ok, alpha = pcall(require, "alpha")
   if not status_ok then
      return
   end

   local dashboard = require "alpha.themes.dashboard"
   dashboard.section.header.val = {
      [[                               __                ]],
      [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
      [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
      [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
      [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
      [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
   }
   dashboard.section.buttons.val = {
      dashboard.button("f", "" .. " Find file", "<cmd>lua Snacks.picker.files()<cr>"),
      dashboard.button("e", "" .. " New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("o", "󰄉 " .. " Recent files", "<cmd>lua Snacks.picker.recent()<cr>"),
      dashboard.button("w", "" .. " Find text", "<cmd>lua Snacks.picker.grep()<cr>"),
      dashboard.button("c", "" .. " Config", "<cmd>lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })<cr>"),
      dashboard.button("q", "" .. " Quit", ":qa<CR>"),
   }

   dashboard.section.footer.opts.hl = "Type"
   dashboard.section.header.opts.hl = "Include"
   dashboard.section.buttons.opts.hl = "Keyword"

   dashboard.opts.opts.noautocmd = true
   alpha.setup(dashboard.opts)
end

return M
