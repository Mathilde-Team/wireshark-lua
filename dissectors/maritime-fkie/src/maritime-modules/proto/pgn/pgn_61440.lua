-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_61440.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_61440 = Proto("nmea-2000-61440", "0xF000-0xFEFF: Standardized single-frame non-addressed (61440)")
local manufacturerCode = ProtoField.uint32("nmea-2000-61440.manufacturerCode", "Manufacturer Code")
local industryCode = ProtoField.uint8("nmea-2000-61440.industryCode", "Industry Code", base.DEC, NULL, 0xe0)
local data = ProtoField.bytes("nmea-2000-61440.data", "Data")

NMEA_2000_61440.fields = {manufacturerCode,industryCode,data}

function NMEA_2000_61440.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 61440 (0xF000-0xFEFF: Standardized single-frame non-addressed)"
    local subtree = tree:add(NMEA_2000_61440, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 2) then
        local _rng = buffer(str_offset, 2)
        local _raw = _rng:le_uint()
        local _val = math.floor(_raw / (2 ^ 0)) % (2 ^ 11)
        subtree:add(manufacturerCode, _rng, _val)
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(industryCode, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 2 + 6) then
        subtree:add(data, buffer(str_offset + 2, 6))
    end
end

return NMEA_2000_61440
