-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (protocols/dnp3.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- protocols/dnp3.lua
--
-- Passive DNP3 visibility summary.
--
-- Menu:
--   Tools -> ICS Visibility -> DNP3 -> Summary

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

local app_function_names = {
  [0x00] = "Confirm",
  [0x01] = "Read",
  [0x02] = "Write",
  [0x03] = "Select",
  [0x04] = "Operate",
  [0x05] = "Direct Operate",
  [0x06] = "Direct Operate No Ack",
  [0x07] = "Immediate Freeze",
  [0x08] = "Immediate Freeze No Ack",
  [0x09] = "Freeze Clear",
  [0x0A] = "Freeze Clear No Ack",
  [0x0D] = "Cold Restart",
  [0x0E] = "Warm Restart",
  [0x14] = "Enable Unsolicited",
  [0x15] = "Disable Unsolicited",
  [0x17] = "Delay Measure",
  [0x18] = "Record Current Time",
  [0x81] = "Response",
  [0x82] = "Unsolicited Response",
}

local object_names = {
  [0x0101] = "Binary Input - Packed",
  [0x0102] = "Binary Input - Flags",
  [0x0C01] = "Control Relay Output Block",
  [0x1401] = "Counter - 32-bit with flag",
  [0x1E01] = "Analog Input - 32-bit with flag",
  [0x3201] = "Time and Date",
  [0x3C01] = "Class 0",
  [0x3C02] = "Class 1",
  [0x3C03] = "Class 2",
  [0x3C04] = "Class 3",
}

local function new_stats()
  return {
    frames = 0,
    tcp_test_frames = 0,
    decoded_dnp3_frames = 0,
    requests = 0,
    responses = 0,
    unsolicited = 0,
    confirms = 0,
    reads = 0,
    writes = 0,
    controls = 0,
    time_sync = 0,
    restarts = 0,
    errors = 0,
    warning_count = 0,
    pairs = {},
    dnp_pairs = {},
    sources = {},
    destinations = {},
    app_functions = {},
    objects = {},
    iins = {},
    point_indexes = {},
    binary_points = {},
    analog_points = {},
    counter_points = {},
    control_points = {},
    app_sequences = {},
    transport_sequences = {},
    quality_flags = {},
    crc_errors = {},
    warnings = {},
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

  local paren_hex = value:match("%(0x([0-9a-fA-F]+)%)")
  if paren_hex ~= nil then
    return tonumber(paren_hex, 16)
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

local function named_value(names, code, width)
  if code == nil then
    return "unknown"
  end

  width = width or 2

  return string.format(
    "0x%0" .. tostring(width) .. "X %s",
    code,
    names[code] or "Unknown"
  )
end

local function value_is_true(value)
  if value == nil then
    return false
  end

  value = tostring(value):lower()

  if value == "" or value == "0" or value == "false" then
    return false
  end

  if value:find("not set", 1, true) then
    return false
  end

  local number = parse_number(value)

  if number ~= nil then
    return number ~= 0
  end

  return true
end

local function field_has_true(field)
  for _, value in ipairs(fields_lib.values(field)) do
    if value_is_true(value) then
      return true
    end
  end

  return false
end

local function first_number(field)
  return parse_number(fields_lib.first(field))
end

local function add_warning(text)
  counters.bump(stats.warnings, text)
  stats.warning_count = stats.warning_count + 1
end

local function bump_all(tbl, field)
  for _, value in ipairs(fields_lib.values(field)) do
    counters.bump(tbl, value)
  end
end

local function bump_number_names(tbl, field, names, width)
  for _, value in ipairs(fields_lib.values(field)) do
    local code = parse_number(value)

    counters.bump(tbl, named_value(names, code, width))
  end
end

local function init_fields()
  f.ip_src = fields_lib.safe_field("ip.src")
  f.ip_dst = fields_lib.safe_field("ip.dst")
  f.tcp_srcport = fields_lib.safe_field("tcp.srcport")
  f.tcp_dstport = fields_lib.safe_field("tcp.dstport")

  f.dnp_src = fields_lib.safe_field("dnp3.src")
  f.dnp_dst = fields_lib.safe_field("dnp3.dst")

  f.tr_seq = fields_lib.safe_field("dnp3.tr.seq")

  f.al_func = fields_lib.safe_field("dnp3.al.func")
  f.al_seq = fields_lib.safe_field("dnp3.al.seq")
  f.al_uns = fields_lib.safe_field("dnp3.al.uns")
  f.al_obj = fields_lib.safe_field("dnp3.al.obj")
  f.al_iin = fields_lib.safe_field("dnp3.al.iin")

  f.point_index = fields_lib.safe_field("dnp3.al.point_index")
  f.index = fields_lib.safe_field("dnp3.al.index")

  f.bi_index = fields_lib.safe_field("dnp3.al.bi.index")
  f.bi_event_index = fields_lib.safe_field("dnp3.al.bi.event.index")
  f.ai_index = fields_lib.safe_field("dnp3.al.ai.index")
  f.ai_event_index = fields_lib.safe_field("dnp3.al.ai.event.index")
  f.counter_index = fields_lib.safe_field("dnp3.al.counter.index")
  f.counter_event_index = fields_lib.safe_field("dnp3.al.counter.event.index")
  f.bo_command_index = fields_lib.safe_field("dnp3.al.bo.cmnd.index")
  f.ao_command_index = fields_lib.safe_field("dnp3.al.ao.cmnd.index")

  f.iin_restart = fields_lib.safe_field("dnp3.al.iin.rst")
  f.iin_class1 = fields_lib.safe_field("dnp3.al.iin.cls1d")
  f.iin_class2 = fields_lib.safe_field("dnp3.al.iin.cls2d")
  f.iin_class3 = fields_lib.safe_field("dnp3.al.iin.cls3d")
  f.iin_need_time = fields_lib.safe_field("dnp3.al.iin.tsr")
  f.iin_device_trouble = fields_lib.safe_field("dnp3.al.iin.dt")
  f.iin_config_corrupt = fields_lib.safe_field("dnp3.al.iin.cc")
  f.iin_buffer_overflow = fields_lib.safe_field("dnp3.al.iin.ebo")
  f.iin_obj_unknown = fields_lib.safe_field("dnp3.al.iin.obju")
  f.iin_func_not_impl = fields_lib.safe_field("dnp3.al.iin.fcni")
  f.iin_param_invalid = fields_lib.safe_field("dnp3.al.iin.pioor")

  f.biq_online = fields_lib.safe_field("dnp3.al.biq.b0")
  f.biq_comm_fail = fields_lib.safe_field("dnp3.al.biq.b2")
  f.aiq_online = fields_lib.safe_field("dnp3.al.aiq.b0")
  f.aiq_comm_fail = fields_lib.safe_field("dnp3.al.aiq.b2")
  f.ctrq_online = fields_lib.safe_field("dnp3.al.ctrq.b0")
  f.ctrq_comm_fail = fields_lib.safe_field("dnp3.al.ctrq.b2")

  f.hdr_crc_bad = fields_lib.safe_field("dnp3.hdr.CRC.incorrect")
  f.data_crc_bad = fields_lib.safe_field("dnp3.data_chunk.CRC.incorrect")
  f.invalid_length = fields_lib.safe_field("dnp3.invalid_length")
  f.unknown_object = fields_lib.safe_field("dnp3.unknown_object")
end

local function is_dnp3_tcp_test_frame()
  local src_port = fields_lib.first(f.tcp_srcport)
  local dst_port = fields_lib.first(f.tcp_dstport)

  return (
    src_port == "20000" or
    dst_port == "20000" or
    src_port == "20001" or
    dst_port == "20001"
  )
end

local function has_dnp3_decode()
  if fields_lib.first(f.dnp_src) ~= "" then
    return true
  end

  if fields_lib.first(f.dnp_dst) ~= "" then
    return true
  end

  if fields_lib.first(f.al_func) ~= "" then
    return true
  end

  return false
end

local function count_conversation()
  local ip_src = fields_lib.first(f.ip_src)
  local ip_dst = fields_lib.first(f.ip_dst)
  local dnp_src = fields_lib.first(f.dnp_src)
  local dnp_dst = fields_lib.first(f.dnp_dst)

  if ip_src ~= "" and ip_dst ~= "" then
    counters.bump(stats.pairs, ip_src .. " -> " .. ip_dst)
  end

  if dnp_src ~= "" and dnp_dst ~= "" then
    counters.bump(stats.dnp_pairs, dnp_src .. " -> " .. dnp_dst)
  end

  counters.bump(stats.sources, dnp_src)
  counters.bump(stats.destinations, dnp_dst)
end

local function count_app_function()
  local func = first_number(f.al_func)

  counters.bump(
    stats.app_functions,
    named_value(app_function_names, func)
  )

  if func == nil then
    return
  end

  if func < 0x80 then
    stats.requests = stats.requests + 1
  end

  if func == 0x00 then
    stats.confirms = stats.confirms + 1
  elseif func == 0x01 then
    stats.reads = stats.reads + 1
  elseif func == 0x02 then
    stats.writes = stats.writes + 1
  elseif func == 0x03 or func == 0x04 or func == 0x05 or func == 0x06 then
    stats.controls = stats.controls + 1
    add_warning("Control operation observed")
  elseif func == 0x0D or func == 0x0E then
    stats.restarts = stats.restarts + 1
    add_warning("Restart function observed")
  elseif func == 0x18 then
    stats.time_sync = stats.time_sync + 1
  elseif func == 0x81 then
    stats.responses = stats.responses + 1
  elseif func == 0x82 then
    stats.responses = stats.responses + 1
    stats.unsolicited = stats.unsolicited + 1
    add_warning("Unsolicited response observed")
  end
end

local function count_iin_warnings()
  bump_all(stats.iins, f.al_iin)

  local checks = {
    {field = f.iin_restart, text = "IIN Device Restart"},
    {field = f.iin_class1, text = "IIN Class 1 Data Available"},
    {field = f.iin_class2, text = "IIN Class 2 Data Available"},
    {field = f.iin_class3, text = "IIN Class 3 Data Available"},
    {field = f.iin_need_time, text = "IIN Time Sync Required"},
    {field = f.iin_device_trouble, text = "IIN Device Trouble"},
    {field = f.iin_config_corrupt, text = "IIN Configuration Corrupt"},
    {field = f.iin_buffer_overflow, text = "IIN Event Buffer Overflow"},
    {field = f.iin_obj_unknown, text = "IIN Object Unknown"},
    {field = f.iin_func_not_impl, text = "IIN Function Not Implemented"},
    {field = f.iin_param_invalid, text = "IIN Parameter Invalid"},
  }

  for _, item in ipairs(checks) do
    if field_has_true(item.field) then
      add_warning(item.text)
    end
  end
end

local function count_quality_flags()
  local checks = {
    {field = f.biq_online, text = "Binary Input Online"},
    {field = f.biq_comm_fail, text = "Binary Input Comm Fail"},
    {field = f.aiq_online, text = "Analog Input Online"},
    {field = f.aiq_comm_fail, text = "Analog Input Comm Fail"},
    {field = f.ctrq_online, text = "Counter Online"},
    {field = f.ctrq_comm_fail, text = "Counter Comm Fail"},
  }

  for _, item in ipairs(checks) do
    if field_has_true(item.field) then
      counters.bump(stats.quality_flags, item.text)
    end
  end
end

local function count_error_flags()
  if field_has_true(f.hdr_crc_bad) then
    counters.bump(stats.crc_errors, "Header CRC incorrect")
    stats.errors = stats.errors + 1
    add_warning("DNP3 header CRC error")
  end

  if field_has_true(f.data_crc_bad) then
    counters.bump(stats.crc_errors, "Data chunk CRC incorrect")
    stats.errors = stats.errors + 1
    add_warning("DNP3 data CRC error")
  end

  if field_has_true(f.invalid_length) then
    stats.errors = stats.errors + 1
    add_warning("Invalid DNP3 length")
  end

  if field_has_true(f.unknown_object) then
    stats.errors = stats.errors + 1
    add_warning("Unknown DNP3 object/variation")
  end
end

local function count_objects()
  bump_number_names(stats.objects, f.al_obj, object_names, 4)

  bump_all(stats.point_indexes, f.point_index)
  bump_all(stats.point_indexes, f.index)

  bump_all(stats.binary_points, f.bi_index)
  bump_all(stats.binary_points, f.bi_event_index)

  bump_all(stats.analog_points, f.ai_index)
  bump_all(stats.analog_points, f.ai_event_index)

  bump_all(stats.counter_points, f.counter_index)
  bump_all(stats.counter_points, f.counter_event_index)

  bump_all(stats.control_points, f.bo_command_index)
  bump_all(stats.control_points, f.ao_command_index)
end

local function on_packet()
  local decoded = has_dnp3_decode()

  stats.frames = stats.frames + 1

  if is_dnp3_tcp_test_frame() then
    stats.tcp_test_frames = stats.tcp_test_frames + 1
  end

  if not decoded then
    return
  end

  stats.decoded_dnp3_frames = stats.decoded_dnp3_frames + 1

  count_conversation()
  bump_all(stats.transport_sequences, f.tr_seq)
  bump_all(stats.app_sequences, f.al_seq)

  count_app_function()
  count_objects()
  count_iin_warnings()
  count_quality_flags()
  count_error_flags()
end

local function build_summary()
  local lines = {}

  lines[#lines + 1] = "ICS Visibility - DNP3 Summary"
  lines[#lines + 1] = string.rep("=", 72)
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("Frames analyzed:       %d", stats.frames)
  lines[#lines + 1] = string.format(
    "TCP 20000/20001 frames:%d",
    stats.tcp_test_frames
  )
  lines[#lines + 1] = string.format(
    "Decoded DNP3 frames:   %d",
    stats.decoded_dnp3_frames
  )
  lines[#lines + 1] = string.format("Requests:              %d", stats.requests)
  lines[#lines + 1] = string.format("Responses:             %d", stats.responses)
  lines[#lines + 1] = string.format("Unsolicited responses: %d", stats.unsolicited)
  lines[#lines + 1] = string.format("Confirms:              %d", stats.confirms)
  lines[#lines + 1] = string.format("Reads:                 %d", stats.reads)
  lines[#lines + 1] = string.format("Writes:                %d", stats.writes)
  lines[#lines + 1] = string.format("Controls:              %d", stats.controls)
  lines[#lines + 1] = string.format("Time sync:             %d", stats.time_sync)
  lines[#lines + 1] = string.format("Restarts:              %d", stats.restarts)
  lines[#lines + 1] = string.format("Errors:                %d", stats.errors)
  lines[#lines + 1] = string.format("Warnings:              %d", stats.warning_count)

  windows.add_count_section(lines, "IP Conversations", stats.pairs, 20)
  windows.add_count_section(lines, "DNP3 Address Pairs", stats.dnp_pairs, 20)
  windows.add_count_section(lines, "DNP3 Sources", stats.sources, 20)
  windows.add_count_section(lines, "DNP3 Destinations", stats.destinations, 20)
  windows.add_count_section(lines, "Application Functions", stats.app_functions, 30)
  windows.add_count_section(lines, "Objects", stats.objects, 30)
  windows.add_count_section(lines, "IIN Values", stats.iins, 20)
  windows.add_count_section(lines, "Point Indexes", stats.point_indexes, 30)
  windows.add_count_section(lines, "Binary Input Points", stats.binary_points, 30)
  windows.add_count_section(lines, "Analog Input Points", stats.analog_points, 30)
  windows.add_count_section(lines, "Counter Points", stats.counter_points, 30)
  windows.add_count_section(lines, "Control Points", stats.control_points, 30)
  windows.add_count_section(lines, "Quality Flags", stats.quality_flags, 20)
  windows.add_count_section(lines, "Transport Sequences", stats.transport_sequences, 20)
  windows.add_count_section(lines, "Application Sequences", stats.app_sequences, 20)
  windows.add_count_section(lines, "CRC Errors", stats.crc_errors, 20)
  windows.add_count_section(lines, "Warnings", stats.warnings, 30)

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Notes:"
  lines[#lines + 1] = "- DNP3 over TCP normally uses port 20000."
  lines[#lines + 1] = "- Display filters: dnp3, tcp.port == 20000"
  lines[#lines + 1] = "- This plugin is passive and does not send packets."

  return table.concat(lines, "\n")
end

local function export_csv()
  local base = "ics_visibility_dnp3_"
  local outputs = {
    {
      path = csv.temp_path(base .. "ip_conversations.csv"),
      key = "conversation",
      count = "count",
      data = stats.pairs,
    },
    {
      path = csv.temp_path(base .. "dnp3_address_pairs.csv"),
      key = "address_pair",
      count = "count",
      data = stats.dnp_pairs,
    },
    {
      path = csv.temp_path(base .. "app_functions.csv"),
      key = "app_function",
      count = "count",
      data = stats.app_functions,
    },
    {
      path = csv.temp_path(base .. "objects.csv"),
      key = "object",
      count = "count",
      data = stats.objects,
    },
    {
      path = csv.temp_path(base .. "iin_values.csv"),
      key = "iin",
      count = "count",
      data = stats.iins,
    },
    {
      path = csv.temp_path(base .. "point_indexes.csv"),
      key = "point_index",
      count = "count",
      data = stats.point_indexes,
    },
    {
      path = csv.temp_path(base .. "warnings.csv"),
      key = "warning",
      count = "count",
      data = stats.warnings,
    },
  }

  local lines = {
    "DNP3 CSV export",
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
    "ICS Visibility DNP3 CSV Export",
    table.concat(lines, "\n")
  )
end

local function show_summary()
  local win = windows.show_text("ICS Visibility DNP3", build_summary())

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

  tap = Listener.new(nil, "dnp3 || tcp.port == 20000 || tcp.port == 20001")

  function tap.packet()
    on_packet()
  end

  function tap.reset()
    stats = new_stats()
  end

  function tap.draw()
  end

  register_menu(
    "ICS Visibility/DNP3/Summary",
    show_summary,
    MENU_TOOLS_UNSORTED
  )
end

return M