-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (init.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- init.lua
--
-- Package initializer for ICS Visibility.

local function add_ics_visibility_paths()
  local source = debug.getinfo(1, "S").source

  if source:sub(1, 1) == "@" then
    source = source:sub(2)
  end

  local dir = source:match("^(.*[/\\])") or ""
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

local M = {}

local csv = require("lib.csv")

local modbus = require("protocols.modbus")
local eip = require("protocols.eip")
local bacnet = require("protocols.bacnet")
local profinet = require("protocols.profinet")
local opcua = require("protocols.opcua")
local s7 = require("protocols.s7")
local dnp3 = require("protocols.dnp3")
local iec104 = require("protocols.iec104")

function M.register()
  csv.register_menu()
  modbus.register()
  eip.register()
  bacnet.register()
  profinet.register()
  opcua.register()
  s7.register()
  dnp3.register()
  iec104.register()
end

M.register()

return M
