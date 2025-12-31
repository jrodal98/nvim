local M = {}

---Add a plugin spec by module name
---@param item string Module name (e.g., "user.telescope")
function M.add_spec(spec, item)
   local ok, module = pcall(require, item)

   if ok and type(module) == "table" then
      local plugin_name = item:match "%.([^%.]+)$" or item
      local is_github_repo = type(module[1]) == "string" and module[1]:match "/"
      local needs_auto_config = not module.dir and not module.name and not module.main and not is_github_repo

      if needs_auto_config then
         local local_plugin_path = vim.fn.stdpath "config" .. "/lua/local_plugins/" .. plugin_name
         if vim.fn.isdirectory(local_plugin_path) == 1 then
            module.dir = local_plugin_path
            module.name = plugin_name
            module.main = "local_plugins." .. plugin_name
            table.insert(spec, module)
            return
         end
      end
   end

   table.insert(spec, { import = item })
end

return M
