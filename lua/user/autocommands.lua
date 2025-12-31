-- ========================================
-- FileType-specific settings
-- ========================================

-- Enable line wrap and spell check for text files
vim.api.nvim_create_autocmd("FileType", {
   pattern = { "gitcommit", "markdown" },
   desc = "Enable wrap and spell for text files",
   callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
   end,
})

-- Override makefile tab settings (prefer spaces)
vim.api.nvim_create_autocmd("FileType", {
   pattern = "make",
   desc = "Use spaces in makefiles",
   callback = function()
      vim.opt_local.expandtab = true
   end,
})

-- ========================================
-- UI & Visual Feedback
-- ========================================

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
   desc = "Highlight yanked text",
   callback = function()
      vim.highlight.on_yank { higroup = "Visual", timeout = 200 }
   end,
})

-- Equalize window sizes when Vim is resized
vim.api.nvim_create_autocmd("VimResized", {
   desc = "Equalize window sizes on resize",
   callback = function()
      vim.cmd.tabdo "wincmd ="
   end,
})

-- ========================================
-- Terminal
-- ========================================

-- Setup terminal buffer settings
vim.api.nvim_create_autocmd("TermOpen", {
   pattern = "term://*",
   desc = "Setup terminal buffer keymaps and settings",
   callback = function()
      -- Map jk to exit terminal mode
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = 0, desc = "Exit terminal mode" })

      -- Don't list claude-code buffers in buffer list
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname:match "claude" then
         vim.bo.buflisted = false
      end
   end,
})

-- ========================================
-- File Auto-reload
-- ========================================

local refresh_group = vim.api.nvim_create_augroup("FileRefresh", { clear = true })

-- Check for file changes when focus is gained or buffer is entered
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
   group = refresh_group,
   desc = "Check for external file changes",
   callback = function()
      if vim.fn.filereadable(vim.fn.expand "%") == 1 then
         vim.cmd.checktime()
      end
   end,
})

-- Periodic check for file changes (every second)
---@diagnostic disable-next-line: undefined-field
local refresh_timer = vim.uv.new_timer()
if refresh_timer then
   refresh_timer:start(
      0,
      1000,
      vim.schedule_wrap(function()
         vim.cmd "silent! checktime"
      end)
   )
end

-- Notify when file is changed externally
vim.api.nvim_create_autocmd("FileChangedShellPost", {
   group = refresh_group,
   desc = "Notify on external file change",
   callback = function()
      vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
   end,
})

-- ========================================
-- Exit Handling
-- ========================================
--
-- Custom quit commands that cleanup terminal buffers before exiting to prevent errors like:
--   E948: Job still running
--   E676: No matching autocommands for buftype= buffer
--
-- These errors occur when Neovim tries to quit with active terminal jobs running.
-- By stopping jobs and wiping terminal buffers first, we avoid the blocking prompt.

-- Helper function to cleanup terminal buffers before quitting
local function cleanup_terminals()
   for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
         local ok, chan = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
         if ok and chan then
            pcall(vim.fn.jobstop, chan)
         end
         ---@diagnostic disable-next-line: param-type-mismatch
         pcall(vim.cmd, "bwipeout! " .. buf)
      end
   end
end

-- Override quit commands to handle terminal buffers cleanly
local quit_commands = {
   { name = "Qa", cmd = "qall", desc = "Quit all with terminal cleanup" },
   { name = "Wqa", cmd = "wqall", desc = "Write and quit all with terminal cleanup" },
}

for _, cmd_config in ipairs(quit_commands) do
   vim.api.nvim_create_user_command(cmd_config.name, function()
      cleanup_terminals()
      vim.cmd(cmd_config.cmd)
   end, { bang = true, desc = cmd_config.desc })
end
