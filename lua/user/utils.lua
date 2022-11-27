local M = {}
function M.is_devserver()
   if vim.env.DEVSERVER then
      return true
   else
      return false
   end
end

return M
