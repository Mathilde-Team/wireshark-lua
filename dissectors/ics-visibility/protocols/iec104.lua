-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (protocols/iec104.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- protocols/iec104.lua
--
-- Passive IEC-60870-5-104 visibility summary.
--
-- Menu:
--   Tools -> ICS Visibility -> IEC-104 -> Summary

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

local typeid_names = {
  [1] = "M_SP_NA_1 Single-point information",
  [3] = "M_DP_NA_1 Double-point information",
  [9] = "M_ME_NA_1 Measured normalized value",
  [11] = "M_ME_NB_1 Measured scaled value",
  [13] = "M_ME_NC_1 Measured short float",
  [15] = "M_IT_NA_1 Integrated totals",
  [30] = "M_SP_TB_1 Single-point with CP56Time2a",
  [31] = "M_DP_TB_1 Double-point with CP56Time2a",
  [34] = "M_ME_TD_1 Normalized value with CP56Time2a",
  [35] = "M_ME_TE_1 Scaled value with CP56Time2a",
  [36] = "M_ME_TF_1 Short float with CP56Time2a",
  [45] = "C_SC_NA_1 Single command",
  [46] = "C_DC_NA_1 Double command",
  [47] = "C_RC_NA_1 Regulating step command",
  [48] = "C_SE_NA_1 Setpoint normalized command",
  [49] = "C_SE_NB_1 Setpoint scaled command",
  [50] = "C_SE_NC_1 Setpoint short float command",
  [58] = "C_SC_TA_1 Single command with CP56Time2a",
  [59] = "C_DC_TA_1 Double command with CP56Time2a",
  [100] = "C_IC_NA_1 Interrogation command",
  [101] = "C_CI_NA_1 Counter interrogation command",
  [103] = "C_CS_NA_1 Clock synchronization command",
  [104] = "C_TS_NA_1 Test command",
  [105] = "C_RP_NA_1 Reset process command",
}

local cause_names = {
  [1] = "Periodic/cyclic",
  [2] = "Background scan",
  [3] = "Spontaneous",
  [4] = "Initialized",
  [5] = "Request",
  [6] = "Activation",
  [7] = "Activation confirmation",
  [8] = "Deactivation",
  [9] = "Deactivation confirmation",
  [10] = "Activation termination",
  [20] = "Interrogated by station",
  [44] = "Unknown type identification",
  [45] = "Unknown cause of transmission",
  [46] = "Unknown common address",
  [47] = "Unknown information object address",
}

local function new_stats()
  return {
    frames = 0,
    tcp_test_frames = 0,
    decoded_iec104_frames = 0,
    i_frames = 0,
    s_frames = 0,
    u_frames = 0,
    startdt = 0,
    stopdt = 0,
    testfr = 0,
    telemetry = 0,
    commands = 0,
    interrogations = 0,
    clock_sync = 0,
    negative_confirmations = 0,
    warnings_count = 0,
    pairs = {},
    apci_types = {},
    u_types = {},
    tx_seq = {},
    rx_seq = {},
    typeids = {},
    causes = {},
    common_addresses = {},
    ioas = {},
    single_points = {},
    double_points = {},
    measured_values = {},
    command_objects = {},
    qoi_values = {},
    quality_flags = {},
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

local function add_warning(text)
  counters.bump(stats.warnings, text)
  stats.warnings_count = stats.warnings_count + 1
end

local function values_any(primary, fallback)
  local values = fields_lib.values(primary)

  if #values > 0 then
    return values
  end

  return fields_lib.values(fallback)
end

local function first_any(primary, fallback)
  local value = fields_lib.first(primary)

  if value ~= "" then
    return value
  end

  return fields_lib.first(fallback)
end

local function first_number_any(primary, fallback)
  return parse_number(first_any(primary, fallback))
end

local function bump_values(tbl, values)
  for _, value in ipairs(values) do
    counters.bump(tbl, value)
  end
end

local function bump_number_names(tbl, values, names, width)
  for _, value in ipairs(values) do
    local code = parse_number(value)

    counters.bump(tbl, named_value(names, code, width))
  end
end

local function init_fields()
  f.ip_src = fields_lib.safe_field("ip.src")
  f.ip_dst = fields_lib.safe_field("ip.dst")
  f.tcp_srcport = fields_lib.safe_field("tcp.srcport")
  f.tcp_dstport = fields_lib.safe_field("tcp.dstport")

  f.apci_len = fields_lib.safe_field("iec60870_104.apdulen")
  f.apci_type = fields_lib.safe_field("iec60870_104.type")
  f.apci_utype = fields_lib.safe_field("iec60870_104.utype")
  f.apci_tx = fields_lib.safe_field("iec60870_104.tx")
  f.apci_rx = fields_lib.safe_field("iec60870_104.rx")

  f.apdu_invalid_len = fields_lib.safe_field("iec104.apdu_invalid_len")
  f.apdu_min_len = fields_lib.safe_field("iec104.apdu_min_len")
  f.short_asdu = fields_lib.safe_field("iec104.short_asdu")

  f.typeid = fields_lib.safe_field("iec60870_asdu.typeid")
  f.old_typeid = fields_lib.safe_field("104asdu.typeid")

  f.cause = fields_lib.safe_field("iec60870_asdu.causetx")
  f.old_cause = fields_lib.safe_field("104asdu.causetx")

  f.common_addr = fields_lib.safe_field("iec60870_asdu.addr")
  f.old_common_addr = fields_lib.safe_field("104asdu.addr")

  f.oa = fields_lib.safe_field("iec60870_asdu.oa")
  f.old_oa = fields_lib.safe_field("104asdu.oa")

  f.ioa = fields_lib.safe_field("iec60870_asdu.ioa")
  f.old_ioa = fields_lib.safe_field("104asdu.ioa")

  f.sq = fields_lib.safe_field("iec60870_asdu.sq")
  f.old_sq = fields_lib.safe_field("104asdu.sq")

  f.numix = fields_lib.safe_field("iec60870_asdu.numix")
  f.old_numix = fields_lib.safe_field("104asdu.numix")

  f.test = fields_lib.safe_field("iec60870_asdu.test")
  f.old_test = fields_lib.safe_field("104asdu.test")

  f.negative = fields_lib.safe_field("iec60870_asdu.nega")
  f.old_negative = fields_lib.safe_field("104asdu.nega")

  f.siq_spi = fields_lib.safe_field("iec60870_asdu.siq.spi")
  f.old_siq_spi = fields_lib.safe_field("104asdu.siq.spi")

  f.diq_dpi = fields_lib.safe_field("iec60870_asdu.diq.dpi")
  f.old_diq_dpi = fields_lib.safe_field("104asdu.diq.dpi")

  f.normval = fields_lib.safe_field("iec60870_asdu.normval")
  f.old_normval = fields_lib.safe_field("104asdu.normval")

  f.scalval = fields_lib.safe_field("iec60870_asdu.scalval")
  f.old_scalval = fields_lib.safe_field("104asdu.scalval")

  f.floatval = fields_lib.safe_field("iec60870_asdu.float")
  f.old_floatval = fields_lib.safe_field("104asdu.float")

  f.bcr_count = fields_lib.safe_field("iec60870_asdu.bcr.count")
  f.old_bcr_count = fields_lib.safe_field("104asdu.bcr.count")

  f.qds_iv = fields_lib.safe_field("iec60870_asdu.qds.iv")
  f.old_qds_iv = fields_lib.safe_field("104asdu.qds.iv")

  f.qds_nt = fields_lib.safe_field("iec60870_asdu.qds.nt")
  f.old_qds_nt = fields_lib.safe_field("104asdu.qds.nt")

  f.qds_sb = fields_lib.safe_field("iec60870_asdu.qds.sb")
  f.old_qds_sb = fields_lib.safe_field("104asdu.qds.sb")

  f.qds_bl = fields_lib.safe_field("iec60870_asdu.qds.bl")
  f.old_qds_bl = fields_lib.safe_field("104asdu.qds.bl")

  f.qds_ov = fields_lib.safe_field("iec60870_asdu.qds.ov")
  f.old_qds_ov = fields_lib.safe_field("104asdu.qds.ov")

  f.sco = fields_lib.safe_field("iec60870_asdu.sco")
  f.old_sco = fields_lib.safe_field("104asdu.sco")

  f.sco_on = fields_lib.safe_field("iec60870_asdu.sco.on")
  f.old_sco_on = fields_lib.safe_field("104asdu.sco.on")

  f.sco_se = fields_lib.safe_field("iec60870_asdu.sco.se")
  f.old_sco_se = fields_lib.safe_field("104asdu.sco.se")

  f.dco = fields_lib.safe_field("iec60870_asdu.dco")
  f.old_dco = fields_lib.safe_field("104asdu.dco")

  f.dco_on = fields_lib.safe_field("iec60870_asdu.dco.on")
  f.old_dco_on = fields_lib.safe_field("104asdu.dco.on")

  f.dco_se = fields_lib.safe_field("iec60870_asdu.dco.se")
  f.old_dco_se = fields_lib.safe_field("104asdu.dco.se")

  f.qoi = fields_lib.safe_field("iec60870_asdu.qoi")
  f.old_qoi = fields_lib.safe_field("104asdu.qoi")
end

local function is_iec104_tcp_test_frame()
  local src_port = fields_lib.first(f.tcp_srcport)
  local dst_port = fields_lib.first(f.tcp_dstport)

  return (
    src_port == "2404" or
    dst_port == "2404" or
    src_port == "12404" or
    dst_port == "12404"
  )
end

local function has_iec104_decode()
  if fields_lib.first(f.apci_len) ~= "" then
    return true
  end

  if fields_lib.first(f.apci_type) ~= "" then
    return true
  end

  if first_any(f.typeid, f.old_typeid) ~= "" then
    return true
  end

  return false
end

local function count_conversation()
  local src = fields_lib.first(f.ip_src)
  local dst = fields_lib.first(f.ip_dst)

  if src ~= "" and dst ~= "" then
    counters.bump(stats.pairs, src .. " -> " .. dst)
  end
end

local function classify_apci()
  local raw_type = fields_lib.first(f.apci_type)
  local type_code = parse_number(raw_type)
  local utype = fields_lib.first(f.apci_utype)

  counters.bump(stats.apci_types, raw_type)
  counters.bump(stats.u_types, utype)

  bump_values(stats.tx_seq, fields_lib.values(f.apci_tx))
  bump_values(stats.rx_seq, fields_lib.values(f.apci_rx))

  if type_code == 0 or raw_type:find("I", 1, true) then
    stats.i_frames = stats.i_frames + 1
  elseif type_code == 1 or raw_type:find("S", 1, true) then
    stats.s_frames = stats.s_frames + 1
  elseif type_code == 3 or raw_type:find("U", 1, true) then
    stats.u_frames = stats.u_frames + 1
  end

  local upper = utype:upper()

  if upper:find("START", 1, true) then
    stats.startdt = stats.startdt + 1
  elseif upper:find("STOP", 1, true) then
    stats.stopdt = stats.stopdt + 1
    add_warning("STOPDT observed")
  elseif upper:find("TEST", 1, true) then
    stats.testfr = stats.testfr + 1
  end
end

local function classify_typeid()
  local typeid = first_number_any(f.typeid, f.old_typeid)
  local cause = first_number_any(f.cause, f.old_cause)

  bump_number_names(
    stats.typeids,
    values_any(f.typeid, f.old_typeid),
    typeid_names,
    2
  )

  bump_number_names(
    stats.causes,
    values_any(f.cause, f.old_cause),
    cause_names,
    2
  )

  bump_values(
    stats.common_addresses,
    values_any(f.common_addr, f.old_common_addr)
  )

  bump_values(stats.ioas, values_any(f.ioa, f.old_ioa))

  if typeid == nil then
    return
  end

  if typeid == 1 or typeid == 3 then
    stats.telemetry = stats.telemetry + 1
  elseif typeid == 9 or typeid == 11 or typeid == 13 then
    stats.telemetry = stats.telemetry + 1
  elseif typeid == 15 or typeid == 30 or typeid == 31 then
    stats.telemetry = stats.telemetry + 1
  elseif typeid == 34 or typeid == 35 or typeid == 36 then
    stats.telemetry = stats.telemetry + 1
  elseif typeid >= 45 and typeid <= 50 then
    stats.commands = stats.commands + 1
    add_warning("IEC-104 control command observed")
  elseif typeid == 58 or typeid == 59 then
    stats.commands = stats.commands + 1
    add_warning("IEC-104 time-tagged control command observed")
  elseif typeid == 100 or typeid == 101 then
    stats.interrogations = stats.interrogations + 1
  elseif typeid == 103 then
    stats.clock_sync = stats.clock_sync + 1
    add_warning("IEC-104 clock synchronization observed")
  end

  if cause == 44 or cause == 45 or cause == 46 or cause == 47 then
    add_warning("IEC-104 negative/error cause observed")
  end
end

local function count_values()
  bump_values(stats.single_points, values_any(f.siq_spi, f.old_siq_spi))
  bump_values(stats.double_points, values_any(f.diq_dpi, f.old_diq_dpi))

  bump_values(stats.measured_values, values_any(f.normval, f.old_normval))
  bump_values(stats.measured_values, values_any(f.scalval, f.old_scalval))
  bump_values(stats.measured_values, values_any(f.floatval, f.old_floatval))
  bump_values(stats.measured_values, values_any(f.bcr_count, f.old_bcr_count))

  bump_values(stats.command_objects, values_any(f.sco, f.old_sco))
  bump_values(stats.command_objects, values_any(f.dco, f.old_dco))

  bump_values(stats.qoi_values, values_any(f.qoi, f.old_qoi))
end

local function count_quality_flags()
  local checks = {
    {primary = f.qds_iv, fallback = f.old_qds_iv, text = "QDS Invalid"},
    {primary = f.qds_nt, fallback = f.old_qds_nt, text = "QDS Not Topical"},
    {primary = f.qds_sb, fallback = f.old_qds_sb, text = "QDS Substituted"},
    {primary = f.qds_bl, fallback = f.old_qds_bl, text = "QDS Blocked"},
    {primary = f.qds_ov, fallback = f.old_qds_ov, text = "QDS Overflow"},
  }

  for _, item in ipairs(checks) do
    if field_has_true(item.primary) or field_has_true(item.fallback) then
      counters.bump(stats.quality_flags, item.text)
      add_warning(item.text)
    end
  end

  if field_has_true(f.negative) or field_has_true(f.old_negative) then
    stats.negative_confirmations = stats.negative_confirmations + 1
    add_warning("Negative confirmation flag observed")
  end

  if field_has_true(f.test) or field_has_true(f.old_test) then
    add_warning("IEC-104 test flag observed")
  end

  if field_has_true(f.apdu_invalid_len) then
    add_warning("IEC-104 invalid APDU length")
  end

  if field_has_true(f.apdu_min_len) then
    add_warning("IEC-104 APDU below minimum length")
  end

  if field_has_true(f.short_asdu) then
    add_warning("IEC-104 short ASDU")
  end
end

local function on_packet()
  local decoded = has_iec104_decode()

  stats.frames = stats.frames + 1

  if is_iec104_tcp_test_frame() then
    stats.tcp_test_frames = stats.tcp_test_frames + 1
  end

  if not decoded then
    return
  end

  stats.decoded_iec104_frames = stats.decoded_iec104_frames + 1

  count_conversation()
  classify_apci()
  classify_typeid()
  count_values()
  count_quality_flags()
end

local function build_summary()
  local lines = {}

  lines[#lines + 1] = "ICS Visibility - IEC-104 Summary"
  lines[#lines + 1] = string.rep("=", 72)
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("Frames analyzed:       %d", stats.frames)
  lines[#lines + 1] = string.format("TCP 2404/12404 frames: %d", stats.tcp_test_frames)
  lines[#lines + 1] = string.format(
    "Decoded IEC-104 frames:%d",
    stats.decoded_iec104_frames
  )
  lines[#lines + 1] = string.format("I-format frames:       %d", stats.i_frames)
  lines[#lines + 1] = string.format("S-format frames:       %d", stats.s_frames)
  lines[#lines + 1] = string.format("U-format frames:       %d", stats.u_frames)
  lines[#lines + 1] = string.format("STARTDT frames:        %d", stats.startdt)
  lines[#lines + 1] = string.format("STOPDT frames:         %d", stats.stopdt)
  lines[#lines + 1] = string.format("TESTFR frames:         %d", stats.testfr)
  lines[#lines + 1] = string.format("Telemetry ASDUs:       %d", stats.telemetry)
  lines[#lines + 1] = string.format("Command ASDUs:         %d", stats.commands)
  lines[#lines + 1] = string.format("Interrogations:        %d", stats.interrogations)
  lines[#lines + 1] = string.format("Clock sync:            %d", stats.clock_sync)
  lines[#lines + 1] = string.format(
    "Negative confirms:     %d",
    stats.negative_confirmations
  )
  lines[#lines + 1] = string.format("Warnings:              %d", stats.warnings_count)

  windows.add_count_section(lines, "IP Conversations", stats.pairs, 20)
  windows.add_count_section(lines, "APCI Types", stats.apci_types, 20)
  windows.add_count_section(lines, "U-frame Types", stats.u_types, 20)
  windows.add_count_section(lines, "TX Sequence Numbers", stats.tx_seq, 20)
  windows.add_count_section(lines, "RX Sequence Numbers", stats.rx_seq, 20)
  windows.add_count_section(lines, "ASDU Type IDs", stats.typeids, 30)
  windows.add_count_section(lines, "Causes of Transmission", stats.causes, 30)
  windows.add_count_section(lines, "Common Addresses", stats.common_addresses, 20)
  windows.add_count_section(lines, "Information Object Addresses", stats.ioas, 40)
  windows.add_count_section(lines, "Single Points", stats.single_points, 20)
  windows.add_count_section(lines, "Double Points", stats.double_points, 20)
  windows.add_count_section(lines, "Measured Values", stats.measured_values, 30)
  windows.add_count_section(lines, "Command Objects", stats.command_objects, 20)
  windows.add_count_section(lines, "QOI Values", stats.qoi_values, 20)
  windows.add_count_section(lines, "Quality Flags", stats.quality_flags, 20)
  windows.add_count_section(lines, "Warnings", stats.warnings, 30)

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Notes:"
  lines[#lines + 1] = "- IEC-104 normally uses TCP port 2404."
  lines[#lines + 1] = "- Display filters: iec60870_104, iec60870_asdu, tcp.port == 2404"
  lines[#lines + 1] = "- This plugin is passive and does not send packets."

  return table.concat(lines, "\n")
end

local function export_csv()
  local base = "ics_visibility_iec104_"
  local outputs = {
    {
      path = csv.temp_path(base .. "conversations.csv"),
      key = "conversation",
      count = "count",
      data = stats.pairs,
    },
    {
      path = csv.temp_path(base .. "typeids.csv"),
      key = "typeid",
      count = "count",
      data = stats.typeids,
    },
    {
      path = csv.temp_path(base .. "causes.csv"),
      key = "cause",
      count = "count",
      data = stats.causes,
    },
    {
      path = csv.temp_path(base .. "common_addresses.csv"),
      key = "common_address",
      count = "count",
      data = stats.common_addresses,
    },
    {
      path = csv.temp_path(base .. "ioas.csv"),
      key = "ioa",
      count = "count",
      data = stats.ioas,
    },
    {
      path = csv.temp_path(base .. "quality_flags.csv"),
      key = "quality_flag",
      count = "count",
      data = stats.quality_flags,
    },
    {
      path = csv.temp_path(base .. "warnings.csv"),
      key = "warning",
      count = "count",
      data = stats.warnings,
    },
  }

  local lines = {
    "IEC-104 CSV export",
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
    "ICS Visibility IEC-104 CSV Export",
    table.concat(lines, "\n")
  )
end

local function show_summary()
  local win = windows.show_text("ICS Visibility IEC-104", build_summary())

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

  tap = Listener.new(nil, "tcp.port == 2404 || tcp.port == 12404")

  function tap.packet()
    on_packet()
  end

  function tap.reset()
    stats = new_stats()
  end

  function tap.draw()
  end

  register_menu(
    "ICS Visibility/IEC-104/Summary",
    show_summary,
    MENU_TOOLS_UNSORTED
  )
end

return M