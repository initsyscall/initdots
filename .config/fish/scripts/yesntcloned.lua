#!/usr/bin/env lua
-- =============================================================================
-- clonegitfiles.lua (Rebranded: Yesn't Cloned)
-- A self-contained script to download individual folders/files from GitHub
-- utilizing the GitHub REST API and Curl, styled with the 'themeInit' palette.
-- =============================================================================

-- =============================================================================
-- SECTION 1: DOMAIN DEFINITIONS & CONSTANTS (Theme & Theme Colors)
-- =============================================================================

local Theme = {
  palette = {
    bg            = { 22, 20, 35 },       -- #161423
    surface       = { 32, 29, 51 },       -- #201D33
    border        = { 50, 45, 74 },       -- #322D4A
    textPrimary   = { 224, 222, 244 },    -- #E0DEF4
    textSecondary = { 144, 140, 170 },    -- #908CAA
    textMuted     = { 110, 106, 134 },    -- #6E6A86
    kwd           = { 162, 119, 255 },    -- #A277FF
    fnc           = { 255, 51, 102 },     -- #FF3366
    typ           = { 203, 166, 247 },    -- #CBA6F7
    str           = { 240, 135, 189 },    -- #F087BD
    num           = { 246, 193, 119 },    -- #F6C177
    opr           = { 128, 255, 234 }     -- #80FFEA
  }
}

--- Wraps a string in Truecolor (24-bit) ANSI escape sequences based on the theme palette.
-- @param text string The raw text to style
-- @param fg_key string The key in the theme palette for foreground color
-- @param bg_key string (Optional) The key for background color
-- @return string The ANSI-escaped string
function Theme.paint(text, fg_key, bg_key)
  local esc = ""
  if fg_key and Theme.palette[fg_key] then
    local r, g, b = table.unpack(Theme.palette[fg_key])
    esc = esc .. string.format("\27[38;2;%d;%d;%dm", r, g, b)
  end
  if bg_key and Theme.palette[bg_key] then
    local r, g, b = table.unpack(Theme.palette[bg_key])
    esc = esc .. string.format("\27[48;2;%d;%d;%dm", r, g, b)
  end
  return esc .. text .. "\27[0m"
end

-- =============================================================================
-- SECTION 2: DOMAIN MODELS (URL Parser Engine)
-- =============================================================================

local GithubUrlParser = {}

--- Parses standard GitHub URLs using path-tokenization to extract components.
-- Safely bypasses standard Lua pattern limits to cleanly resolve tree/blob depths.
-- @param raw_url string The user-provided URL
-- @return table|nil Table containing parsed fields, or nil if parse fails
-- @return string|nil Error message if parsing failed
function GithubUrlParser.parse(raw_url)
  if not raw_url or raw_url == "" then
    return nil, "URL string is empty."
  end

  -- Strip leading/trailing spaces, asterisks, queries, hashes, and trailing slashes
  local cleaned_url = raw_url:gsub("%s+", "")
      :gsub("%*+$", "")
      :gsub("%?.*$", "")
      :gsub("#.*$", "")
      :gsub("/+$", "")

  -- Strip protocol and domain components
  local path_part = cleaned_url:match("^https?://github%.com/(.+)$")
  if not path_part then
    return nil, "Not a valid GitHub URL (must start with http://github.com or https://github.com)."
  end

  -- Split path_part into directory segments
  local segments = {}
  for segment in path_part:gmatch("[^/]+") do
    table.insert(segments, segment)
  end

  if #segments < 2 then
    return nil, "URL must contain at least an owner and a repository name."
  end

  local owner = segments[1]
  local repo = segments[2]
  local path_type = nil
  local branch = "main"
  local path = ""

  if #segments >= 3 then
    local maybe_type = segments[3]
    if maybe_type == "tree" or maybe_type == "blob" then
      path_type = maybe_type
      if #segments >= 4 then
        branch = segments[4]
        if #segments >= 5 then
          local path_segments = {}
          for i = 5, #segments do
            table.insert(path_segments, segments[i])
          end
          path = table.concat(path_segments, "/")
        end
      end
    else
      -- No tree/blob segment specified; assume structural subpath directly
      path_type = "tree"
      local path_segments = {}
      for i = 3, #segments do
        table.insert(path_segments, segments[i])
      end
      path = table.concat(path_segments, "/")
    end
  end

  return {
    owner = owner,
    repo = repo,
    type = path_type or "tree",
    branch = branch,
    path = path
  }
end

-- =============================================================================
-- SECTION 3: APPLICATION SERVICES (Self-contained JSON Parser)
-- =============================================================================

local JsonDecoder = {}

--- Parses a raw JSON string into a structured Lua table.
-- Built from scratch to maintain zero external library dependencies.
-- @param str string The raw JSON payload
-- @return any Decoded Lua value or raises an error on failure
function JsonDecoder.decode(str)
  local pos = 1
  local function skip_whitespace()
    pos = string.find(str, "%S", pos) or #str + 1
  end

  local parse_value, parse_object, parse_array, parse_string, parse_number, parse_literal

  function parse_value()
    skip_whitespace()
    local char = string.sub(str, pos, pos)
    if char == "{" then
      return parse_object()
    elseif char == "[" then
      return parse_array()
    elseif char == '"' then
      return parse_string()
    elseif string.find(char, "[-0-9]") then
      return parse_number()
    elseif char == "t" or char == "f" or char == "n" then
      return parse_literal()
    else
      error("Unexpected JSON syntax token at position " .. pos .. ": '" .. char .. "'")
    end
  end

  function parse_object()
    local obj = {}
    pos = pos + 1     -- Skip open curly brace
    skip_whitespace()
    if string.sub(str, pos, pos) == "}" then
      pos = pos + 1
      return obj
    end
    while true do
      skip_whitespace()
      if string.sub(str, pos, pos) ~= '"' then error("Expected string key in object at position " .. pos) end
      local key = parse_string()
      skip_whitespace()
      if string.sub(str, pos, pos) ~= ":" then error("Expected ':' separator at position " .. pos) end
      pos = pos + 1       -- Skip colon
      local val = parse_value()
      obj[key] = val
      skip_whitespace()
      local next_char = string.sub(str, pos, pos)
      if next_char == "}" then
        pos = pos + 1
        break
      elseif next_char == "," then
        pos = pos + 1
      else
        error("Expected ',' or '}' separator inside object at position " .. pos)
      end
    end
    return obj
  end

  function parse_array()
    local arr = {}
    pos = pos + 1     -- Skip open bracket
    skip_whitespace()
    if string.sub(str, pos, pos) == "]" then
      pos = pos + 1
      return arr
    end
    while true do
      local val = parse_value()
      table.insert(arr, val)
      skip_whitespace()
      local next_char = string.sub(str, pos, pos)
      if next_char == "]" then
        pos = pos + 1
        break
      elseif next_char == "," then
        pos = pos + 1
      else
        error("Expected ',' or ']' separator inside array at position " .. pos)
      end
    end
    return arr
  end

  function parse_string()
    pos = pos + 1     -- Skip opening quote
    local start = pos
    while true do
      local next_pos = string.find(str, '"', pos)
      if not next_pos then error("Unclosed JSON string starting from position " .. start) end
      local escapes = 0
      local check = next_pos - 1
      while string.sub(str, check, check) == "\\" do
        escapes = escapes + 1
        check = check - 1
      end
      if escapes % 2 == 0 then
        pos = next_pos + 1
        local val = string.sub(str, start, next_pos - 1)
        val = val:gsub("\\\\", "\\"):gsub("\\\"", "\""):gsub("\\n", "\n"):gsub("\\r", "\r"):gsub("\\t", "\t")
        return val
      else
        pos = next_pos + 1
      end
    end
  end

  function parse_number()
    local _, last = string.find(str, "^%-?%d+%.?%d*[eE]?[-+]?%d*", pos)
    if not last then error("Malformed number structure at position " .. pos) end
    local val = tonumber(string.sub(str, pos, last))
    pos = last + 1
    return val
  end

  function parse_literal()
    if string.sub(str, pos, pos + 3) == "true" then
      pos = pos + 4
      return true
    elseif string.sub(str, pos, pos + 4) == "false" then
      pos = pos + 5
      return false
    elseif string.sub(str, pos, pos + 3) == "null" then
      pos = pos + 4
      return nil
    else
      error("Unknown literal configuration at position " .. pos)
    end
  end

  local status, result = pcall(parse_value)
  if status then
    return result
  else
    return nil, result
  end
end

-- =============================================================================
-- SECTION 4: INFRASTRUCTURE ADAPTERS (Curl & FS Operations)
-- =============================================================================

local HttpEngine = {}

--- Validates whether curl is installed and available in system PATH.
-- @return boolean True if curl is present
function HttpEngine.validate_curl()
  local handle = io.popen("curl --version 2>&1")
  if not handle then return false end
  local output = handle:read("*a")
  handle:close()
  return output and output:match("^curl") ~= nil
end

--- Issues a GET request using standard system curl.
-- @param url string Target HTTP endpoint
-- @param headers table Key-value headers map
-- @return string|nil Response body
-- @return boolean True if execution completed successfully
function HttpEngine.get(url, headers)
  local cmd = { "curl", "-sSL" }
  table.insert(cmd, "-H")
  table.insert(cmd, [["Accept: application/vnd.github.v3+json"]])

  if headers then
    for k, v in pairs(headers) do
      table.insert(cmd, "-H")
      table.insert(cmd, string.format("%q", k .. ": " .. v))
    end
  end
  table.insert(cmd, string.format("%q", url))

  local handle = io.popen(table.concat(cmd, " "))
  if not handle then return nil, false end
  local response = handle:read("*a")
  local _, _, code = handle:close()
  return response, (code == 0 or code == nil)
end

--- Direct file down-streamer using local system curl layout creation.
-- @param url string Direct downloadable binary or text link
-- @param destination_path string Target filesystem path
-- @return boolean True if operation completed with exit status 0
function HttpEngine.download_file(url, destination_path)
  local cmd = string.format("curl -sSL --create-dirs -o %q %q", destination_path, url)
  local exit_status = os.execute(cmd)
  if type(exit_status) == "number" then
    return exit_status == 0
  else
    return exit_status == true
  end
end

-- =============================================================================
-- SECTION 5: DOMAIN CONTROLLER (Crawl Orchestration Engine)
-- =============================================================================

local Crawler = {}

--- Calculates the relative path offset of a discovered sub-asset
-- @param asset_path string Full path of item inside Git tree
-- @param base_path string Base folder directory entry path
-- @return string Truncated asset path relative to target folder directory
local function get_relative_offset(asset_path, base_path)
  if base_path == "" then return asset_path end
  local escaped_base = base_path:gsub("([^%w])", "%%%1")
  local rel = asset_path:gsub("^" .. escaped_base .. "/?", "")
  return rel
end

--- Recursively traverses GitHub Directory APIs and schedules payloads downloading.
-- @param parsed_url table Configured url specification map
-- @param local_dir string Root workspace directories destination
-- @param current_path string Iterative segment inside nested trees
-- @param file_list_out table Collection recording downloaded local file layouts
-- @return boolean True if successfully navigated without critical breaks
-- @return string|nil Error details on failure
function Crawler.traverse(parsed_url, local_dir, current_path, file_list_out)
  local api_endpoint = string.format(
    "https://api.github.com/repos/%s/%s/contents/%s?ref=%s",
    parsed_url.owner,
    parsed_url.repo,
    current_path,
    parsed_url.branch
  )

  local headers = { ["User-Agent"] = "Yesnt-Cloned-Downloader" }
  local token = os.getenv("GITHUB_TOKEN")
  if token and token ~= "" then
    headers["Authorization"] = "token " .. token
  end

  local raw_payload, success = HttpEngine.get(api_endpoint, headers)
  if not success or not raw_payload then
    return false, "Network query down. API Server connection failed."
  end

  local data, parse_err = JsonDecoder.decode(raw_payload)
  if not data then
    return false, "Payload parsing failure: " .. (parse_err or "Unknown pattern error.")
  end

  if type(data) == "table" and data.message then
    return false, "GitHub API Warning: " .. data.message
  end

  -- Case 1: Handle standalone isolated file return
  if type(data) == "table" and data.type == "file" then
    local target_name = get_relative_offset(data.path, parsed_url.path)
    local destination = (local_dir .. "/" .. target_name):gsub("//+", "/")

    io.write(Theme.paint("    -> Fetching file: ", "textSecondary") .. Theme.paint(target_name, "str") .. "\n")
    local dl_ok = HttpEngine.download_file(data.download_url, destination)
    if dl_ok then
      table.insert(file_list_out, destination)
    else
      io.write(Theme.paint("       [FAIL] Critical network block writing file.\n", "fnc"))
    end
    return true
  end

  -- Case 2: Array representing Directory entries
  if type(data) == "table" then
    for _, node in ipairs(data) do
      if node.type == "file" then
        local relative_to_root = get_relative_offset(node.path, parsed_url.path)
        local destination = (local_dir .. "/" .. relative_to_root):gsub("//+", "/")

        io.write(Theme.paint("    -> Fetching file: ", "textSecondary") .. Theme.paint(relative_to_root, "str") .. "\n")
        local dl_ok = HttpEngine.download_file(node.download_url, destination)
        if dl_ok then
          table.insert(file_list_out, destination)
        else
          io.write(Theme.paint("       [FAIL] Download execution terminated early.\n", "fnc"))
        end
      elseif node.type == "dir" then
        local ok, err = Crawler.traverse(parsed_url, local_dir, node.path, file_list_out)
        if not ok then return false, err end
      end
    end
    return true
  end

  return false, "Unexpected Response: Format did not match File/Directory payload structures."
end

-- =============================================================================
-- SECTION 6: PRESENTATION LAYER (Interactive Terminal User Experience Interface)
-- =============================================================================

local CLI = {}

function CLI.print_banner()
  local bdr = Theme.paint("+--------------------------------------------------+", "border")
  local logo = Theme.paint("                 Yesn't Cloned                      ", "kwd")
  local title = Theme.paint("      \"Yes, I want files; No, I won't clone\"       ", "textPrimary")
  local shadow = Theme.paint("            Developed in Zero-Trust Lua            ", "textMuted")

  print(bdr)
  print(string.format("%s%s%s", Theme.paint("|", "border"), logo, Theme.paint("|", "border")))
  print(string.format("%s%s%s", Theme.paint("|", "border"), title, Theme.paint("|", "border")))
  print(string.format("%s%s%s", Theme.paint("|", "border"), shadow, Theme.paint("|", "border")))
  print(bdr)
  print()
end

function CLI.prompt(message, default_val, fg_key)
  local display_prompt = Theme.paint(message, fg_key or "textSecondary")
  if default_val then
    display_prompt = display_prompt .. Theme.paint(" [default: " .. default_val .. "]", "textMuted")
  end
  io.write(display_prompt .. Theme.paint("> ", "opr"))
  io.flush()
  local answer = io.read()
  if not answer then return nil end
  answer = answer:gsub("\r", ""):gsub("\n", "")
  if answer == "" then
    return default_val
  end
  return answer
end

function CLI.execute()
  CLI.print_banner()

  if not HttpEngine.validate_curl() then
    print(Theme.paint("[CRITICAL ERROR]: The 'curl' binary is not found in your PATH environment.", "fnc"))
    os.exit(1)
  end

  while true do
    print(Theme.paint("Select download mode:", "typ"))
    print("  " .. Theme.paint("1.", "num") .. " Standalone File")
    print("  " .. Theme.paint("2.", "num") .. " Repository Directory Folder")
    print("  " .. Theme.paint("3.", "num") .. " Exit Program")
    print()

    local choice = CLI.prompt("Selection option (1, 2, or 3)", "2", "textPrimary")
    if not choice or choice == "3" then
      print(Theme.paint("Exiting gracefully. Clean run terminated.", "textMuted"))
      break
    end

    if choice ~= "1" and choice ~= "2" then
      print(Theme.paint("[!] Invalid choice option. Select 1, 2, or 3.\n", "fnc"))
    else
      local target_url = CLI.prompt("Repo Path (GitHub URL String)")
      if not target_url or target_url == "" then
        print(Theme.paint("[!] URL string is mandatory to proceed.\n", "fnc"))
      else
        local parsed_spec, err = GithubUrlParser.parse(target_url)
        if not parsed_spec then
          print(Theme.paint("[!] Encountered parsing issues: " .. err .. "\n", "fnc"))
        else
          local default_target_dir = "."
          if parsed_spec.path ~= "" then
            default_target_dir = "./" .. parsed_spec.path:match("([^/]+)$")
          else
            default_target_dir = "./" .. parsed_spec.repo
          end

          local dest_path = CLI.prompt("Local Target Path Directory", default_target_dir, "textPrimary")
          print()
          print(Theme.paint("[+] Resolving Asset Path Details via API...", "typ"))
          print(Theme.paint("    - Owner:  ", "textMuted") .. Theme.paint(parsed_spec.owner, "num"))
          print(Theme.paint("    - Repo:   ", "textMuted") .. Theme.paint(parsed_spec.repo, "num"))
          print(Theme.paint("    - Branch: ", "textMuted") .. Theme.paint(parsed_spec.branch, "num"))
          print(Theme.paint("    - Path:   ", "textMuted") ..
          Theme.paint(parsed_spec.path == "" and "/" or parsed_spec.path, "num"))
          print()

          local downloaded_files = {}
          local execution_ok, execution_err = Crawler.traverse(parsed_spec, dest_path, parsed_spec.path, downloaded_files)

          if execution_ok then
            print()
            print(Theme.paint("[√] Download sequence completed successfully.", "opr"))
            print(Theme.paint("Cloned files inside directory: ", "textPrimary") .. Theme.paint(dest_path, "num"))
            for _, file in ipairs(downloaded_files) do
              print("  - " .. Theme.paint(file, "str"))
            end
            print()
          else
            print()
            print(Theme.paint("[!] Sync halted midway due to critical execution barrier:", "fnc"))
            print("    " .. Theme.paint(execution_err or "Unknown system error.", "textPrimary"))
            print()
          end
        end
      end
    end
  end
end

CLI.execute()
