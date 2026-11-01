-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (protocols/bacnet.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- protocols/bacnet.lua
--
-- Passive BACnet/IP visibility summary.
--
-- Menu:
--   Tools -> ICS Visibility -> BACnet -> Summary

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

local confirmed_services = {
  [0] = "AcknowledgeAlarm",
  [1] = "ConfirmedCOVNotification",
  [2] = "ConfirmedEventNotification",
  [3] = "GetAlarmSummary",
  [4] = "GetEnrollmentSummary",
  [5] = "SubscribeCOV",
  [12] = "ReadProperty",
  [14] = "ReadPropertyMultiple",
  [15] = "WriteProperty",
  [16] = "WritePropertyMultiple",
  [17] = "DeviceCommunicationControl",
  [20] = "ReinitializeDevice",
  [21] = "VT-Open",
  [22] = "VT-Close",
  [23] = "VT-Data",
  [24] = "Authenticate",
  [25] = "RequestKey",
  [26] = "ReadRange",
  [27] = "LifeSafetyOperation",
  [28] = "SubscribeCOVProperty",
  [29] = "GetEventInformation",
}

local unconfirmed_services = {
  [0] = "I-Am",
  [1] = "I-Have",
  [2] = "UnconfirmedCOVNotification",
  [3] = "UnconfirmedEventNotification",
  [4] = "UnconfirmedPrivateTransfer",
  [5] = "UnconfirmedTextMessage",
  [6] = "TimeSynchronization",
  [7] = "Who-Has",
  [8] = "Who-Is",
  [9] = "UTC-TimeSynchronization",
  [10] = "WriteGroup",
  [11] = "UnconfirmedCOVNotificationMultiple",
}

local properties = {
  [28] = "Description",
  [75] = "ObjectIdentifier",
  [77] = "ObjectName",
  [79] = "ObjectType",
  [85] = "PresentValue",
  [111] = "StatusFlags",
}

local object_types = {
  [0] = "AnalogInput",
  [1] = "AnalogOutput",
  [2] = "AnalogValue",
  [3] = "BinaryInput",
  [4] = "BinaryOutput",
  [5] = "BinaryValue",
  [8] = "Device",
  [13] = "MultiStateInput",
  [14] = "MultiStateOutput",
  [19] = "MultiStateValue",
}

local function new_stats()
  return {
    frames = 0,
    pairs = {},
    bvlc_functions = {},
    confirmed = {},
    unconfirmed = {},
    objects = {},
    object_types = {},
    properties = {},
    devices = {},
    vendors = {},
    errors = {},
    writes = 0,
    reads = 0,
    discovery = 0,
  }
end

local stats = new_stats()

local function parse_number(value)
  if value == nil or value == "" then
    return nil
  end

  value = tostring(value)

  local hex = value:match("^%s*0x([0-9a-fA-F]+)")
  if hex ~= nil then
    return tonumber(hex, 16)
  end

  local leading = value:match("^%s*(%d+)")
  if leading ~= nil then
    return tonumber(leading)
  end

  local paren = value:match("%((%d+)%)")
  if paren ~= nil then
    return tonumber(paren)
  end

  return tonumber(value)
end

local function first_number(field)
  return parse_number(fields_lib.first(field))
end

local function service_name(tbl, code)
  if code == nil then
    return "unknown"
  end

  return string.format(
    "0x%02X %s",
    code,
    tbl[code] or "Unknown"
  )
end

local function property_name(code)
  if code == nil then
    return "unknown"
  end

  return string.format(
    "%d %s",
    code,
    properties[code] or "Unknown"
  )
end

local function object_type_name(code)
  if code == nil then
    return "unknown"
  end

  return string.format(
    "%d %s",
    code,
    object_types[code] or "Unknown"
  )
end

local function init_fields()
  f.ip_src = fields_lib.safe_field("ip.src")
  f.ip_dst = fields_lib.safe_field("ip.dst")

  f.bvlc_type = fields_lib.safe_field("bvlc.type")
  f.bvlc_function = fields_lib.safe_field("bvlc.function")
  f.bvlc_result = fields_lib.safe_field("bvlc.result")

  f.npdu_control = fields_lib.safe_field("bacnet.control")
  f.npdu_msg_type = fields_lib.safe_field("bacnet.mesgtyp")

  f.confirmed_service = fields_lib.safe_field("bacapp.confirmed_service")
  f.unconfirmed_service = fields_lib.safe_field("bacapp.unconfirmed_service")
  f.invoke_id = fields_lib.safe_field("bacapp.invoke_id")

  f.object_id = fields_lib.safe_field("bacapp.objectIdentifier")
  f.object_type = fields_lib.safe_field("bacapp.objectType")
  f.instance = fields_lib.safe_field("bacapp.instance_number")
  f.property_id = fields_lib.safe_field("bacapp.property_identifier")

  f.device_id = fields_lib.safe_field("bacapp.deviceIdentifier")
  f.vendor_id = fields_lib.safe_field("bacapp.vendor_identifier")

  f.error_class = fields_lib.safe_field("bacapp.error_class")
  f.error_code = fields_lib.safe_field("bacapp.error_code")
end

local function bump_all(tbl, field)
  for _, value in ipairs(fields_lib.values(field)) do
    counters.bump(tbl, value)
  end
end

local function bump_service_counts()
  local confirmed = first_number(f.confirmed_service)
  local unconfirmed = first_number(f.unconfirmed_service)

  if confirmed ~= nil then
    counters.bump(
      stats.confirmed,
      service_name(confirmed_services, confirmed)
    )

    if confirmed == 12 or confirmed == 14 or confirmed == 26 then
      stats.reads = stats.reads + 1
    elseif confirmed == 15 or confirmed == 16 then
      stats.writes = stats.writes + 1
    end
  end

  if unconfirmed ~= nil then
    counters.bump(
      stats.unconfirmed,
      service_name(unconfirmed_services, unconfirmed)
    )

    if unconfirmed == 0 or unconfirmed == 8 then
      stats.discovery = stats.discovery + 1
    end
  end
end

local function bump_properties()
  for _, value in ipairs(fields_lib.values(f.property_id)) do
    local code = parse_number(value)

    counters.bump(stats.properties, property_name(code))
  end
end

local function bump_object_types()
  for _, value in ipairs(fields_lib.values(f.object_type)) do
    local code = parse_number(value)

    counters.bump(stats.object_types, object_type_name(code))
  end
end

local function bump_errors()
  local error_class = fields_lib.first(f.error_class)
  local error_code = fields_lib.first(f.error_code)

  if error_class ~= "" or error_code ~= "" then
    counters.bump(
      stats.errors,
      "class " .. error_class .. " / code " .. error_code
    )
  end
end

local function on_packet()
  local src = fields_lib.first(f.ip_src)
  local dst = fields_lib.first(f.ip_dst)
  local bvlc_function = fields_lib.first(f.bvlc_function)

  stats.frames = stats.frames + 1

  if src ~= "" and dst ~= "" then
    counters.bump(stats.pairs, src .. " -> " .. dst)
  end

  counters.bump(stats.bvlc_functions, bvlc_function)

  bump_service_counts()
  bump_all(stats.objects, f.object_id)
  bump_object_types()
  bump_properties()
  bump_all(stats.devices, f.device_id)
  bump_all(stats.vendors, f.vendor_id)
  bump_errors()
end

local function build_summary()
  local lines = {}

  lines[#lines + 1] = "ICS Visibility - BACnet/IP Summary"
  lines[#lines + 1] = string.rep("=", 72)
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("Frames analyzed: %d", stats.frames)
  lines[#lines + 1] = string.format("Read-ish messages: %d", stats.reads)
  lines[#lines + 1] = string.format("Write messages:    %d", stats.writes)
  lines[#lines + 1] = string.format("Discovery messages:%d", stats.discovery)

  windows.add_count_section(lines, "IP Conversations", stats.pairs, 20)
  windows.add_count_section(lines, "BVLC Functions", stats.bvlc_functions, 20)
  windows.add_count_section(lines, "Confirmed Services", stats.confirmed, 20)
  windows.add_count_section(lines, "Unconfirmed Services", stats.unconfirmed, 20)
  windows.add_count_section(lines, "Object Identifiers", stats.objects, 30)
  windows.add_count_section(lines, "Object Types", stats.object_types, 20)
  windows.add_count_section(lines, "Properties", stats.properties, 20)
  windows.add_count_section(lines, "Device IDs", stats.devices, 20)
  windows.add_count_section(lines, "Vendor IDs", stats.vendors, 20)
  windows.add_count_section(lines, "Errors", stats.errors, 20)

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Notes:"
  lines[#lines + 1] = "- BACnet/IP normally uses UDP port 47808."
  lines[#lines + 1] = "- Use display filter: bvlc || bacnet || bacapp"
  lines[#lines + 1] = "- This plugin is passive and does not send packets."

  return table.concat(lines, "\n")
end

local function export_csv()
  local base = "ics_visibility_bacnet_"
  local outputs = {
    {
      path = csv.temp_path(base .. "conversations.csv"),
      key = "conversation",
      count = "count",
      data = stats.pairs,
    },
    {
      path = csv.temp_path(base .. "confirmed_services.csv"),
      key = "confirmed_service",
      count = "count",
      data = stats.confirmed,
    },
    {
      path = csv.temp_path(base .. "unconfirmed_services.csv"),
      key = "unconfirmed_service",
      count = "count",
      data = stats.unconfirmed,
    },
    {
      path = csv.temp_path(base .. "objects.csv"),
      key = "object",
      count = "count",
      data = stats.objects,
    },
    {
      path = csv.temp_path(base .. "properties.csv"),
      key = "property",
      count = "count",
      data = stats.properties,
    },
    {
      path = csv.temp_path(base .. "devices.csv"),
      key = "device",
      count = "count",
      data = stats.devices,
    },
  }

  local lines = {
    "BACnet CSV export",
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

  windows.show_text(
    "ICS Visibility BACnet CSV Export",
    table.concat(lines, "\n")
  )
end

local function show_summary()
  local win = windows.show_text("ICS Visibility BACnet", build_summary())

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

  tap = Listener.new(nil, "bvlc || bacnet || bacapp")

  function tap.packet()
    on_packet()
  end

  function tap.reset()
    stats = new_stats()
  end

  function tap.draw()
  end

  register_menu(
    "ICS Visibility/BACnet/Summary",
    show_summary,
    MENU_TOOLS_UNSORTED
  )
end

return M