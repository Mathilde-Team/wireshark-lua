-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/smash64-dev/kaillera-dissector (okai.lua),
-- commit 96e5fc77a1aa29510b24394144d0820541e85488 du 01/05/2021.
-- Licence amont : MIT (fichier LICENSE, « Copyright (c) 2021 Smash64 Development ») — voir README.md.

-- okai.lua
-- http://p2p.okai.ru/

require "constants"
local Message = require "lib.message"

OKAI_PROTOCOL = "Okai"
OKAI_DESCRIPTION = "Open Kaillera Protocol"

local okai = Proto(string.lower(OKAI_PROTOCOL), OKAI_DESCRIPTION)
okai.fields = {}
local fields = okai.fields

-- typed messages
fields.msg_count    = ProtoField.uint8("okai.cnt", "Messages")
fields.msg_id       = ProtoField.uint8("okai.id", "Message ID")
fields.msg_length   = ProtoField.uint8("okai.len", "Length")
fields.msg_type     = ProtoField.uint8("okai.type", "Type", base.HEX, Message.static:buildMessageTypes(OKAI_TYPES))

-- generated fields
for message, proto in pairs(Message.static:buildProtoFields(OKAI_TYPES, OKAI_PROTOCOL)) do
    fields[message] = proto
end

local function login_request_heuristic(tvb, pinfo, tree)
    local message = tvb():range(0, 4):bytes()
    local client_request = ByteArray.new("0100a100")
    local server_accept = ByteArray.new("0100a110")

    if message == client_request then
        DissectorTable.get("udp.port"):add(pinfo.src_port, okai)
        DissectorTable.get("udp.port"):add(pinfo.dst_port, okai)
        -- only mark this as open kaillera on server accept
        return true
    end

    if message == server_accept then
        DissectorTable.get("udp.port"):add(server_accept, okai)
        return true
    end

    return false
end

function okai.dissector(tvb, pinfo, tree)
    pinfo.cols.protocol = OKAI_PROTOCOL
    local payload = tree:add(okai, tvb())

    local count = tvb:range(0,1)
    local messages = payload:add_le(fields.msg_count, count)

    local offset = 1
    for i = 1, count:int() do
        local message = messages:add_le(fields.msg_id, tvb:range(offset, 1))
        local len = tvb:range(offset + 1, 1)
        message:add_le(fields.msg_length, len)

        local type = tvb:range(offset + 2, 1)
        local data = message:add_le(fields.msg_type, type)
        local messageType = OKAI_TYPES[type:int()]

        if messageType then
            messageType.protocol = OKAI_PROTOCOL
            messageType:dissect(okai.fields, tvb:range(offset + 2, len:le_uint()), data)
            message:set_len(len:le_uint() + 2)
        end

        offset = offset + 2 + len:le_uint()
    end
end

-- autodetect open kaillera messages
okai:register_heuristic("udp", login_request_heuristic)
