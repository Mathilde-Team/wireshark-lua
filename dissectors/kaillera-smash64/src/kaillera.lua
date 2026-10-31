-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/smash64-dev/kaillera-dissector (kaillera.lua),
-- commit 96e5fc77a1aa29510b24394144d0820541e85488 du 01/05/2021.
-- Licence amont : MIT (fichier LICENSE, « Copyright (c) 2021 Smash64 Development ») — voir README.md.

-- kaillera.lua
-- http://kaillera.com/

require "constants"
local Message = require "lib.message"

KAILLERA_PROTOCOL = "Kaillera"
KAILLERA_DESCRIPTION = "Kaillera Middleware Protocol"

local kaillera = Proto(string.lower(KAILLERA_PROTOCOL), KAILLERA_DESCRIPTION)
kaillera.fields = {}
local fields = kaillera.fields

-- raw messages
fields.client_hello = ProtoField.stringz("kaillera.client_hello", "Client")
fields.client_ping  = ProtoField.stringz("kaillera.client_ping", "Client")
fields.server_hello = ProtoField.stringz("kaillera.server_hello", "Server")
fields.server_pong  = ProtoField.stringz("kaillera.server_pong", "Server")
fields.server_port  = ProtoField.stringz("kaillera.server_port", "Port")

-- typed messages
fields.msg_count    = ProtoField.uint8("kaillera.cnt", "Messages")
fields.msg_id       = ProtoField.uint16("kaillera.id", "Message ID")
fields.msg_length   = ProtoField.uint16("kaillera.len", "Length")
fields.msg_type     = ProtoField.uint8("kaillera.type", "Type", base.HEX, Message.static:buildMessageTypes(KAILLERA_TYPES))

-- generated fields
for message, proto in pairs(Message.static:buildProtoFields(KAILLERA_TYPES, KAILLERA_PROTOCOL)) do
    fields[message] = proto
end

local function hello_dood_heuristic(tvb, pinfo, tree)
    local message = tvb():range():stringz()
    local client_hello = string.match(message, KAILLERA_RAW.client_hello)
    local server_hello = string.match(message, KAILLERA_RAW.server_hello)

    if client_hello then
        DissectorTable.get("udp.port"):add(pinfo.src_port, kaillera)
        DissectorTable.get("udp.port"):add(pinfo.dst_port, kaillera)
        tree:add_le(fields.client_hello, message)
        -- only mark this as kaillera on server hello
        return false
    end

    if server_hello then
        DissectorTable.get("udp.port"):add(server_hello, kaillera)
        tree:add_le(fields.server_hello, message)
        tree:add_le(fields.server_port, server_hello)
        return true
    end

    -- handle excess raw messages too (ping/pong)
    if string.match(message, KAILLERA_RAW.client_ping) then tree:add_le(fields.client_ping, message) end
    if string.match(message, KAILLERA_RAW.server_pong) then tree:add_le(fields.server_pong, message) end
    return false
end

local function origin_heuristic(field)
    local client = field.client == 0 and field.value:bytes() == ByteArray.new("00")
    local server = field.server == 0 and field.value:bytes() == ByteArray.new("00")

    if client and not server then return "client" end
    if server and not client then return "server" end
    return "unknown"
end

function kaillera.dissector(tvb, pinfo, tree)
    pinfo.cols.protocol = KAILLERA_PROTOCOL
    local payload = tree:add(kaillera, tvb())

    -- handle raw messages
    for _, message in pairs(KAILLERA_RAW) do
        if string.match(tvb():range():stringz(), message) then
            hello_dood_heuristic(tvb, pinfo, payload)
            return true
        end
    end

    local count = tvb:range(0,1)
    local messages = payload:add_le(fields.msg_count, count)

    local offset = 1
    for i = 1, count:int() do
        local message = messages:add_le(fields.msg_id, tvb:range(offset, 2))
        local len = tvb:range(offset + 2, 2)
        message:add_le(fields.msg_length, len)

        local type = tvb:range(offset + 4, 1)
        local data = message:add_le(fields.msg_type, type)
        local messageType = KAILLERA_TYPES[type:int()]

        if messageType then
            messageType.protocol = KAILLERA_PROTOCOL
            messageType.isOrigin = origin_heuristic

            messageType:dissect(kaillera.fields, tvb:range(offset + 4, len:le_uint()), data)
            message:set_len(len:le_uint() + 4)
        end

        offset = offset + 4 + len:le_uint()
    end
end

-- autodetect kaillera middleware messages
kaillera:register_heuristic("udp", hello_dood_heuristic)
