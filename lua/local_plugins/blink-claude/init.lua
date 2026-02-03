-- ============================================================================
-- blink-claude: Claude Code Skills/Commands Completion Source
-- ============================================================================
-- Provides autocomplete for /skill and /command names in claude-prompt* files
-- Triggers only after '/' in markdown buffers with 'claude-prompt' prefix
--
-- Architecture:
--   1. File Scanner Module - Pure functions for filesystem operations
--   2. Cache Manager - Session-scoped state management
--   3. Blink.cmp Provider - Protocol implementation
-- ============================================================================

--- @class blink.cmp.Source
local source = {}

-- Configuration for testing (can be overridden by tests)
local config = {
  home_dir = nil, -- Will use vim.env.HOME if nil
}

-- ============================================================================
-- Section 1: File Scanner Module (Pure Functions)
-- ============================================================================

--- Get home directory (supports override for testing)
--- @return string Home directory path
local function get_home_dir()
  return config.home_dir or vim.env.HOME or vim.fn.expand("~")
end

--- Skip YAML frontmatter and return the line number after it
--- @param lines string[] File lines
--- @return number Line number after frontmatter (1-indexed), or 1 if no frontmatter
local function skip_frontmatter(lines)
  if not lines[1] or lines[1] ~= "---" then
    return 1
  end

  for i = 2, #lines do
    if lines[i] == "---" then
      return i + 1
    end
  end

  return 1 -- Malformed frontmatter
end

--- Extract description from YAML frontmatter
--- @param lines string[] File lines
--- @return string|nil Description or nil
local function parse_yaml_description(lines)
  if not lines[1] or lines[1] ~= "---" then
    return nil
  end

  local in_description = false
  local description_parts = {}

  for i = 2, #lines do
    local line = lines[i]

    if line == "---" then
      break
    end

    if line:match("^description:%s*(.*)$") then
      local inline_desc = line:match("^description:%s*(.+)$")
      if inline_desc then
        return inline_desc:gsub('^"', ''):gsub('"$', '')
      end
      in_description = true
    elseif in_description then
      if line:match("^%w+:") then
        break
      elseif line:match("^%s+(.+)$") then
        local content = line:match("^%s+(.+)$")
        table.insert(description_parts, content)
      end
    end
  end

  if #description_parts > 0 then
    return table.concat(description_parts, " ")
  end

  return nil
end

--- Extract first non-empty content line after frontmatter
--- @param lines string[] File lines
--- @return string|nil First content line or nil
local function extract_first_content_line(lines)
  local start_line = skip_frontmatter(lines)

  for i = start_line, #lines do
    local trimmed = lines[i]:match("^%s*(.-)%s*$")
    if trimmed and #trimmed > 0 and not trimmed:match("^#") then
      return trimmed
    end
  end

  return nil
end

--- Extract description from a skill or command file
--- @param file_path string Path to the .md file
--- @param item_type string Either "skill" or "command"
--- @return string|nil Description text or nil
local function extract_description(file_path, item_type)
  local ok, lines = pcall(vim.fn.readfile, file_path, "", 50)
  if not ok or not lines then
    return nil
  end

  -- Try frontmatter description first
  local desc = parse_yaml_description(lines)
  if desc then
    return desc
  end

  -- Fallback to first content line for commands
  if item_type == "command" then
    return extract_first_content_line(lines)
  end

  return nil
end

--- Create a completion item
--- @param name string The skill/command name
--- @param description string|nil Optional description
--- @param file_path string Path to the source file
--- @param item_type string Either "skill" or "command"
--- @param scope string Either "user" or "project"
--- @param plugin_info table|nil Optional {name: string, source: string} for plugin items
--- @return blink.cmp.CompletionItem
local function create_completion_item(name, description, file_path, item_type, scope, plugin_info)
  local label, insertText, source_suffix

  if plugin_info then
    -- Plugin item: /plugin:name format
    label = "/" .. plugin_info.name .. ":" .. name
    insertText = plugin_info.name .. ":" .. name
    source_suffix = "\n\n(plugin:" .. plugin_info.name .. "@" .. plugin_info.source .. ")"
  else
    -- Core item: /name format
    label = "/" .. name
    insertText = name
    source_suffix = scope == "user" and "\n\n(user)" or "\n\n(project)"
  end

  local doc_value = description
    and (description .. source_suffix)
    or ('Claude ' .. item_type .. ': ' .. name .. source_suffix)

  local data = {
    source = "claude",
    file = file_path,
    type = item_type,
    scope = scope,
  }

  if plugin_info then
    data.plugin = plugin_info.name
    data.plugin_source = plugin_info.source
  end

  return {
    label = label,
    kind = 23, -- CompletionItemKind.Event (󰉁 icon)
    insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
    insertText = insertText, -- Insert without leading /
    labelDetails = {
      description = "Claude",
    },
    documentation = {
      kind = 'markdown',
      value = doc_value,
    },
    data = data,
  }
