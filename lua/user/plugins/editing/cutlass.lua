return {
   "svermeulen/vim-cutlass",
   event = { "BufReadPre", "BufNewFile" },
   keys = {
      { "x", "d", mode = { "n", "x" }, noremap = true, silent = true },
      { "xx", "dd", mode = "n", noremap = true, silent = true },
      { "X", "D", mode = "n", noremap = true, silent = true },
   },
}
