-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_65016.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_65016 = Proto("nmea-2000-65016", "Utility Total AC Power (65016)")
local realPower = ProtoField.int32("nmea-2000-65016.realPower", "Real Power (W)")
local apparentPower = ProtoField.int32("nmea-2000-65016.apparentPower", "Apparent Power (VA)")

NMEA_2000_65016.fields = {realPower,apparentPower}

function NMEA_2000_65016.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 65016 (Utility Total AC Power)"
    local subtree = tree:add(NMEA_2000_65016, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 4) then
        subtree:add_le(realPower, buffer(str_offset, 4))
    end
    if buffer:len() >= (str_offset + 4 + 4) then
        subtree:add_le(apparentPower, buffer(str_offset + 4, 4))
    end
end

return NMEA_2000_65016
