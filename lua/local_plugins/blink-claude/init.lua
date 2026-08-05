-- ============================================================================
-- blink-claude: Claude Code Skills/Commands Completion Source
-- ============================================================================
-- Provides autocomplete for /skill and /command names in claude-prompt* files
-- Triggers only after '/' in markdown buffers with 'claude-prompt' prefix
--
-- Shared infrastructure (frontmatter parsing, argument-hint snippets, item
-- construction, cache, blink.cmp protocol) lives in
-- local_plugins.blink-agent-common; this module contains only Claude Code's
-- discovery logic (.claude dirs and plugins).
-- ============================================================================

---@module 'blink.cmp'

local fm = require "local_plugins.blink-agent-common.frontmatter"
local items_builder = require "local_plugins.blink-agent-common.items"
local common_source = require "local_plugins.blink-agent-common.source"
local util = require "local_plugins.blink-agent-common.util"

-- ============================================================================
-- File Scanner (Claude-specific)
-- ============================================================================

--- Create a completion item
--- @param name string The skill/command name
--- @param description string|nil Optional description
--- @param file_path string Path to the source file
--- @param item_type string Either "skill" or "command"
--- @param scope string Either "user" or "project"
--- @param plugin_info table|nil Optional {name: string, source: string} for plugin items
--- @param argument_hint string|nil Optional argument hint for snippets
--- @return blink.cmp.CompletionItem
local function create_completion_item(name, description, file_path, item_type, scope, plugin_info, argument_hint)
   local label, doc_suffix
   if plugin_info then
      label = "/" .. plugin_info.name .. ":" .. name
      doc_suffix = "\n\n(plugin:" .. plugin_info.name .. "@" .. plugin_info.source .. ")"
   else
      label = "/" .. name
      doc_suffix = "\n\n(" .. scope .. ")"
   end

   local data = {
      source = "claude",
      type = item_type,
      scope = scope,
   }

   if plugin_info then
      data.plugin = plugin_info.name
      data.plugin_source = plugin_info.source
   end

   return items_builder.make {
      label = label,
      source_label = "Claude",
      description = description,
      fallback_description = "Claude " .. item_type .. ": " .. name,
      doc_suffix = doc_suffix,
      argument_hint = argument_hint,
      file = file_path,
      data = data,
   }
end

--- Walk up the directory tree and find all .claude directories
--- Always includes ~/.claude first
--- @param home string Home directory
--- @return string[] List of .claude directory paths found (from cwd up to /)
local function find_claude_directories(home)
   local claude_dirs = {}
   local home_claude = home .. "/.claude"

   -- Always include ~/.claude first
   local stat = vim.uv.fs_stat(home_claude)
   if stat and stat.type == "directory" then
      table.insert(claude_dirs, home_claude)
   end

   -- Walk up from cwd to root
   util.walk_ancestors(function(dir)
      local claude_path = dir .. "/.claude"
      local path_stat = vim.uv.fs_stat(claude_path)

      -- Add if it exists and is not already added (avoid duplicate ~/.claude)
      if path_stat and path_stat.type == "directory" and claude_path ~= home_claude then
         table.insert(claude_dirs, claude_path)
      end
   end)

   return claude_dirs
end

