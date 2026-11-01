-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (protocols/modbus.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- protocols/modbus.lua
--
-- Passive Modbus/TCP visibility summary.
--
-- Menu:
--   Tools -> ICS Visibility -> Modbus -> Summary

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

local write_functions = {
  [5] = true,
  [6] = true,
  [15] = true,
  [16] = true,
  [22] = true,
  [23] = true,
}

local function new_stats()
  return {
    frames = 0,
    reads = 0,
    writes = 0,
    exceptions = 0,
    conversations = {},
    unit_ids = {},
    function_codes = {},
    register_ranges = {},
    exception_codes = {},
  }
end

local stats = new_stats()

local function init_fields()
  f.ip_src = fields_lib.safe_field("ip.src")
  f.ip_dst = fields_lib.safe_field("ip.dst")

  f.unit_id = fields_lib.safe_field("modbus.unit_id")
  f.func_code = fields_lib.safe_field("modbus.func_code")
  f.reference_num = fields_lib.safe_field("modbus.reference_num")
  f.word_count = fields_lib.safe_field("modbus.word_cnt")
  f.bit_count = fields_lib.safe_field("modbus.bit_cnt")
  f.exception_code = fields_lib.safe_field("modbus.exception_code")
end

local function function_name(code)
  local names = {
    [1] = "Read Coils",
    [2] = "Read Discrete Inputs",
    [3] = "Read Holding Registers",
    [4] = "Read Input Registers",
    [5] = "Write Single Coil",
    [6] = "Write Single Register",
    [15] = "Write Multiple Coils",
    [16] = "Write Multiple Registers",
    [22] = "Mask Write Register",
    [23] = "Read/Write Multiple Registers",
  }

  if code == nil then
    return "unknown"
  end

  if code >= 128 then
    return string.format(
      "0x%02X Exception response to %s",
      code,
      function_name(code - 128)
    )
  end

  return string.format(
    "0x%02X %s",
    code,
    names[code] or "Unknown"
  )
end

local function classify_packet(func_code)
  if func_code == nil then
    return
  end

  if func_code >= 128 then
    stats.exceptions = stats.exceptions + 1
    return
  end

  if write_functions[func_code] then
    stats.writes = stats.writes + 1
  else
    stats.reads = stats.reads + 1
  end
end

local function add_register_range(unit_id, func_code)
  local ref = fields_lib.first_number(f.reference_num)
  local words = fields_lib.first_number(f.word_count)
  local bits = fields_lib.first_number(f.bit_count)

  if ref == nil then
    return
  end

  local count = words or bits or 1
  local last_ref = ref + count - 1
  local unit = unit_id or "unknown"
  local func = function_name(func_code)

  local key = string.format(
    "unit %s  %s  ref %d-%d",
    unit,
    func,
    ref,
    last_ref
  )

  counters.bump(stats.register_ranges, key)
end

local function on_packet()
  local src = fields_lib.first(f.ip_src)
  local dst = fields_lib.first(f.ip_dst)
  local unit_id = fields_lib.first(f.unit_id)
  local func_code = fields_lib.first_number(f.func_code)
  local exception_code = fields_lib.first(f.exception_code)

  stats.frames = stats.frames + 1

  if src ~= "" and dst ~= "" then
    counters.bump(stats.conversations, src .. " -> " .. dst)
  end

  counters.bump(stats.unit_ids, unit_id)
  counters.bump(stats.function_codes, function_name(func_code))
  counters.bump(stats.exception_codes, exception_code)

  classify_packet(func_code)
  add_register_range(unit_id, func_code)
end

local function build_summary()
  local lines = {}

  lines[#lines + 1] = "ICS Visibility - Modbus/TCP Summary"
  lines[#lines + 1] = string.rep("=", 72)
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("Frames analyzed: %d", stats.frames)
  lines[#lines + 1] = string.format("Read-ish messages: %d", stats.reads)
  lines[#lines + 1] = string.format("Write messages:    %d", stats.writes)
  lines[#lines + 1] = string.format("Exceptions:        %d", stats.exceptions)

  windows.add_count_section(lines, "Conversations", stats.conversations, 20)
  windows.add_count_section(lines, "Unit IDs", stats.unit_ids, 20)
  windows.add_count_section(lines, "Function Codes", stats.function_codes, 20)
  windows.add_count_section(lines, "Register / Coil Ranges", stats.register_ranges, 30)
  windows.add_count_section(lines, "Exception Codes", stats.exception_codes, 20)

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Notes:"
  lines[#lines + 1] = "- Port 502 usually decodes as Modbus/TCP automatically."
  lines[#lines + 1] = "- For test port 1502, use Analyze -> Decode As -> Modbus/TCP."
  lines[#lines + 1] = "- This plugin is passive and does not send packets."

  return table.concat(lines, "\n")
end

local function export_csv()
  local base = "ics_visibility_modbus_"
  local outputs = {
    {
      path = csv.temp_path(base .. "conversations.csv"),
      key = "conversation",
      count = "count",
      data = stats.conversations,
    },
    {
      path = csv.temp_path(base .. "function_codes.csv"),
      key = "function_code",
      count = "count",
      data = stats.function_codes,
    },
    {
      path = csv.temp_path(base .. "register_ranges.csv"),
      key = "register_range",
      count = "count",
      data = stats.register_ranges,
    },
    {
      path = csv.temp_path(base .. "unit_ids.csv"),
      key = "unit_id",
      count = "count",
      data = stats.unit_ids,
    },
    {
      path = csv.temp_path(base .. "exception_codes.csv"),
      key = "exception_code",
      count = "count",
      data = stats.exception_codes,
    },
  }

  local lines = {
    "Modbus CSV export",
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

  windows.show_text("ICS Visibility Modbus CSV Export", table.concat(lines, "\n"))
end

local function show_summary()
  local win = windows.show_text("ICS Visibility Modbus", build_summary())

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

local function register_decode_ports()
  local ok_dissector, dissector = pcall(Dissector.get, "mbtcp")
  local ok_table, tcp_table = pcall(DissectorTable.get, "tcp.port")

  if ok_dissector and dissector ~= nil and ok_table and tcp_table ~= nil then
    pcall(function()
      tcp_table:add(1502, dissector)
    end)
  end
end

function M.register()
  if registered then
    return
  end

  registered = true

  init_fields()
  register_decode_ports()

  tap = Listener.new(nil, "modbus")

  function tap.packet()
    on_packet()
  end

  function tap.reset()
    stats = new_stats()
  end

  function tap.draw()
  end

  register_menu(
    "ICS Visibility/Modbus/Summary",
    show_summary,
    MENU_TOOLS_UNSORTED
  )
end

return M
