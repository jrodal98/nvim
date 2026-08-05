" Buck/Starlark files: ft=starlark (for LSP) with bzl syntax highlighting.
" Kept as an ftdetect autocmd (not vim.filetype.add) because `syntax=bzl`
" must be set *after* filetype, or the syntax loader overrides it.
au BufRead,BufNewFile *.sky,*.bxl,*.bzl,TARGETS{.v2,},BUCK{.v2,},DEFS,BUILD,PACKAGE    set filetype=starlark syntax=bzl
