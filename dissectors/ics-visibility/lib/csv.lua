-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (lib/csv.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- lib/csv.lua
--
-- Shared CSV helpers for ICS Visibility.

local source = debug.getinfo(1, "S").source

if source:sub(1, 1) == "@" then
  source = source:sub(2)
end

source = source:gsub("\\", "/")

local root = source:match("^(.*[/\\])") or ""

if root:match("/lib/$") then
  root = root:gsub("/lib/$", "/")
elseif root:match("/protocols/$") then
  root = root:gsub("/protocols/$", "/")
end

local bootstrap = dofile(root .. "lib/bootstrap.lua")
bootstrap.setup_from_file(source)

local counters = require("lib.counters")

local M = {}

local export_dir = nil
local menu_registered = false

local function normalize_path(path)
  return tostring(path or ""):gsub("\\", "/")
end

local function trim(value)
  value = tostring(value or "")
  value = value:gsub("^%s+", "")
  value = value:gsub("%s+$", "")
  value = value:gsub('^"(.*)"$', "%1")
  value = value:gsub("^'(.*)'$", "%1")

  return value
end

local function trim_trailing_slash(path)
  path = normalize_path(path)

  while #path > 1 and path:sub(-1) == "/" do
    path = path:sub(1, -2)
  end

  return path
end

local function join_path(dir, filename)
  return trim_trailing_slash(dir) .. "/" .. filename
end

local function sanitize_filename(filename)
  filename = tostring(filename or "ics_visibility_export.csv")

  filename = filename:gsub("[\r\n]", "_")
  filename = filename:gsub("[/\\]", "_")

  if filename == "" then
    filename = "ics_visibility_export.csv"
  end

  return filename
end

local function config_file_path()
  if Dir ~= nil and Dir.personal_config_path ~= nil then
    return normalize_path(
      Dir.personal_config_path("ics_visibility_export_dir.txt")
    )
  end

  return nil
end

local function default_export_dir()
  if Dir ~= nil and Dir.personal_config_path ~= nil then
    return normalize_path(
      Dir.personal_config_path("ics_visibility_exports")
    )
  end

  local home = os.getenv("USERPROFILE") or os.getenv("HOME")

  if home ~= nil and home ~= "" then
    return join_path(home, "ics_visibility_exports")
  end

  return "."
end

local function dir_exists(path)
  path = trim_trailing_slash(path)

  if Dir ~= nil and Dir.exists ~= nil then
    return Dir.exists(path) == true
  end

  return false
end

local function ensure_dir(path)
  path = trim_trailing_slash(trim(path))

  if path == "" then
    return false, "empty export directory"
  end

  if dir_exists(path) then
    return true, nil
  end

  if Dir ~= nil and Dir.make ~= nil then
    local ok = Dir.make(path)

    if ok == true or dir_exists(path) then
      return true, nil
    end
  end

  return false, "could not create export directory: " .. path
end

local function read_configured_dir()
  local path = config_file_path()

  if path == nil then
    return nil
  end

  local file = io.open(path, "r")

  if file == nil then
    return nil
  end

  local value = file:read("*l")
  file:close()

  value = trim(value)

  if value == "" then
    return nil
  end

  return normalize_path(value)
end

local function write_configured_dir(path)
  local cfg = config_file_path()

  if cfg == nil then
    return true, nil
  end

  local file, err = io.open(cfg, "w")

  if file == nil then
    return false, err
  end

  file:write(trim_trailing_slash(path))
  file:write("\n")
  file:close()

  return true, nil
end

function M.get_export_dir()
  if export_dir ~= nil and export_dir ~= "" then
    return export_dir
  end

  local configured = read_configured_dir()

  if configured ~= nil then
    local ok = ensure_dir(configured)

    if ok then
      export_dir = trim_trailing_slash(configured)
      return export_dir
    end
  end

  local fallback = default_export_dir()
  ensure_dir(fallback)

  export_dir = trim_trailing_slash(fallback)

  return export_dir
end

function M.set_export_dir(path)
  path = trim_trailing_slash(trim(path))

  local ok, err = ensure_dir(path)

  if not ok then
    return false, err
  end

  local saved, save_err = write_configured_dir(path)

  if not saved then
    return false, save_err
  end

  export_dir = path

  return true, nil
end

function M.temp_path(filename)
  return join_path(
    M.get_export_dir(),
    sanitize_filename(filename)
  )
end

function M.escape(value)
  if value == nil then
    return ""
  end

  value = tostring(value)

  local needs_quotes = (
    value:find(",", 1, true) ~= nil or
    value:find('"', 1, true) ~= nil or
    value:find("\n", 1, true) ~= nil or
    value:find("\r", 1, true) ~= nil
  )

  value = value:gsub('"', '""')

  if needs_quotes then
    return '"' .. value .. '"'
  end

  return value
end

function M.line(values)
  local escaped = {}

  for index, value in ipairs(values or {}) do
    escaped[index] = M.escape(value)
  end

  return table.concat(escaped, ",")
end

function M.write_lines(path, lines)
  local file, err = io.open(path, "w")

  if not file then
    return false, err
  end

  for _, line in ipairs(lines or {}) do
    file:write(line)
    file:write("\n")
  end

  file:close()

  return true, nil
end

function M.write_rows_csv(path, headers, rows)
  local lines = {}

  headers = headers or {}
  rows = rows or {}

  lines[#lines + 1] = M.line(headers)

  for _, row in ipairs(rows) do
    local values = {}

    for _, header in ipairs(headers) do
      values[#values + 1] = row[header]
    end

    lines[#lines + 1] = M.line(values)
  end

  return M.write_lines(path, lines)
end

function M.write_array_rows_csv(path, headers, rows)
  local lines = {}

  headers = headers or {}
  rows = rows or {}

  lines[#lines + 1] = M.line(headers)

  for _, row in ipairs(rows) do
    lines[#lines + 1] = M.line(row)
  end

  return M.write_lines(path, lines)
end

function M.write_count_csv(path, key_header, count_header, data, limit)
  key_header = key_header or "key"
  count_header = count_header or "count"

  local rows = {}

  for _, item in ipairs(counters.top(data, limit)) do
    rows[#rows + 1] = {
      [key_header] = item.key,
      [count_header] = item.count,
    }
  end

  return M.write_rows_csv(
    path,
    {key_header, count_header},
    rows
  )
end

function M.write_key_value_csv(path, key_header, value_header, data)
  key_header = key_header or "key"
  value_header = value_header or "value"

  local rows = {}

  if data ~= nil then
    for key, value in pairs(data) do
      rows[#rows + 1] = {
        [key_header] = key,
        [value_header] = value,
      }
    end
  end

  table.sort(rows, function(left, right)
    return tostring(left[key_header]) < tostring(right[key_header])
  end)

  return M.write_rows_csv(
    path,
    {key_header, value_header},
    rows
  )
end

function M.write_sectioned_count_csv(path, sections)
  local lines = {}

  for _, section in ipairs(sections or {}) do
    if #lines > 0 then
      lines[#lines + 1] = ""
    end

    lines[#lines + 1] = M.line({
      section.title or "section",
      "",
    })

    lines[#lines + 1] = M.line({
      section.key_header or "key",
      section.count_header or "count",
    })

    for _, item in ipairs(counters.top(section.data, section.limit)) do
      lines[#lines + 1] = M.line({
        item.key,
        item.count,
      })
    end
  end

  return M.write_lines(path, lines)
end

function M.prompt_export_dir(callback)
  if type(new_dialog) ~= "function" then
    return false, "new_dialog is not available"
  end

  local function on_submit(path)
    local ok, err = M.set_export_dir(path)
    local win = TextWindow.new("ICS Visibility CSV Export Directory")

    if ok then
      win:set(
        "CSV export directory updated:\n\n" ..
        M.get_export_dir() ..
        "\n\nFuture CSV exports will write here."
      )

      if callback ~= nil then
        callback(M.get_export_dir())
      end
    else
      win:set(
        "Failed to set CSV export directory:\n\n" ..
        tostring(err) ..
        "\n\nCurrent directory:\n\n" ..
        M.get_export_dir()
      )
    end
  end

  new_dialog(
    "ICS Visibility CSV Export Directory",
    on_submit,
    "Export directory"
  )

  return true, nil
end

function M.show_export_dir_window()
  local win = TextWindow.new("ICS Visibility CSV Export Directory")

  local function text()
    return table.concat({
      "Current CSV export directory:",
      "",
      M.get_export_dir(),
      "",
      "Click Change Directory to set a different folder.",
      "",
      "Example:",
      "C:/Users/somer/Documents/ics_visibility_exports",
    }, "\n")
  end

  win:set(text())

  win:add_button("Change Directory", function()
    M.prompt_export_dir(function()
      win:set(text())
    end)
  end)

  win:add_button("Refresh", function()
    win:set(text())
  end)
end

function M.register_menu()
  if menu_registered then
    return
  end

  if type(gui_enabled) == "function" and not gui_enabled() then
    return
  end

  if type(register_menu) ~= "function" then
    return
  end

  menu_registered = true

  register_menu(
    "ICS Visibility/Settings/CSV Export Directory",
    function()
      M.show_export_dir_window()
    end,
    MENU_TOOLS_UNSORTED
  )
end

return M