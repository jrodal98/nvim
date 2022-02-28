require("iswap").setup {
   -- The keys that will be used as a selection, in order
   -- ('asdfghjklqwertyuiopzxcvbnm' by default)
   keys = "asdfghjklqwertyuiopzxcvbnm",

   -- Grey out the rest of the text when making a selection
   -- (enabled by default)
   grey = "enable",

   -- Highlight group for the sniping value (asdf etc.)
   -- default 'Search'
   hl_snipe = "Search",

   -- Highlight group for the visual selection of terms
   -- default 'Visual'
   hl_selection = "Visual",

   -- Highlight group for the greyed background
   -- default 'Comment'
   hl_grey = "Comment",

   -- Highlight priority for the greyed background
   -- default '1000'
   hl_grey_priority = "1000",

   -- Automatically swap with only two arguments
   -- default nil
   autoswap = true,
}

require("core.utils").map("n", "<leader>sa", ":ISwap <CR>")
