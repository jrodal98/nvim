local map = require("core.utils").map

vim.cmd [[
  highlight PCSDebugging guifg=red
]]

local case_insensitive_pattern = "\\c"
local pcs_debugging_patterns = table.concat({
   "error",
   "errors",
   "failed",
   "fail",
   "failure",
   "exception",
   "traceback",
   "cancel",
   "canceled",
   "canceling",
   "warning",
   "warn",
   "missing",
   "stop",
   "not found",
}, "\\|")

map(
   "n",
   "<leader>db",
   "<cmd>syntax match PCSDebugging /" .. case_insensitive_pattern .. pcs_debugging_patterns .. "/<CR>"
)
