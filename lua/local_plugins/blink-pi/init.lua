-- ============================================================================
-- blink-pi: Pi Skills/Prompt-Template Completion Source
-- ============================================================================
-- Provides autocomplete for /skill:name and /prompt-template names in
-- pi-editor-*/prompt.md files (pi's external editor buffers).
-- Triggers only after '/' in markdown buffers at that path.
--
-- Shared infrastructure (frontmatter parsing, argument-hint snippets, item
-- construction, cache, blink.cmp protocol) lives in
-- local_plugins.blink-agent-common; this module contains only pi's discovery
-- logic.
-- ============================================================================

---@module 'blink.cmp'

local fm = require "local_plugins.blink-agent-common.frontmatter"
local items_builder = require "local_plugins.blink-agent-common.items"
local common_source = require "local_plugins.blink-agent-common.source"
local util = require "local_plugins.blink-agent-common.util"

-- ============================================================================
-- File Scanner (pi-specific)
-- ============================================================================

--- Extract name, description and argument hint from file
--- @param file_path string Path to the .md file
--- @param item_type string Either "skill" or "prompt"
--- @return string|nil name Frontmatter name or nil
--- @return string|nil description Description text or nil
--- @return string|nil argument_hint Argument hint or nil
local function extract_metadata(file_path, item_type)
   -- Prompt templates fall back to the first non-empty line as description
   local meta = fm.extract(file_path, { first_line_fallback = item_type == "prompt" })
   return meta.name, meta.description, meta.argument_hint
end

--- Create a completion item
--- @param name string The skill/prompt-template name
--- @param description string|nil Optional description
--- @param file_path string Path to the source file
--- @param item_type string Either "skill" or "prompt"
--- @param scope string Origin label, e.g. "user", "project", "settings"
--- @param argument_hint string|nil Optional argument hint for snippets
--- @return blink.cmp.CompletionItem
local function create_completion_item(name, description, file_path, item_type, scope, argument_hint)
   -- Pi invokes skills as /skill:name, prompt templates as /name
   local label = item_type == "skill" and ("/skill:" .. name) or ("/" .. name)
   local type_label = item_type == "skill" and "skill" or "prompt template"

   return items_builder.make {
      label = label,
      source_label = "Pi",
      description = description,
      fallback_description = "Pi " .. type_label .. ": " .. name,
      doc_suffix = "\n\n(" .. scope .. ")",
      argument_hint = argument_hint,
      file = file_path,
      data = {
         source = "pi",
         type = item_type,
         scope = scope,
      },
   }
end

--- Maximum directory depth for recursive SKILL.md discovery
local MAX_SKILL_DEPTH = 4

--- Recursively find SKILL.md files under a directory.
--- Follows symlinks (vim's `**` glob does not, and skill dirs are commonly
--- symlinked), guards against symlink loops via realpath tracking, and caps
--- recursion depth to avoid pathological trees.
--- @param root string Directory to search
--- @return string[] Paths to SKILL.md files (root's own SKILL.md excluded)
local function find_skill_md_files(root)
   local results = {}
   local visited = {}

   local function walk(dir, depth)
      local real = vim.uv.fs_realpath(dir) or dir
      if visited[real] then
         return
      end
      visited[real] = true

      if depth > 0 then
         local skill_md = dir .. "/SKILL.md"
         local stat = vim.uv.fs_stat(skill_md)
         if stat and stat.type == "file" then
            table.insert(results, skill_md)
         end
      end

      if depth >= MAX_SKILL_DEPTH then
         return
      end

      for _, entry in ipairs(vim.fn.glob(dir .. "/*", false, true)) do
         -- fs_stat follows symlinks, unlike fs_scandir entry types
         local stat = vim.uv.fs_stat(entry)
         if stat and stat.type == "directory" then
            walk(entry, depth + 1)
         end
      end
   end

   walk(root, 0)
   return results
end

--- Resolve a settings path entry (supports ~ and relative paths)
--- @param entry string Path entry from settings.json
--- @param base_dir string Directory of the settings file (for relative paths)
--- @param home string Home directory
--- @return string Absolute path
local function resolve_settings_path(entry, base_dir, home)
   if entry:sub(1, 1) == "~" then
      return home .. entry:sub(2)
   elseif entry:sub(1, 1) == "/" then
      return entry
   else
      return base_dir .. "/" .. entry
   end
end

--- Parse the "skills" array from a pi settings.json file
--- @param settings_path string Path to settings.json
--- @param home string Home directory
--- @return string[] Resolved absolute paths (may be files or directories)
local function parse_settings_skill_paths(settings_path, home)
   local paths = {}

   local stat = vim.uv.fs_stat(settings_path)
   if not stat then
      return paths
   end

   local ok, content = pcall(vim.fn.readfile, settings_path)
   if not ok then
      return paths
   end

   local data
   ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
   if not ok or type(data) ~= "table" or type(data.skills) ~= "table" then
      return paths
   end

   local base_dir = vim.fn.fnamemodify(settings_path, ":h")
   for _, entry in ipairs(data.skills) do
      if type(entry) == "string" then
         table.insert(paths, (resolve_settings_path(entry, base_dir, home):gsub("/$", "")))
      end
   end

   return paths
end

--- @class PiSkillLocation
--- @field dir string Directory to scan
--- @field scope string Origin label
--- @field root_md boolean Whether root *.md files are individual skills

--- Collect all skill locations in pi's discovery order (first found wins)
--- @param home string Home directory
--- @return PiSkillLocation[] locations
--- @return {path: string, scope: string}[] skill_files Individual skill files from settings
local function find_skill_locations(home)
   local locations = {}
   local skill_files = {}
   local seen_dirs = {}

   local function add_dir(dir, scope, root_md)
      if seen_dirs[dir] then
         return
      end

      local stat = vim.uv.fs_stat(dir)
      if stat and stat.type == "directory" then
         seen_dirs[dir] = true
         table.insert(locations, { dir = dir, scope = scope, root_md = root_md })
      end
   end

   local function add_settings_entries(settings_path, scope)
      for _, path in ipairs(parse_settings_skill_paths(settings_path, home)) do
         local stat = vim.uv.fs_stat(path)
         if stat then
            if stat.type == "directory" then
               add_dir(path, scope, false)
            else
               table.insert(skill_files, { path = path, scope = scope })
            end
         end
      end
   end

   -- Global locations
   add_dir(home .. "/.pi/agent/skills", "user", true)
   add_dir(home .. "/.agents/skills", "user", false)

   -- Project locations (cwd and ancestors)
   util.walk_ancestors(function(dir)
      add_dir(dir .. "/.pi/skills", "project", true)
      add_dir(dir .. "/.agents/skills", "project", false)
   end)

   -- Settings-configured locations
   add_settings_entries(home .. "/.pi/agent/settings.json", "settings")
   util.walk_ancestors(function(dir)
      add_settings_entries(dir .. "/.pi/settings.json", "settings")
   end)

   return locations, skill_files
end

--- Collect all prompt template directories
--- @param home string Home directory
--- @return {dir: string, scope: string}[]
local function find_prompt_locations(home)
   local locations = {}
   local seen_dirs = {}

   local function add_dir(dir, scope)
      if seen_dirs[dir] then
         return
      end

      local stat = vim.uv.fs_stat(dir)
      if stat and stat.type == "directory" then
         seen_dirs[dir] = true
         table.insert(locations, { dir = dir, scope = scope })
      end
   end

   add_dir(home .. "/.pi/agent/prompts", "user")

   util.walk_ancestors(function(dir)
      add_dir(dir .. "/.pi/prompts", "project")
   end)

   return locations
end

--- Scan all pi locations and extract completion items
--- @param config {home_dir: string|nil} Source config (test home_dir override)
--- @return blink.cmp.CompletionItem[]
local function scan_skills_and_prompts(config)
   local items = {}
   local seen = {} -- Track labels to avoid duplicates (first found wins, like pi)
   local home = util.home_of(config)

   local function add_item(name, item_type, file_path, scope, fm_name, description, hint)
      name = fm_name or name
      if not name then
         return
      end

      local label = item_type == "skill" and ("/skill:" .. name) or ("/" .. name)
      if seen[label] then
         return
      end
      seen[label] = true

      table.insert(items, create_completion_item(name, description, file_path, item_type, scope, hint))
   end

   -- Prompt templates: /name from <dir>/*.md (non-recursive, filename is the command name)
   for _, loc in ipairs(find_prompt_locations(home)) do
      local files = vim.fn.glob(loc.dir .. "/*.md", false, true)

      for _, file_path in ipairs(files) do
         local name = file_path:match "/([^/]+)%.md$"
         if name then
            local _, description, hint = extract_metadata(file_path, "prompt")
            add_item(name, "prompt", file_path, loc.scope, nil, description, hint)
         end
      end
   end

   -- Skills: /skill:name
   local skill_locations, skill_files = find_skill_locations(home)

   for _, loc in ipairs(skill_locations) do
      -- Directories containing SKILL.md, discovered recursively (follows symlinks)
      local files = find_skill_md_files(loc.dir)

      for _, file_path in ipairs(files) do
         local dir_name = file_path:match "/([^/]+)/SKILL%.md$"
         local fm_name, description, hint = extract_metadata(file_path, "skill")
         add_item(dir_name, "skill", file_path, loc.scope, fm_name, description, hint)
      end

      -- Direct root *.md files as individual skills (~/.pi/agent/skills and .pi/skills only)
      if loc.root_md then
         local md_files = vim.fn.glob(loc.dir .. "/*.md", false, true)

         for _, file_path in ipairs(md_files) do
            local file_name = file_path:match "/([^/]+)%.md$"
            if file_name and file_name ~= "SKILL" then
               local fm_name, description, hint = extract_metadata(file_path, "skill")
               add_item(file_name, "skill", file_path, loc.scope, fm_name, description, hint)
            end
         end
      end
   end

   -- Individual skill files from settings
   for _, entry in ipairs(skill_files) do
      local file_name = entry.path:match "/([^/]+)%.md$"
      if file_name then
         if file_name == "SKILL" then
            file_name = entry.path:match "/([^/]+)/SKILL%.md$"
         end
         local fm_name, description, hint = extract_metadata(entry.path, "skill")
         add_item(file_name, "skill", entry.path, entry.scope, fm_name, description, hint)
      end
   end

   return items
end

-- ============================================================================
-- Source (shared blink.cmp provider from blink-agent-common)
-- ============================================================================

return common_source.make {
   name = "blink-pi",
   path_pattern = "/pi%-editor%-[^/]+/prompt%.md$",
   scan = scan_skills_and_prompts,
}
