-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_130850.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_130850 = Proto("nmea-2000-130850", "Simnet: Event (130850)")
local manufacturerCode = ProtoField.uint32("nmea-2000-130850.manufacturerCode", "Manufacturer Code")
local industryCode = ProtoField.uint8("nmea-2000-130850.industryCode", "Industry Code", base.DEC, NULL, 0xe0)
local address = ProtoField.uint8("nmea-2000-130850.address", "Address")
local proprietaryId = ProtoField.uint8("nmea-2000-130850.proprietaryId", "Proprietary ID", base.DEC, NULL, 0xff)

NMEA_2000_130850.fields = {manufacturerCode,industryCode,address,proprietaryId}

function NMEA_2000_130850.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 130850 (Simnet: Event)"
    local subtree = tree:add(NMEA_2000_130850, buffer(), subtree_title)
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
    if buffer:len() >= (str_offset + 2 + 1) then
        subtree:add(address, buffer(str_offset + 2, 1))
    end
    if buffer:len() >= (str_offset + 4 + 1) then
        subtree:add(proprietaryId, buffer(str_offset + 4, 1))
    end
end

return NMEA_2000_130850
