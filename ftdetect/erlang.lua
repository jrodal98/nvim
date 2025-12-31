local extensions = {
   ".erl",
   ".hrl",
   ".app.src",
   ".app",
   ".escript",
   ".yrl",
   ".xrl",
}

for _, ext in ipairs(extensions) do
   vim.cmd("au BufRead,BufNewFile *" .. ext .. " set filetype=erlang")
end

local files = {
   "rebar.config",
   "rebar.lock",
   "rebar.config.script",
   "sys.config",
   "sys.config.src",
   "sys.lanyard.config.src",
   "sys.ct.config",
   "sys.shell.config",
}

for _, file in ipairs(files) do
   vim.cmd("au BufRead,BufNewFile */whatsapp/*" .. file .. " set filetype=erlang")
end
