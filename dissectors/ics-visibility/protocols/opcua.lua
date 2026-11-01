-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (protocols/opcua.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- protocols/opcua.lua
--
-- Passive OPC UA visibility summary.
--
-- Menu:
--   Tools -> ICS Visibility -> OPC UA -> Summary

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
    message_types = {},
    chunk_types = {},
    endpoints = {},
    server_uris = {},
    security_policies = {},
    security_modes = {},
    secure_channels = {},
    token_ids = {},
    sequence_numbers = {},
    request_ids = {},
    request_handles = {},
    sessions = {},
    users = {},
    status_codes = {},
    service_results = {},
    warnings = {},
    hello = 0,
    ack = 0,
    open_secure_channel = 0,
    close_secure_channel = 0,
    message = 0,
    error = 0,
    encrypted_or_secured = 0,
    usernames_seen = 0,
  }
end

local stats = new_stats()

local function init_fields()
  f.ip_src = fields_lib.safe_field("ip.src")
  f.ip_dst = fields_lib.safe_field("ip.dst")
  f.tcp_srcport = fields_lib.safe_field("tcp.srcport")
  f.tcp_dstport = fields_lib.safe_field("tcp.dstport")

  f.transport_type = fields_lib.safe_field("opcua.transport.type")
  f.transport_chunk = fields_lib.safe_field("opcua.transport.chunk")
  f.transport_endpoint = fields_lib.safe_field("opcua.transport.endpoint")
  f.transport_server_uri = fields_lib.safe_field("opcua.transport.suri")
  f.transport_error = fields_lib.safe_field("opcua.transport.error")
  f.transport_reason = fields_lib.safe_field("opcua.transport.reason")
  f.transport_scid = fields_lib.safe_field("opcua.transport.scid")

  -- Older Wireshark versions used transport.* without the opcua. prefix.
  f.old_transport_type = fields_lib.safe_field("transport.type")
  f.old_transport_chunk = fields_lib.safe_field("transport.chunk")
  f.old_transport_endpoint = fields_lib.safe_field("transport.endpoint")
  f.old_transport_error = fields_lib.safe_field("transport.error")
  f.old_transport_scid = fields_lib.safe_field("transport.scid")

  f.security_policy = fields_lib.safe_field("opcua.security.spu")
  f.security_token_id = fields_lib.safe_field("opcua.security.tokenid")
  f.security_seq = fields_lib.safe_field("opcua.security.seq")
  f.security_rqid = fields_lib.safe_field("opcua.security.rqid")

  f.sequence_number = fields_lib.safe_field("opcua.sequence.seq")
  f.sequence_request_id = fields_lib.safe_field("opcua.sequence.rqid")

  f.request_handle = fields_lib.safe_field("opcua.RequestHandle")
  f.session_name = fields_lib.safe_field("opcua.SessionName")
  f.username = fields_lib.safe_field("opcua.UserName")

  f.endpoint_url = fields_lib.safe_field("opcua.EndpointUrl")
  f.security_mode = fields_lib.safe_field("opcua.MessageSecurityMode")
  f.security_policy_uri = fields_lib.safe_field("opcua.SecurityPolicyUri")

  f.service_result = fields_lib.safe_field("opcua.ServiceResult")
  f.status_code = fields_lib.safe_field("opcua.StatusCode")
end

local function values_with_fallback(primary, fallback)
  local values = fields_lib.values(primary)

  if #values > 0 then
    return values
  end

  return fields_lib.values(fallback)
end

local function first_with_fallback(primary, fallback)
  local value = fields_lib.first(primary)

  if value ~= "" then
    return value
  end

  return fields_lib.first(fallback)
end

local function bump_all(tbl, field)
  for _, value in ipairs(fields_lib.values(field)) do
    counters.bump(tbl, value)
  end
end

local function bump_values(tbl, values)
  for _, value in ipairs(values) do
    counters.bump(tbl, value)
  end
end

local function add_warning(text)
  counters.bump(stats.warnings, text)
end

