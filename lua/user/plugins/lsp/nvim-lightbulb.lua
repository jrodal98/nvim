return {
   "kosayoda/nvim-lightbulb",
   event = { "BufReadPre", "BufNewFile" },
   -- Show the lightbulb on CursorHold/CursorHoldI (plugin's builtin autocmd).
   -- updatetime = -1 stops the plugin from overriding the value set in
   -- user.options (it would otherwise force updatetime = 200).
   opts = {
      autocmd = { enabled = true, updatetime = -1 },
   },
}
