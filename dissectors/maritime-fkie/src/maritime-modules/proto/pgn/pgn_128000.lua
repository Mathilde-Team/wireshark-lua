-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_128000.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_128000 = Proto("nmea-2000-128000", "Leeway Angle (128000)")
local sid = ProtoField.uint8("nmea-2000-128000.sid", "SID")
local leewayAngle = ProtoField.float("nmea-2000-128000.leewayAngle", "Leeway Angle (rad)")

NMEA_2000_128000.fields = {sid,leewayAngle}

function NMEA_2000_128000.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 128000 (Leeway Angle)"
    local subtree = tree:add(NMEA_2000_128000, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(sid, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 2) then
        subtree:add(leewayAngle, buffer(str_offset + 1, 2), buffer(str_offset + 1, 2):le_int() * 0.0001)
    end
end

return NMEA_2000_128000
