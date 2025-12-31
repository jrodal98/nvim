local M = {
   "willothy/flatten.nvim",
   lazy = false,
   priority = 1001,
}

function M.config()
   local status_ok, flatten = pcall(require, "flatten")
   if not status_ok then
      return
   end

   flatten.setup {
      window = {
         open = "alternate",
         focus = "first",
      },
      hooks = {
         should_block = function(argv)
            -- Block for git commit, rebase, and other interactive commands
            return vim.tbl_contains(argv, "-b")
               or vim.tbl_contains(argv, "-c")
               or vim.tbl_contains(argv, "--cmd")
               or vim.tbl_contains(argv, "+cmd")
         end,
         pre_open = function()
            -- Close toggleterm if it's open
            local ok, term = pcall(require, "toggleterm.terminal")
            if ok then
               local termid = term.get_focused_id()
               if termid then
                  vim.cmd "ToggleTerm"
               end
            end
         end,
         post_open = function(bufnr, winnr, filetype, is_blocking)
            if is_blocking then
               -- For blocking buffers (like git commit), set up autocommands
               vim.api.nvim_create_autocmd("BufHidden", {
                  buffer = bufnr,
                  once = true,
                  callback = function()
                     -- Reopen toggleterm after the blocking buffer closes
                     vim.schedule(function()
                        local ok, _ = pcall(require, "toggleterm")
                        if ok then
                           vim.cmd "ToggleTerm"
                        end
                     end)
                  end,
               })
            end
         end,
      },
      block_for = {
         gitcommit = true,
         gitrebase = true,
      },
   }
end

return M