local function classify_message_type(message_type)
  if message_type == "" then
    return
  end

  local upper = message_type:upper()

  if upper:find("HEL", 1, true) then
    stats.hello = stats.hello + 1
  elseif upper:find("ACK", 1, true) then
    stats.ack = stats.ack + 1
  elseif upper:find("OPN", 1, true) then
    stats.open_secure_channel = stats.open_secure_channel + 1
  elseif upper:find("CLO", 1, true) then
    stats.close_secure_channel = stats.close_secure_channel + 1
  elseif upper:find("MSG", 1, true) then
    stats.message = stats.message + 1
  elseif upper:find("ERR", 1, true) then
    stats.error = stats.error + 1
    add_warning("OPC UA Error message observed")
  end
end

local function count_security()
  local policy_values = fields_lib.values(f.security_policy)
  local uri_values = fields_lib.values(f.security_policy_uri)
  local mode_values = fields_lib.values(f.security_mode)

  bump_values(stats.security_policies, policy_values)
  bump_values(stats.security_policies, uri_values)
  bump_values(stats.security_modes, mode_values)

  if #policy_values > 0 or #uri_values > 0 or #mode_values > 0 then
    stats.encrypted_or_secured = stats.encrypted_or_secured + 1
  end

  for _, value in ipairs(policy_values) do
    if value:find("None", 1, true) then
      add_warning("SecurityPolicy None observed")
    end
  end

  for _, value in ipairs(uri_values) do
    if value:find("None", 1, true) then
      add_warning("SecurityPolicy None observed")
    end
  end

  for _, value in ipairs(mode_values) do
    if value == "1" or value:find("None", 1, true) then
      add_warning("MessageSecurityMode None observed")
    end
  end
end

local function count_users()
  local users = fields_lib.values(f.username)

  if #users > 0 then
    stats.usernames_seen = stats.usernames_seen + #users
  end

  bump_values(stats.users, users)
end

local function count_errors()
  bump_all(stats.status_codes, f.status_code)
  bump_all(stats.service_results, f.service_result)

  if #fields_lib.values(f.transport_error) > 0 then
    add_warning("Transport error observed")
  end

  if #fields_lib.values(f.old_transport_error) > 0 then
    add_warning("Transport error observed")
  end

  if #fields_lib.values(f.status_code) > 0 then
    add_warning("StatusCode observed")
  end

  if #fields_lib.values(f.service_result) > 0 then
    add_warning("ServiceResult observed")
  end
end

local function on_packet()
  local src = fields_lib.first(f.ip_src)
  local dst = fields_lib.first(f.ip_dst)

  local message_type = first_with_fallback(
    f.transport_type,
    f.old_transport_type
  )

  stats.frames = stats.frames + 1

  if src ~= "" and dst ~= "" then
    counters.bump(stats.pairs, src .. " -> " .. dst)
  end

  counters.bump(stats.message_types, message_type)
  classify_message_type(message_type)

  bump_values(
    stats.chunk_types,
    values_with_fallback(f.transport_chunk, f.old_transport_chunk)
  )

  bump_values(
    stats.endpoints,
    values_with_fallback(f.transport_endpoint, f.old_transport_endpoint)
  )

  bump_all(stats.endpoints, f.endpoint_url)
  bump_all(stats.server_uris, f.transport_server_uri)

  bump_values(
    stats.secure_channels,
    values_with_fallback(f.transport_scid, f.old_transport_scid)
  )

  bump_all(stats.token_ids, f.security_token_id)
  bump_all(stats.sequence_numbers, f.security_seq)
  bump_all(stats.sequence_numbers, f.sequence_number)
  bump_all(stats.request_ids, f.security_rqid)
  bump_all(stats.request_ids, f.sequence_request_id)
  bump_all(stats.request_handles, f.request_handle)
  bump_all(stats.sessions, f.session_name)

  count_security()
  count_users()
  count_errors()
end

