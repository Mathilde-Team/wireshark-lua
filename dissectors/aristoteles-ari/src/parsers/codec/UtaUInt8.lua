-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/seemoo-lab/aristoteles,
-- commit 25cb9bb5c35993ed0c74248b96f0065d5479f447 du 30/09/2026.
-- Licence amont : MIT (LICENSE amont) — voir README.md.
PARSER = {}

PARSER.codec_name = "UtaUInt8"

-- Has to be a local field, to access it in the parser method
local fields = {
    utauint8_value = ProtoField.uint16("ari.utauint8.value", "UtaUInt8 value", base.DEC),
}

PARSER.fields = fields

-- Amount of bytes this data format is capable of / encoded in.
PARSER.length = 1

function PARSER.parse(packet, tlv_tree, cur_tlv_data_byte, tlv_data_tvb, extra_information)
    local num = tlv_data_tvb:le_uint()

    tlv_tree:add(fields.utauint8_value, tlv_data_tvb, num, "Value: " .. num)

    return true
end