--- Parse installed plugins from JSON file
--- @param cwd string Current working directory for project matching
--- @param home string Home directory
--- @return table<string, {path: string, source: string}> Map of plugin_name -> {path, source}
local function parse_installed_plugins(cwd, home)
   local plugins = {}
   local json_path = home .. "/.claude/plugins/installed_plugins.json"

   -- Check if file exists
   local stat = vim.uv.fs_stat(json_path)
   if not stat then
      return plugins
   end

   -- Read and parse JSON
   local ok, content = pcall(vim.fn.readfile, json_path)
   if not ok then
      return plugins
   end

   local json_str = table.concat(content, "\n")
   local data
   ok, data = pcall(vim.json.decode, json_str)
   if not ok or not data or not data.plugins then
      return plugins
   end

   -- Normalize cwd for comparison
   local normalized_cwd = cwd:gsub("/$", "")

   -- Extract plugin names and install paths
   for plugin_key, installations in pairs(data.plugins) do
      -- Extract plugin name and source from "plugin-name@source" format
      local plugin_name, plugin_source = plugin_key:match "^([^@]+)@(.+)$"
      if not plugin_name then
         plugin_name = plugin_key
         plugin_source = "unknown"
      end

      -- Use the first installation and check scope
      if plugin_name and installations[1] and installations[1].installPath then
         local install = installations[1]
         local scope = install.scope or "user"

         -- Include user-scoped plugins always
         if scope == "user" then
            plugins[plugin_name] = { path = install.installPath, source = plugin_source }
         -- Include project-scoped plugins if projectPath is cwd or any parent of cwd
         elseif scope == "project" and install.projectPath then
            local normalized_project = install.projectPath:gsub("/$", "")

            -- Check if cwd is within or equal to the project path (using string prefix, not pattern)
            local is_in_project = normalized_cwd == normalized_project
               or normalized_cwd:sub(1, #normalized_project + 1) == normalized_project .. "/"

            if is_in_project then
               -- Check if install path exists, if not try to find actual version directory
               local install_stat = vim.uv.fs_stat(install.installPath)
               local final_path = nil

               if install_stat then
                  final_path = install.installPath
               else
                  -- installPath might have "unknown" version, try to find actual directory
                  local parent_dir = install.installPath:match "^(.+)/[^/]+$"
                  if parent_dir then
                     local versions = vim.fn.glob(parent_dir .. "/*", false, true)
                     for _, version_dir in ipairs(versions) do
                        local version_stat = vim.uv.fs_stat(version_dir)
                        if version_stat and version_stat.type == "directory" then
                           final_path = version_dir
                           break
                        end
                     end
                  end
               end

               if final_path then
                  plugins[plugin_name] = { path = final_path, source = plugin_source }
               end
            end
         end
      end
   end

   return plugins
end

--- Extract command/skill name from file path
--- @param file_path string Full path to the file
--- @param item_type string Either "skill" or "command"
--- @return string|nil Name extracted from path, or nil if extraction failed
local function extract_completion_name(file_path, item_type)
   if item_type == "skill" then
      -- For SKILL.md: use parent directory name
      -- Example: /path/skills/unslop-code/SKILL.md -> "unslop-code"
      local skill_name = file_path:match "/([^/]+)/SKILL%.md$"
      return skill_name
   else
      -- For command *.md: use filename without extension
      -- Example: /path/commands/commit.md -> "commit"
      local cmd_name = file_path:match "/([^/]+)%.md$"
      -- Exclude SKILL.md files that might be matched by glob
      if cmd_name and cmd_name ~= "SKILL" then
         return cmd_name
      end
   end

   return nil
end

--- Extract description and argument hint from file
--- @param file_path string Path to the .md file
--- @param item_type string Either "skill" or "command"
--- @return string|nil description Description text or nil
--- @return string|nil argument_hint Argument hint or nil
local function extract_metadata(file_path, item_type)
   -- Commands fall back to the first non-empty line as description
   local meta = fm.extract(file_path, { first_line_fallback = item_type == "command" })
   return meta.description, meta.argument_hint
end

--- Scan all Claude directories and extract completion items
--- @param config {home_dir: string|nil} Source config (test home_dir override)
--- @return blink.cmp.CompletionItem[]
local function scan_skills_and_commands(config)
   local items = {}
   local seen = {} -- Track labels to avoid duplicates
   local home = util.home_of(config)
   local cwd = vim.fn.getcwd()
   local home_claude = home .. "/.claude"

   -- Walk up directory tree and scan all .claude directories found
   local claude_dirs = find_claude_directories(home)

   for _, claude_dir in ipairs(claude_dirs) do
      -- Determine scope: "user" for ~/.claude, "project" for everything else
      local scope = (claude_dir == home_claude) and "user" or "project"

      local dir_configs = {
         { pattern = claude_dir .. "/skills/*/SKILL.md", type = "skill", scope = scope },
         { pattern = claude_dir .. "/commands/*.md", type = "command", scope = scope },
      }

      for _, dir_config in ipairs(dir_configs) do
         local files = vim.fn.glob(dir_config.pattern, false, true)

         for _, file_path in ipairs(files) do
            local name = extract_completion_name(file_path, dir_config.type)
            if name then
               local label = "/" .. name

               -- Skip if we've already seen this label (avoid duplicates from symlinks)
               if not seen[label] then
                  seen[label] = true

                  local description, argument_hint = extract_metadata(file_path, dir_config.type)
                  local item = create_completion_item(
                     name,
                     description,
                     file_path,
                     dir_config.type,
                     dir_config.scope,
                     nil,
                     argument_hint
                  )
                  table.insert(items, item)
               end
            end
         end
      end
   end

   -- Scan plugin skills and commands (with plugin: prefix)
   local plugins = parse_installed_plugins(cwd, home)

   for plugin_name, plugin_info in pairs(plugins) do
      local plugin_configs = {
         { pattern = plugin_info.path .. "/commands/*.md", type = "command" },
         { pattern = plugin_info.path .. "/skills/*/SKILL.md", type = "skill" },
      }

      for _, dir_config in ipairs(plugin_configs) do
         local files = vim.fn.glob(dir_config.pattern, false, true)

         for _, file_path in ipairs(files) do
            local name = extract_completion_name(file_path, dir_config.type)
            if name then
               local label = "/" .. plugin_name .. ":" .. name

               -- Skip if we've already seen this label
               if not seen[label] then
                  seen[label] = true

                  local description, argument_hint = extract_metadata(file_path, dir_config.type)
                  local plugin_data = { name = plugin_name, source = plugin_info.source }
                  -- Plugin items always have "user" scope (from plugin installation)
                  local item = create_completion_item(
                     name,
                     description,
                     file_path,
                     dir_config.type,
                     "user",
                     plugin_data,
                     argument_hint
                  )
                  table.insert(items, item)
               end
            end
         end
      end
   end

   return items
end

-- ============================================================================
-- Source (shared blink.cmp provider from blink-agent-common)
-- ============================================================================

return common_source.make {
   name = "blink-claude",
   filename_pattern = "^claude%-prompt",
   scan = scan_skills_and_commands,
}
