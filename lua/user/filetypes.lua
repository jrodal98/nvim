-- Filetype detection.
-- Note: starlark/Buck files (BUCK, TARGETS, *.bzl, ...) are detected in
-- ftdetect/starlark.vim instead, because they also need `syntax=bzl`, which
-- vim.filetype.add cannot express (the syntax loader would override it).

local public_configs = {
   -- Erlang
   {
      extension = {
         erl = "erlang",
         hrl = "erlang",
         app = "erlang",
         escript = "erlang",
         yrl = "erlang",
         xrl = "erlang",
      },
      pattern = {
         [".*%.app%.src$"] = "erlang",
         -- WhatsApp rebar/sys config files
         [".*/whatsapp/.*rebar%.config$"] = "erlang",
         [".*/whatsapp/.*rebar%.lock$"] = "erlang",
         [".*/whatsapp/.*rebar%.config%.script$"] = "erlang",
         [".*/whatsapp/.*sys%.config$"] = "erlang",
         [".*/whatsapp/.*sys%.config%.src$"] = "erlang",
         [".*/whatsapp/.*sys%.lanyard%.config%.src$"] = "erlang",
         [".*/whatsapp/.*sys%.ct%.config$"] = "erlang",
         [".*/whatsapp/.*sys%.shell%.config$"] = "erlang",
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
