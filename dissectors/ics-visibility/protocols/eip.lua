-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (protocols/eip.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- protocols/eip.lua
--
-- Passive EtherNet/IP / CIP visibility summary.
--
-- Menu:
--   Tools -> ICS Visibility -> EIP -> Summary

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
local csv = require("lib.csv")
local fields_lib = require("lib.fields")
local windows = require("lib.windows")

local M = {}

local tap = nil
local registered = false

local f = {}

local function new_stats()
  return {
    frames = 0,
    pairs = {},
    services = {},
    symbols = {},
    sessions = {},
    connections = {},
  }
end

local stats = new_stats()

local function init_fields()
  f.ip_src = fields_lib.safe_field("ip.src")
  f.ip_dst = fields_lib.safe_field("ip.dst")

  f.cip_service = fields_lib.safe_field("cip.service")
  f.cip_service_code = fields_lib.safe_field("cip.service_code")
  f.cip_sc = fields_lib.safe_field("cip.sc")

  f.cip_symbol = fields_lib.safe_field("cip.symbol")
  f.cip_ascii_symbol = fields_lib.safe_field("cip.ascii_symbol")

  f.enip_session = fields_lib.safe_field("enip.session")
  f.enip_connid = fields_lib.safe_field("enip.cpf.sai.connid")
end

local function get_service()
  local value = fields_lib.first(f.cip_service)

  if value ~= "" then
    return value
  end

  value = fields_lib.first(f.cip_service_code)

  if value ~= "" then
    return value
  end

  return fields_lib.first(f.cip_sc)
end

local function bump_symbols()
  local found = false

  for _, symbol in ipairs(fields_lib.values(f.cip_symbol)) do
    counters.bump(stats.symbols, symbol)
    found = true
  end

  for _, symbol in ipairs(fields_lib.values(f.cip_ascii_symbol)) do
    counters.bump(stats.symbols, symbol)
    found = true
  end

  return found
end

local function on_packet()
  local src = fields_lib.first(f.ip_src)
  local dst = fields_lib.first(f.ip_dst)
  local service = get_service()
  local session = fields_lib.first(f.enip_session)
  local connid = fields_lib.first(f.enip_connid)

  stats.frames = stats.frames + 1

  if src ~= "" and dst ~= "" then
    counters.bump(stats.pairs, src .. " -> " .. dst)
  end

  counters.bump(stats.services, service)
  counters.bump(stats.sessions, session)
  counters.bump(stats.connections, connid)

  bump_symbols()
end

local function build_summary()
  local lines = {}

  lines[#lines + 1] = "ICS Visibility - EtherNet/IP / CIP Summary"
  lines[#lines + 1] = string.rep("=", 72)
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("Frames analyzed: %d", stats.frames)

  windows.add_count_section(lines, "IP Conversations", stats.pairs, 20)
  windows.add_count_section(lines, "CIP Services", stats.services, 20)
  windows.add_count_section(lines, "Visible CIP Symbols", stats.symbols, 30)
  windows.add_count_section(lines, "ENIP Sessions", stats.sessions, 20)
  windows.add_count_section(lines, "Connection IDs", stats.connections, 20)

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Notes:"
  lines[#lines + 1] = "- Symbol/tag names only appear when present in packets."
  lines[#lines + 1] = "- Implicit I/O usually exposes connection data, not tag names."
  lines[#lines + 1] = "- This plugin is passive and does not send packets."

  return table.concat(lines, "\n")
end

local function export_csv()
  local base = "ics_visibility_eip_"
  local outputs = {
    {
      path = csv.temp_path(base .. "conversations.csv"),
      key = "conversation",
      count = "count",
      data = stats.pairs,
    },
    {
      path = csv.temp_path(base .. "services.csv"),
      key = "service",
      count = "count",
      data = stats.services,
    },
    {
      path = csv.temp_path(base .. "symbols.csv"),
      key = "symbol",
      count = "count",
      data = stats.symbols,
    },
    {
      path = csv.temp_path(base .. "sessions.csv"),
      key = "session",
      count = "count",
      data = stats.sessions,
    },
    {
      path = csv.temp_path(base .. "connections.csv"),
      key = "connection_id",
      count = "count",
      data = stats.connections,
    },
  }

  local lines = {
    "EIP CSV export",
    string.rep("=", 72),
    "",
  }

  for _, item in ipairs(outputs) do
    local ok, err = csv.write_count_csv(
      item.path,
      item.key,
      item.count,
      item.data
    )

    if ok then
      lines[#lines + 1] = "wrote: " .. item.path
    else
      lines[#lines + 1] = "failed: " .. item.path .. " - " .. tostring(err)
    end
  end

  windows.show_text("ICS Visibility EIP CSV Export", table.concat(lines, "\n"))
end

local function show_summary()
  local win = windows.show_text("ICS Visibility EIP", build_summary())

  win:add_button("Refresh", function()
    win:set(build_summary())
  end)

  win:add_button("Export CSV", function()
    export_csv()
  end)

  win:add_button("Clear Counters", function()
    stats = new_stats()
    win:set(build_summary())
  end)
end

function M.register()
  if registered then
    return
  end

  registered = true

  init_fields()

  tap = Listener.new(nil, "enip || cip")

  function tap.packet()
    on_packet()
  end

  function tap.reset()
    stats = new_stats()
  end

  function tap.draw()
  end

  register_menu(
    "ICS Visibility/EIP/Summary",
    show_summary,
    MENU_TOOLS_UNSORTED
  )
end

return M