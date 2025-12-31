local M = {
   "kosayoda/nvim-lightbulb",
   event = { "BufReadPre", "BufNewFile" },
}

function M.config()
   vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      callback = function()
         require("nvim-lightbulb").update_lightbulb()
      end,
   })
end

return M
