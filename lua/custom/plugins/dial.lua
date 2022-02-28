local map = require("core.utils").map
local dial_map = require "dial.map"
local augend = require "dial.augend"
local dial_config = require "dial.config"

dial_config.augends:register_group {
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

map("n", "<C-a>", dial_map.inc_normal())
map("n", "<C-x>", dial_map.dec_normal())
map("v", "<C-a>", dial_map.inc_visual())
map("v", "<C-x>", dial_map.dec_visual())
map("v", "g<C-a>", dial_map.inc_gvisual())
map("v", "g<C-x>", dial_map.dec_gvisual())
