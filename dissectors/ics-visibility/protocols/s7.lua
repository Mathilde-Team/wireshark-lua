-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (protocols/s7.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- protocols/s7.lua
--
-- Passive Siemens S7 visibility summary.
--
-- Menu:
--   Tools -> ICS Visibility -> S7comm -> Summary

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

local rosctr_names = {
  [1] = "Job",
  [2] = "Ack",
  [3] = "AckData",
  [7] = "UserData",
}

local function_names = {
  [0x04] = "Read Var",
  [0x05] = "Write Var",
  [0x1A] = "Request Download",
  [0x1B] = "Download Block",
  [0x1C] = "Download Ended",
  [0x1D] = "Start Upload",
  [0x1E] = "Upload",
  [0x1F] = "End Upload",
  [0x28] = "PI Service",
  [0x29] = "PLC Stop",
  [0xF0] = "Setup Communication",
}

local area_names = {
  [0x81] = "Inputs",
  [0x82] = "Outputs",
  [0x83] = "Merkers",
  [0x84] = "DB",
  [0x1C] = "Counters",
  [0x1D] = "Timers",
}

local return_code_names = {
  [0xFF] = "Success",
  [0x01] = "Hardware fault",
  [0x03] = "Accessing object not allowed",
  [0x05] = "Invalid address",
  [0x06] = "Data type not supported",
  [0x0A] = "Object does not exist",
}

local function new_stats()
  return {
	frames = 0,
	tcp_test_frames = 0,
	decoded_cotp_frames = 0,
	decoded_s7_frames = 0,
	setup_comm = 0,
    reads = 0,
    writes = 0,
    jobs = 0,
    ack_data = 0,
    errors = 0,
    warning_count = 0,
    pairs = {},
    cotp_types = {},
    rosctrs = {},
    functions = {},
    pdu_refs = {},
    dbs = {},
    areas = {},
    access_items = {},
    item_lengths = {},
    item_counts = {},
    return_codes = {},
    header_errors = {},
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
  counters.bump(stats.warnings, text)
  stats.warning_count = stats.warning_count + 1
end

local function values(field)
  return fields_lib.values(field)
end

local function first_number(field)
  return parse_number(fields_lib.first(field))
end

local function init_fields()
  f.ip_src = fields_lib.safe_field("ip.src")
  f.ip_dst = fields_lib.safe_field("ip.dst")
  f.tcp_srcport = fields_lib.safe_field("tcp.srcport")
  f.tcp_dstport = fields_lib.safe_field("tcp.dstport")

  f.cotp_type = fields_lib.safe_field("cotp.type")
  f.cotp_src_ref = fields_lib.safe_field("cotp.srcref")
  f.cotp_dst_ref = fields_lib.safe_field("cotp.dstref")

  f.rosctr = fields_lib.safe_field("s7comm.header.rosctr")
  f.pdu_ref = fields_lib.safe_field("s7comm.header.pduref")
  f.protocol_id = fields_lib.safe_field("s7comm.header.protid")
  f.param_len = fields_lib.safe_field("s7comm.header.parlg")
  f.data_len = fields_lib.safe_field("s7comm.header.datlg")
  f.err_class = fields_lib.safe_field("s7comm.header.errcls")
  f.err_code = fields_lib.safe_field("s7comm.header.errcod")

  f.function_code = fields_lib.safe_field("s7comm.param.func")
  f.item_count = fields_lib.safe_field("s7comm.param.itemcount")
  f.pdu_length = fields_lib.safe_field("s7comm.param.pdu_length")

  f.item_db = fields_lib.safe_field("s7comm.param.item.db")
  f.item_area = fields_lib.safe_field("s7comm.param.item.area")
  f.item_address = fields_lib.safe_field("s7comm.param.item.address")
  f.item_address_byte = fields_lib.safe_field("s7comm.param.item.address.byte")
  f.item_address_bit = fields_lib.safe_field("s7comm.param.item.address.bit")
  f.item_length = fields_lib.safe_field("s7comm.param.item.length")
  f.item_transport_size = fields_lib.safe_field("s7comm.param.item.transp_size")

  f.dbread_db = fields_lib.safe_field("s7comm.param.item.dbread.db")
  f.dbread_start = fields_lib.safe_field("s7comm.param.item.dbread.startaddress")
  f.dbread_length = fields_lib.safe_field("s7comm.param.item.dbread.length")

  f.return_code = fields_lib.safe_field("s7comm.data.returncode")
  f.data_transport_size = fields_lib.safe_field("s7comm.data.transportsize")
end

local function count_basic_fields()
  local src = fields_lib.first(f.ip_src)
  local dst = fields_lib.first(f.ip_dst)

  if src ~= "" and dst ~= "" then
    counters.bump(stats.pairs, src .. " -> " .. dst)
  end

  for _, value in ipairs(values(f.cotp_type)) do
    counters.bump(stats.cotp_types, value)
  end

  for _, value in ipairs(values(f.pdu_ref)) do
    counters.bump(stats.pdu_refs, value)
  end

  for _, value in ipairs(values(f.item_count)) do
    counters.bump(stats.item_counts, value)
  end
end

local function count_rosctr()
  local code = first_number(f.rosctr)

  counters.bump(stats.rosctrs, named_value(rosctr_names, code))

  if code == 1 then
    stats.jobs = stats.jobs + 1
  elseif code == 3 then
    stats.ack_data = stats.ack_data + 1
  end
end

local function count_function()
  local code = first_number(f.function_code)

  counters.bump(stats.functions, named_value(function_names, code))

  if code == 0xF0 then
    stats.setup_comm = stats.setup_comm + 1
  elseif code == 0x04 then
    stats.reads = stats.reads + 1
  elseif code == 0x05 then
    stats.writes = stats.writes + 1
  end

  if code == 0x29 then
    add_warning("PLC Stop function observed")
  end
end

local function count_access_items()
  local dbs = values(f.item_db)
  local areas = values(f.item_area)
  local byte_addresses = values(f.item_address_byte)
  local bit_addresses = values(f.item_address_bit)
  local lengths = values(f.item_length)

  local count = math.max(
    #dbs,
    #areas,
    #byte_addresses,
    #bit_addresses,
    #lengths
  )

  for index = 1, count do
    local db = dbs[index] or ""
    local area_raw = areas[index] or ""
    local byte_addr = byte_addresses[index] or ""
    local bit_addr = bit_addresses[index] or ""
    local length = lengths[index] or ""

    local area_code = parse_number(area_raw)
    local area = named_value(area_names, area_code)

    counters.bump(stats.dbs, db)
    counters.bump(stats.areas, area)
    counters.bump(stats.item_lengths, length)

    counters.bump(
      stats.access_items,
      "DB " .. db ..
      " / " .. area ..
      " / byte " .. byte_addr ..
      " / bit " .. bit_addr ..
      " / len " .. length
    )
  end

  for _, db in ipairs(values(f.dbread_db)) do
    counters.bump(stats.dbs, db)
  end
end

local function count_return_codes()
  for _, value in ipairs(values(f.return_code)) do
    local code = parse_number(value)
    local name = named_value(return_code_names, code)

    counters.bump(stats.return_codes, name)

    if code ~= nil and code ~= 0xFF then
      stats.errors = stats.errors + 1
      add_warning("Non-success S7 return code: " .. name)
    end
  end
end

local function count_header_errors()
  local err_class = first_number(f.err_class)
  local err_code = first_number(f.err_code)

  if err_class ~= nil and err_class ~= 0 then
    local key = string.format(
      "class 0x%02X / code 0x%02X",
      err_class,
      err_code or 0
    )

    counters.bump(stats.header_errors, key)
    stats.errors = stats.errors + 1
    add_warning("S7 header error observed: " .. key)
  end
end

local function is_s7_tcp_test_frame()
  local src_port = fields_lib.first(f.tcp_srcport)
  local dst_port = fields_lib.first(f.tcp_dstport)

  return (
    src_port == "102" or
    dst_port == "102" or
    src_port == "1102" or
    dst_port == "1102"
  )
end

local function has_cotp_decode()
  return fields_lib.first(f.cotp_type) ~= ""
end

local function has_s7_decode()
  if fields_lib.first(f.rosctr) ~= "" then
    return true
  end

  if fields_lib.first(f.function_code) ~= "" then
    return true
  end

  if #fields_lib.values(f.return_code) > 0 then
    return true
  end

  return false
end

local function on_packet()
  local cotp_decoded = has_cotp_decode()
  local s7_decoded = has_s7_decode()

  stats.frames = stats.frames + 1

  if is_s7_tcp_test_frame() then
    stats.tcp_test_frames = stats.tcp_test_frames + 1
  end

  if cotp_decoded then
    stats.decoded_cotp_frames = stats.decoded_cotp_frames + 1
  end

  if s7_decoded then
    stats.decoded_s7_frames = stats.decoded_s7_frames + 1
  end

  count_basic_fields()

  -- If Wireshark has not decoded the packet as S7comm yet, do not pollute
  -- the S7 sections with "unknown" counters.
  if not s7_decoded then
    return
  end

  count_rosctr()
  count_function()
  count_access_items()
  count_return_codes()
  count_header_errors()
end

local function build_summary()
  local lines = {}

  lines[#lines + 1] = "ICS Visibility - S7comm Summary"
  lines[#lines + 1] = string.rep("=", 72)
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("Frames analyzed:       %d", stats.frames)
  lines[#lines + 1] = string.format(
    "TCP 102/1102 frames:   %d",
    stats.tcp_test_frames
  )
  lines[#lines + 1] = string.format(
    "Decoded COTP frames:   %d",
    stats.decoded_cotp_frames
  )
  lines[#lines + 1] = string.format(
    "Decoded S7comm frames: %d",
    stats.decoded_s7_frames
  )
  lines[#lines + 1] = string.format("Jobs:                  %d", stats.jobs)
  lines[#lines + 1] = string.format("AckData responses:     %d", stats.ack_data)
  lines[#lines + 1] = string.format("Setup Communication:   %d", stats.setup_comm)
  lines[#lines + 1] = string.format("Read Var messages:     %d", stats.reads)
  lines[#lines + 1] = string.format("Write Var messages:    %d", stats.writes)
  lines[#lines + 1] = string.format("Errors:                %d", stats.errors)
  lines[#lines + 1] = string.format("Warnings:              %d", stats.warning_count)

  windows.add_count_section(lines, "IP Conversations", stats.pairs, 20)
  windows.add_count_section(lines, "COTP Types", stats.cotp_types, 20)
  windows.add_count_section(lines, "ROSCTR Types", stats.rosctrs, 20)
  windows.add_count_section(lines, "S7 Functions", stats.functions, 20)
  windows.add_count_section(lines, "DB Numbers", stats.dbs, 30)
  windows.add_count_section(lines, "Memory Areas", stats.areas, 20)
  windows.add_count_section(lines, "Access Items", stats.access_items, 40)
  windows.add_count_section(lines, "Item Lengths", stats.item_lengths, 20)
  windows.add_count_section(lines, "Item Counts", stats.item_counts, 20)
  windows.add_count_section(lines, "Return Codes", stats.return_codes, 20)
  windows.add_count_section(lines, "Header Errors", stats.header_errors, 20)
  windows.add_count_section(lines, "PDU References", stats.pdu_refs, 20)
  windows.add_count_section(lines, "Warnings", stats.warnings, 20)

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Notes:"
  lines[#lines + 1] = "- S7comm normally rides on TCP port 102 through TPKT/COTP."
  lines[#lines + 1] = "- Display filters: s7comm, cotp, tcp.port == 102"
  lines[#lines + 1] = "- This plugin is passive and does not send packets."

  return table.concat(lines, "\n")
end

local function export_csv()
  local base = "ics_visibility_s7comm_"
  local outputs = {
    {
      path = csv.temp_path(base .. "conversations.csv"),
      key = "conversation",
      count = "count",
      data = stats.pairs,
    },
    {
      path = csv.temp_path(base .. "functions.csv"),
      key = "function",
      count = "count",
      data = stats.functions,
    },
    {
      path = csv.temp_path(base .. "dbs.csv"),
      key = "db",
      count = "count",
      data = stats.dbs,
    },
    {
      path = csv.temp_path(base .. "areas.csv"),
      key = "area",
      count = "count",
      data = stats.areas,
    },
    {
      path = csv.temp_path(base .. "access_items.csv"),
      key = "access_item",
      count = "count",
      data = stats.access_items,
    },
    {
      path = csv.temp_path(base .. "return_codes.csv"),
      key = "return_code",
      count = "count",
      data = stats.return_codes,
    },
    {
      path = csv.temp_path(base .. "warnings.csv"),
      key = "warning",
      count = "count",
      data = stats.warnings,
    },
  }

  local lines = {
    "S7comm CSV export",
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
    "ICS Visibility S7comm CSV Export",
    table.concat(lines, "\n")
  )
end

local function show_summary()
  local win = windows.show_text("ICS Visibility S7comm", build_summary())

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

  tap = Listener.new(nil, "s7comm || cotp || tcp.port == 102 || tcp.port == 1102")

  function tap.packet()
    on_packet()
  end

  function tap.reset()
    stats = new_stats()
  end

  function tap.draw()
  end

  register_menu(
    "ICS Visibility/S7comm/Summary",
    show_summary,
    MENU_TOOLS_UNSORTED
  )
end

return M