local function build_summary()
  local lines = {}

  lines[#lines + 1] = "ICS Visibility - OPC UA Summary"
  lines[#lines + 1] = string.rep("=", 72)
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("Frames analyzed:       %d", stats.frames)
  lines[#lines + 1] = string.format("HEL messages:          %d", stats.hello)
  lines[#lines + 1] = string.format("ACK messages:          %d", stats.ack)
  lines[#lines + 1] = string.format(
    "OpenSecureChannel:     %d",
    stats.open_secure_channel
  )
  lines[#lines + 1] = string.format(
    "CloseSecureChannel:    %d",
    stats.close_secure_channel
  )
  lines[#lines + 1] = string.format("MSG messages:          %d", stats.message)
  lines[#lines + 1] = string.format("ERR messages:          %d", stats.error)
  lines[#lines + 1] = string.format(
    "Security fields seen:  %d",
    stats.encrypted_or_secured
  )
  lines[#lines + 1] = string.format(
    "Usernames seen:        %d",
    stats.usernames_seen
  )

  windows.add_count_section(lines, "IP Conversations", stats.pairs, 20)
  windows.add_count_section(lines, "Message Types", stats.message_types, 20)
  windows.add_count_section(lines, "Chunk Types", stats.chunk_types, 20)
  windows.add_count_section(lines, "Endpoints", stats.endpoints, 30)
  windows.add_count_section(lines, "Server URIs", stats.server_uris, 20)
  windows.add_count_section(lines, "Security Policies", stats.security_policies, 30)
  windows.add_count_section(lines, "Security Modes", stats.security_modes, 20)
  windows.add_count_section(lines, "Secure Channel IDs", stats.secure_channels, 20)
  windows.add_count_section(lines, "Security Token IDs", stats.token_ids, 20)
  windows.add_count_section(lines, "Sequence Numbers", stats.sequence_numbers, 20)
  windows.add_count_section(lines, "Request IDs", stats.request_ids, 20)
  windows.add_count_section(lines, "Request Handles", stats.request_handles, 20)
  windows.add_count_section(lines, "Sessions", stats.sessions, 20)
  windows.add_count_section(lines, "Users", stats.users, 20)
  windows.add_count_section(lines, "Status Codes", stats.status_codes, 20)
  windows.add_count_section(lines, "Service Results", stats.service_results, 20)
  windows.add_count_section(lines, "Warnings", stats.warnings, 20)

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Notes:"
  lines[#lines + 1] = "- OPC UA TCP normally uses port 4840."
  lines[#lines + 1] = "- Display filter: opcua"
  lines[#lines + 1] = "- Encrypted OPC UA hides most application details."
  lines[#lines + 1] = "- This plugin is passive and does not send packets."

  return table.concat(lines, "\n")
end

local function export_csv()
  local base = "ics_visibility_opcua_"
  local outputs = {
    {
      path = csv.temp_path(base .. "conversations.csv"),
      key = "conversation",
      count = "count",
      data = stats.pairs,
    },
    {
      path = csv.temp_path(base .. "message_types.csv"),
      key = "message_type",
      count = "count",
      data = stats.message_types,
    },
    {
      path = csv.temp_path(base .. "endpoints.csv"),
      key = "endpoint",
      count = "count",
      data = stats.endpoints,
    },
    {
      path = csv.temp_path(base .. "security_policies.csv"),
      key = "security_policy",
      count = "count",
      data = stats.security_policies,
    },
    {
      path = csv.temp_path(base .. "sessions.csv"),
      key = "session",
      count = "count",
      data = stats.sessions,
    },
    {
      path = csv.temp_path(base .. "users.csv"),
      key = "user",
      count = "count",
      data = stats.users,
    },
    {
      path = csv.temp_path(base .. "warnings.csv"),
      key = "warning",
      count = "count",
      data = stats.warnings,
    },
  }

  local lines = {
    "OPC UA CSV export",
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
    "ICS Visibility OPC UA CSV Export",
    table.concat(lines, "\n")
  )
end

local function show_summary()
  local win = windows.show_text("ICS Visibility OPC UA", build_summary())

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

  tap = Listener.new(nil, "opcua")

  function tap.packet()
    on_packet()
  end

  function tap.reset()
    stats = new_stats()
  end

  function tap.draw()
  end

  register_menu(
    "ICS Visibility/OPC UA/Summary",
    show_summary,
    MENU_TOOLS_UNSORTED
  )
end

return M