-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (protocols/profinet.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only — voir README.md.
-- protocols/profinet.lua
--
-- Passive PROFINET DCP visibility summary.
--
-- Menu:
--   Tools -> ICS Visibility -> PROFINET DCP -> Summary

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

local service_names = {
  [3] = "Get",
  [4] = "Set",
  [5] = "Identify",
  [6] = "Hello",
}

local service_type_names = {
  [0] = "Request",
  [1] = "Response",
}

local option_names = {
  [1] = "IP",
  [2] = "Device",
  [3] = "DHCP",
  [4] = "Reserved",
  [5] = "Control",
  [255] = "All",
}

local function new_stats()
  return {
    frames = 0,
    identify_requests = 0,
    identify_responses = 0,
    set_requests = 0,
    get_requests = 0,
    hello_messages = 0,
    warnings = 0,
    pairs = {},
    services = {},
    service_types = {},
    xids = {},
    station_names = {},
    device_types = {},
    device_ids = {},
    vendor_ids = {},
    options = {},
    suboptions = {},
    ip_configs = {},
    mac_addresses = {},
    block_qualifiers = {},
    warning_list = {},
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

local function named_value(names, code)
  if code == nil then
    return "unknown"
  end

  return string.format(
    "0x%02X %s",
    code,
    names[code] or "Unknown"
  )
end

local function add_warning(text)
  counters.bump(stats.warning_list, text)
  stats.warnings = stats.warnings + 1
end

local function init_fields()
  f.eth_src = fields_lib.safe_field("eth.src")
  f.eth_dst = fields_lib.safe_field("eth.dst")

  f.service_id = fields_lib.safe_field("pn_dcp.service_id")
  f.service_type = fields_lib.safe_field("pn_dcp.service_type")
  f.xid = fields_lib.safe_field("pn_dcp.xid")
  f.response_delay = fields_lib.safe_field("pn_dcp.response_delay")
  f.data_length = fields_lib.safe_field("pn_dcp.data_length")

  f.option = fields_lib.safe_field("pn_dcp.option")
  f.suboption_all = fields_lib.safe_field("pn_dcp.suboption_all")
  f.suboption_device = fields_lib.safe_field("pn_dcp.suboption_device")
  f.suboption_ip = fields_lib.safe_field("pn_dcp.suboption_ip")
  f.suboption_control = fields_lib.safe_field("pn_dcp.suboption_control")

  f.name_of_station = fields_lib.safe_field(
    "pn_dcp.suboption_device_nameofstation"
  )

  f.device_vendor_value = fields_lib.safe_field(
    "pn_dcp.suboption_device_devicevendorvalue"
  )

  f.device_id = fields_lib.safe_field("pn_dcp.suboption_device_id")
  f.vendor_id = fields_lib.safe_field("pn_dcp.suboption_vendor_id")

  f.ip_address = fields_lib.safe_field("pn_dcp.suboption_ip_ip")
  f.subnet_mask = fields_lib.safe_field("pn_dcp.suboption_ip_subnetmask")
  f.gateway = fields_lib.safe_field("pn_dcp.suboption_ip_standard_gateway")
  f.ip_mac = fields_lib.safe_field("pn_dcp.suboption_ip_mac_address")

  f.block_qualifier = fields_lib.safe_field("pn_dcp.block_qualifier")
  f.reset_qualifier = fields_lib.safe_field("pn_dcp.block_qualifier_reset")
  f.ip_conflict = fields_lib.safe_field("pn_dcp.ip_conflict")
end

local function bump_values(tbl, field)
  for _, value in ipairs(fields_lib.values(field)) do
    counters.bump(tbl, value)
  end
end

local function bump_number_values(tbl, field, names)
  for _, value in ipairs(fields_lib.values(field)) do
    local code = parse_number(value)

    counters.bump(tbl, named_value(names, code))
  end
end

local function count_service_type()
  local service_id = first_number(f.service_id)
  local service_type = first_number(f.service_type)

  counters.bump(stats.services, named_value(service_names, service_id))
  counters.bump(
    stats.service_types,
    named_value(service_type_names, service_type)
  )

  if service_id == 5 and service_type == 0 then
    stats.identify_requests = stats.identify_requests + 1
  elseif service_id == 5 and service_type == 1 then
    stats.identify_responses = stats.identify_responses + 1
  elseif service_id == 4 and service_type == 0 then
    stats.set_requests = stats.set_requests + 1
    add_warning("DCP Set request observed")
  elseif service_id == 3 and service_type == 0 then
    stats.get_requests = stats.get_requests + 1
  elseif service_id == 6 then
    stats.hello_messages = stats.hello_messages + 1
  end
end

local function count_ip_configs()
  local ips = fields_lib.values(f.ip_address)
  local masks = fields_lib.values(f.subnet_mask)
  local gateways = fields_lib.values(f.gateway)

  local count = math.max(#ips, #masks, #gateways)

  for index = 1, count do
    local ip = ips[index] or ""
    local mask = masks[index] or ""
    local gateway = gateways[index] or ""

    counters.bump(
      stats.ip_configs,
      ip .. " / " .. mask .. " / " .. gateway
    )
  end
end

local function count_warnings()
  if #fields_lib.values(f.reset_qualifier) > 0 then
    add_warning("Reset-to-factory qualifier observed")
  end

  if #fields_lib.values(f.ip_conflict) > 0 then
    add_warning("IP conflict flag observed")
  end
end

local function on_packet()
  local src = fields_lib.first(f.eth_src)
  local dst = fields_lib.first(f.eth_dst)

  stats.frames = stats.frames + 1

  if src ~= "" and dst ~= "" then
    counters.bump(stats.pairs, src .. " -> " .. dst)
  end

  count_service_type()

  bump_values(stats.xids, f.xid)
  bump_values(stats.station_names, f.name_of_station)
  bump_values(stats.device_types, f.device_vendor_value)
  bump_values(stats.device_ids, f.device_id)
  bump_values(stats.vendor_ids, f.vendor_id)
  bump_values(stats.mac_addresses, f.ip_mac)
  bump_values(stats.block_qualifiers, f.block_qualifier)

  bump_number_values(stats.options, f.option, option_names)
  bump_values(stats.suboptions, f.suboption_all)
  bump_values(stats.suboptions, f.suboption_device)
  bump_values(stats.suboptions, f.suboption_ip)
  bump_values(stats.suboptions, f.suboption_control)

  count_ip_configs()
  count_warnings()
end

local function build_summary()
  local lines = {}

  lines[#lines + 1] = "ICS Visibility - PROFINET DCP Summary"
  lines[#lines + 1] = string.rep("=", 72)
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("Frames analyzed:      %d", stats.frames)
  lines[#lines + 1] = string.format(
    "Identify requests:    %d",
    stats.identify_requests
  )
  lines[#lines + 1] = string.format(
    "Identify responses:   %d",
    stats.identify_responses
  )
  lines[#lines + 1] = string.format("Set requests:         %d", stats.set_requests)
  lines[#lines + 1] = string.format("Get requests:         %d", stats.get_requests)
  lines[#lines + 1] = string.format("Hello messages:       %d", stats.hello_messages)
  lines[#lines + 1] = string.format("Warnings:             %d", stats.warnings)

  windows.add_count_section(lines, "Ethernet Conversations", stats.pairs, 20)
  windows.add_count_section(lines, "Services", stats.services, 20)
  windows.add_count_section(lines, "Service Types", stats.service_types, 20)
  windows.add_count_section(lines, "Station Names", stats.station_names, 30)
  windows.add_count_section(lines, "Device Types / Vendor Values", stats.device_types, 30)
  windows.add_count_section(lines, "Device IDs", stats.device_ids, 20)
  windows.add_count_section(lines, "Vendor IDs", stats.vendor_ids, 20)
  windows.add_count_section(lines, "Options", stats.options, 20)
  windows.add_count_section(lines, "Suboptions", stats.suboptions, 30)
  windows.add_count_section(lines, "IP Configurations", stats.ip_configs, 30)
  windows.add_count_section(lines, "MAC Addresses", stats.mac_addresses, 30)
  windows.add_count_section(lines, "Block Qualifiers", stats.block_qualifiers, 20)
  windows.add_count_section(lines, "Warnings", stats.warning_list, 20)
  windows.add_count_section(lines, "XIDs", stats.xids, 20)

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Notes:"
  lines[#lines + 1] = "- PROFINET DCP is Layer 2, not TCP/UDP."
  lines[#lines + 1] = "- Display filter: pn_dcp"
  lines[#lines + 1] = "- This plugin is passive and does not send packets."

  return table.concat(lines, "\n")
end

local function export_csv()
  local base = "ics_visibility_profinet_dcp_"
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
      path = csv.temp_path(base .. "station_names.csv"),
      key = "station_name",
      count = "count",
      data = stats.station_names,
    },
    {
      path = csv.temp_path(base .. "device_types.csv"),
      key = "device_type",
      count = "count",
      data = stats.device_types,
    },
    {
      path = csv.temp_path(base .. "ip_configurations.csv"),
      key = "ip_configuration",
      count = "count",
      data = stats.ip_configs,
    },
    {
      path = csv.temp_path(base .. "warnings.csv"),
      key = "warning",
      count = "count",
      data = stats.warning_list,
    },
  }

  local lines = {
    "PROFINET DCP CSV export",
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
    "ICS Visibility PROFINET DCP CSV Export",
    table.concat(lines, "\n")
  )
end

local function show_summary()
  local win = windows.show_text("ICS Visibility PROFINET DCP", build_summary())

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

  tap = Listener.new(nil, "pn_dcp")

  function tap.packet()
    on_packet()
  end

  function tap.reset()
    stats = new_stats()
  end

  function tap.draw()
  end

  register_menu(
    "ICS Visibility/PROFINET DCP/Summary",
    show_summary,
    MENU_TOOLS_UNSORTED
  )
end

return M