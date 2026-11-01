-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (lib/bootstrap.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- lib/bootstrap.lua
--
-- Shared path setup for ICS Visibility.
--
-- This file is loaded with dofile() from any Lua file in the project.
-- It makes require("lib.x") and require("protocols.x") work from:
--
--   ics_visibility/
--   ics_visibility/lib/
--   ics_visibility/protocols/

local M = {}

local function normalize_path(path)
  return path:gsub("\\", "/")
end

local function dirname(path)
  return path:match("^(.*[/\\])") or ""
end

local function source_path(level)
  local info = debug.getinfo(level or 3, "S")
  local source = info and info.source or ""

  if source:sub(1, 1) == "@" then
    source = source:sub(2)
  end

  return normalize_path(source)
end

local function project_root_from_file(path)
  local dir = dirname(path)

  if dir:match("/lib/$") then
    return dir:gsub("/lib/$", "/")
  end

  if dir:match("/protocols/$") then
    return dir:gsub("/protocols/$", "/")
  end

  return dir
end

local function path_contains(needle)
  for entry in package.path:gmatch("[^;]+") do
    if entry == needle then
      return true
    end
  end

  return false
end

local function prepend_package_path(path)
  if not path_contains(path) then
    package.path = path .. ";" .. package.path
  end
end

function M.setup_from_file(path)
  local root = project_root_from_file(normalize_path(path))

  prepend_package_path(root .. "?.lua")
  prepend_package_path(root .. "?/init.lua")
  prepend_package_path(root .. "lib/?.lua")
  prepend_package_path(root .. "protocols/?.lua")

  return root
end

function M.setup()
  return M.setup_from_file(source_path(3))
end

return M