end

--- Walk up the directory tree and find all .claude directories
--- Always includes ~/.claude first
--- @return string[] List of .claude directory paths found (from cwd up to /)
local function find_claude_directories()
  local claude_dirs = {}
  local home = get_home_dir()
  local cwd = vim.fn.getcwd()
  local current = cwd
  local home_claude = home .. "/.claude"

  -- Always include ~/.claude first
  local stat = vim.uv.fs_stat(home_claude)
  if stat and stat.type == "directory" then
    table.insert(claude_dirs, home_claude)
  end

  -- Walk up from cwd to root
  while true do
    local claude_path = current .. "/.claude"
    local path_stat = vim.uv.fs_stat(claude_path)

    -- Add if it exists and is not already added (avoid duplicate ~/.claude)
    if path_stat and path_stat.type == "directory" and claude_path ~= home_claude then
      table.insert(claude_dirs, claude_path)
    end

    -- Check if we've reached the root
    if current == "/" then
      break
    end

    -- Move up one directory
    local parent = vim.fn.fnamemodify(current, ":h")
    if parent == current then
      -- Can't go up anymore
      break
    end
    current = parent
  end

  return claude_dirs
end

--- Parse installed plugins from JSON file
--- @param cwd string Current working directory for project matching
--- @return table<string, {path: string, source: string}> Map of plugin_name -> {path, source}
local function parse_installed_plugins(cwd)
  local plugins = {}
  local home = get_home_dir()
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
    local plugin_name, plugin_source = plugin_key:match("^([^@]+)@(.+)$")
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
            local parent_dir = install.installPath:match("^(.+)/[^/]+$")
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
    local skill_name = file_path:match("/([^/]+)/SKILL%.md$")
    return skill_name
  else
    -- For command *.md: use filename without extension
    -- Example: /path/commands/commit.md -> "commit"
    local cmd_name = file_path:match("/([^/]+)%.md$")
    -- Exclude SKILL.md files that might be matched by glob
    if cmd_name and cmd_name ~= "SKILL" then
      return cmd_name
    end
  end

  return nil
end

--- Scan all Claude directories and extract completion items
--- @param bufnr number|nil Buffer number (unused now, kept for compatibility)
--- @return blink.cmp.CompletionItem[]
local function scan_skills_and_commands(bufnr)
  local items = {}
  local seen = {} -- Track labels to avoid duplicates
  local home = get_home_dir()
  local cwd = vim.fn.getcwd()
  local home_claude = home .. "/.claude"

  -- Walk up directory tree and scan all .claude directories found
  local claude_dirs = find_claude_directories()

  for _, claude_dir in ipairs(claude_dirs) do
    -- Determine scope: "user" for ~/.claude, "project" for everything else
    local scope = (claude_dir == home_claude) and "user" or "project"

    local dir_configs = {
      { pattern = claude_dir .. "/skills/*/SKILL.md", type = "skill", scope = scope },
      { pattern = claude_dir .. "/commands/*.md", type = "command", scope = scope },
    }

    for _, config in ipairs(dir_configs) do
      local files = vim.fn.glob(config.pattern, false, true)

      for _, file_path in ipairs(files) do
        local name = extract_completion_name(file_path, config.type)
        if name then
          local label = "/" .. name

          -- Skip if we've already seen this label (avoid duplicates from symlinks)
          if not seen[label] then
            seen[label] = true

            local description = extract_description(file_path, config.type)
            local item = create_completion_item(name, description, file_path, config.type, config.scope, nil)
            table.insert(items, item)
          end
        end
      end
    end
  end

  -- Scan plugin skills and commands (with plugin: prefix)
  local plugins = parse_installed_plugins(cwd)

  for plugin_name, plugin_info in pairs(plugins) do
    local plugin_configs = {
      { pattern = plugin_info.path .. "/commands/*.md", type = "command" },
      { pattern = plugin_info.path .. "/skills/*/SKILL.md", type = "skill" },
    }

    for _, config in ipairs(plugin_configs) do
      local files = vim.fn.glob(config.pattern, false, true)

      for _, file_path in ipairs(files) do
        local name = extract_completion_name(file_path, config.type)
        if name then
          local label = "/" .. plugin_name .. ":" .. name

          -- Skip if we've already seen this label
          if not seen[label] then
            seen[label] = true

            local description = extract_description(file_path, config.type)
            local plugin_data = { name = plugin_name, source = plugin_info.source }
            -- Plugin items always have "user" scope (from plugin installation)
            local item = create_completion_item(name, description, file_path, config.type, "user", plugin_data)
            table.insert(items, item)
          end
        end
      end
    end
  end

  -- Sort alphabetically by label
  table.sort(items, function(a, b)
    return a.label < b.label
  end)

  return items
