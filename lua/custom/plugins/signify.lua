local map = require("core.utils").map



-- default mappings

-- ]c   Jump to the next hunk.
-- [c   Jump to the previous hunk.
--
-- ]C   Jump to the last hunk.
-- [C   Jump to the first hunk.

map("n", "<leader>hd", ":SignifyHunkDiff <CR>")
map("n", "<leader>hu", ":SignifyHunkUndo <CR>")
