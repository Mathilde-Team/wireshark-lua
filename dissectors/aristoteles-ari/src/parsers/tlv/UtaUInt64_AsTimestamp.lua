-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/seemoo-lab/aristoteles,
-- commit 25cb9bb5c35993ed0c74248b96f0065d5479f447 du 30/09/2026.
-- Licence amont : MIT (LICENSE amont) — voir README.md.
PARSER = {}

PARSER.group_id = 1
PARSER.type_id = 526
PARSER.tlv_id = 1

-- Has to be a local field, to access it in the parser method
local fields = {
    utauint64_astimestamp_field = ProtoField.uint16("ari.utauint64_astimestamp", "UtaUInt64 as Timestamp", base.DEC),
}

PARSER.fields = fields

function PARSER.parse(packet, tlv_tree, cur_tlv_data_byte, tlv_data_tvb, extra_information)
    local buffer = packet.buffer

    local timestamp = buffer(cur_tlv_data_byte, 6):le_uint64()
    -- TODO: Last 2 bytes may be timezone offset (?)
    local time_str = "Time: " .. os.date("%Y-%m-%d %H:%M:%S", timestamp:tonumber() / 1000) .. "." .. timestamp:tonumber() % 1000
    tlv_tree:add(fields.utauint64_astimestamp_field, buffer(cur_tlv_data_byte, 6), timestamp:tonumber(), time_str)

    return true
end
