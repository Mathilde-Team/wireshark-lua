-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (ics_visibility.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- ics_visibility.lua
--
-- Wireshark loader for the ICS Visibility plugin.
--
-- Install by copying the whole ics_visibility/ directory into Wireshark's
-- personal plugin folder.

local function add_ics_visibility_paths()
  local source = debug.getinfo(1, "S").source

  if source:sub(1, 1) == "@" then
    source = source:sub(2)
  end

  local dir = source:match("^(.*[/\\])") or ""

  -- Normalize to forward slashes. Lua/Wireshark on Windows can still load
  -- files using forward slashes, and this avoids ugly slash escaping bugs.
  dir = dir:gsub("\\", "/")

  local root = dir

  if root:match("/lib/$") then
    root = root:gsub("/lib/$", "/")
  elseif root:match("/protocols/$") then
    root = root:gsub("/protocols/$", "/")
  end

  package.path = table.concat({
    root .. "?.lua",
    root .. "?/init.lua",
    root .. "lib/?.lua",
    root .. "protocols/?.lua",
    package.path,
  }, ";")
end

add_ics_visibility_paths()

local ok, err = pcall(require, "init")

if not ok then
  report_failure("ICS Visibility failed to load: " .. tostring(err))
end
