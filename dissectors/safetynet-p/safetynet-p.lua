-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/GalloClaudio64/Safetynet-P (safetynet-p.lua),
-- commit 10e3b01b50085ba64dd73a2e1bfdfcea3564d264 du 31/03/2023.
-- Licence amont : GPL-3.0 (LICENSE amont, sans mention « or later ») — voir README.md.
-- Protocol name: Safetynet-P
safetynet_p_proto = Proto("Safetynet-P","Safetynet-P Protocol")

-- create a table to store fields
local fields = safetynet_p_proto.fields

-- define the fields
fields.magic = ProtoField.uint32("safetynet_p.magic", "Magic", base.HEX)
fields.version = ProtoField.uint16("safetynet_p.version", "Version", base.DEC)
fields.type = ProtoField.uint16("safetynet_p.type", "Type", base.DEC)
fields.length = ProtoField.uint32("safetynet_p.length", "Length", base.DEC)
fields.id = ProtoField.uint32("safetynet_p.id", "ID", base.DEC)
fields.payload = ProtoField.string("safetynet_p.payload", "Payload")

-- dissect function
function safetynet_p_proto.dissector(buffer,pinfo,tree)
    pinfo.cols.protocol = "Safetynet-P"

    -- create subtree for Safetynet-P protocol
    local subtree = tree:add(safetynet_p_proto,buffer())

    -- check buffer length
    if buffer:len() < 18 then
        -- buffer is too short, so this is not a valid Safetynet-P packet
        return
    end

    -- add the fields to the subtree
    subtree:add(fields.magic, buffer(0,4))
    subtree:add(fields.version, buffer(4,2))
    subtree:add(fields.type, buffer(6,2))
    subtree:add(fields.length, buffer(8,4))
    subtree:add(fields.id, buffer(12,4))

    -- check if the payload field exists
    if buffer:len() > 16 then
        -- add the payload field to the subtree
        subtree:add(fields.payload, buffer(16))
    end
end

-- load the udp.port table
udp_table = DissectorTable.get("udp.port")

-- register our protocol to handle udp port 40000
udp_table:add(40000,safetynet_p_proto)
