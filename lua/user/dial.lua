local augend_status, augend = pcall(require, "dial.augend")
if not augend_status then
   return
end

local config_status, config = pcall(require, "dial.config")
if not config_status then
   return
end

local map_status, map = pcall(require, "dial.map")
if not map_status then
   return
end

config.augends:register_group {
   default = {
      augend.integer.alias.decimal_int, -- include negative numbers
      augend.integer.alias.hex,
      augend.date.alias["%Y/%m/%d"],
      augend.date.alias["%Y-%m-%d"],
      augend.date.alias["%m/%d"],
      augend.constant.alias.alpha, -- lowercase letter
      augend.constant.alias.Alpha, -- uppercase letter
      augend.constant.alias.bool, -- true, false
      augend.semver.alias.semver,
      augend.constant.new {
         elements = { "True", "False" },
         word = true,
         cyclic = true,
      },
      augend.constant.new {
         elements = { "and", "or" },
         word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
         cyclic = true, -- "or" is incremented into "and".
      },
      augend.constant.new {
         elements = { "&&", "||" },
         word = false,
         cyclic = true,
      },
   },
}

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<C-a>", map.inc_normal(), opts)
keymap("n", "<C-x>", map.dec_normal(), opts)
keymap("v", "<C-a>", map.inc_visual(), opts)
keymap("v", "<C-x>", map.dec_visual(), opts)
keymap("v", "g<C-a>", map.inc_gvisual(), opts)
keymap("v", "g<C-x>", map.dec_gvisual(), opts)
