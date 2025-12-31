local public_configs = {
   {
      extension = {
         bzl = "starlark",
      },
      filename = {
         BUCK = "starlark",
         TARGETS = "starlark",
         PACKAGE = "starlark",
      },
   },
}

-- Load Meta-specific filetype configs if available
local ok, filetypes_provider = pcall(require, "meta-private.filetypes.config")
if ok then
   local meta_configs = filetypes_provider.get()
   if meta_configs and #meta_configs > 0 then
      -- Append Meta configs to public configs
      for _, config in ipairs(meta_configs) do
         table.insert(public_configs, config)
      end
   end
end

-- Register all filetype configs
for _, config in ipairs(public_configs) do
   vim.filetype.add(config)
end