end

-- ============================================================================
-- Section 2: Cache Manager (Stateful)
-- ============================================================================

--- Session-scoped cache for completion items
local cache = {
  items = nil,           -- Cached completion items
  initialized = false,   -- Whether cache has been populated
}

--- Check if cache should be initialized for the given buffer
--- @param bufnr number Buffer number
--- @return boolean True if this is a claude-prompt markdown buffer and cache not initialized
local function should_initialize_cache(bufnr)
  if cache.initialized then
    return false
  end

  -- Check filetype
  if vim.bo[bufnr].filetype ~= "markdown" then
    return false
  end

  -- Check filename pattern
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local basename = vim.fn.fnamemodify(filename, ":t")

  return basename:match("^claude%-prompt") ~= nil
end

--- Get cached completion items, loading them if necessary
--- @param bufnr number Buffer number (for detecting /tmp and repo context)
--- @return blink.cmp.CompletionItem[] Completion items (may be empty on error)
local function get_cached_items(bufnr)
  if not cache.items then
    -- Attempt to scan and cache, with error handling
    local ok, items_or_err = pcall(scan_skills_and_commands, bufnr)
    if ok then
      cache.items = items_or_err
      cache.initialized = true
    else
      -- Log error for debugging, then fallback
      vim.notify(
        "blink-claude: Error scanning files: " .. tostring(items_or_err),
        vim.log.levels.WARN
      )
      cache.items = {}
      cache.initialized = true
    end
  end
  return cache.items
end

-- ============================================================================
-- Section 3: Blink.cmp Provider (Protocol Implementation)
-- ============================================================================

--- Check if completions should be shown in current context
--- @param ctx blink.cmp.Context Completion context
--- @param bufnr number Buffer number
--- @return boolean True if completions should be shown
local function should_show_completions(ctx, bufnr)
  -- Check filetype
  if vim.bo[bufnr].filetype ~= "markdown" then
    return false
  end

  -- Check filename pattern
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local basename = vim.fn.fnamemodify(filename, ":t")

  if not basename:match("^claude%-prompt") then
    return false
  end

  -- Check if cursor is positioned after / that starts a word
  local line = ctx.line
  local col = ctx.cursor[2]

  -- Check if we just typed / or are in the middle of completing after /
  if col > 0 then
    local before_cursor = line:sub(1, col)
    -- Match patterns like: "/", "/un", "/unslop"
    -- But NOT "path/to" - the / must be at start of line or after whitespace
    local slash_match = before_cursor:match("/%w*$")
    if slash_match then
      -- Find the position of the / in the line
      local slash_pos = col - #slash_match + 1

      -- Check that / is either at start of line or preceded by whitespace
      if slash_pos == 1 then
        -- / is at start of line
        return true
      elseif slash_pos > 1 then
        -- Check character before /
        local char_before = line:sub(slash_pos - 1, slash_pos - 1)
        if char_before:match("%s") then
          -- / is preceded by whitespace
          return true
        end
      end
    end
  end

  return false
end

--- Constructor for the source
--- @param opts table|nil Options (unused for this source)
--- @return blink.cmp.Source
function source.new(opts)
  local self = setmetatable({}, { __index = source })
  return self
end

--- Get trigger characters for this source
--- @return string[]
function source:get_trigger_characters()
  return { "/" }
end

--- Get completions for the current context
--- @param ctx blink.cmp.Context
--- @param callback fun(response: blink.cmp.CompletionResponse)
function source:get_completions(ctx, callback)
  local bufnr = vim.api.nvim_get_current_buf()

  -- Initialize cache on first claude-prompt buffer (lazy loading)
  if should_initialize_cache(bufnr) then
    get_cached_items(bufnr)
  end

  -- Check if we should show completions in this context
  if not should_show_completions(ctx, bufnr) then
    callback({
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = {},
    })
    return
  end

  -- Return cached items
  local items = cache.items or {}
  callback({
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = items,
  })
end

--- Configure the source (for testing)
--- @param opts table Options table with optional home_dir
function source.configure(opts)
  if opts.home_dir then
    config.home_dir = opts.home_dir
  end
end

--- Reset cache (for testing)
function source.reset_cache()
  cache.items = nil
  cache.initialized = false
end

return source
