-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_129027.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_129027 = Proto("nmea-2000-129027", "Position Delta, Rapid Update (129027)")
local sid = ProtoField.uint8("nmea-2000-129027.sid", "SID")
local timeDelta = ProtoField.float("nmea-2000-129027.timeDelta", "Time Delta (s)")
local latitudeDelta = ProtoField.float("nmea-2000-129027.latitudeDelta", "Latitude Delta (deg)")
local longitudeDelta = ProtoField.float("nmea-2000-129027.longitudeDelta", "Longitude Delta (deg)")

NMEA_2000_129027.fields = {sid,timeDelta,latitudeDelta,longitudeDelta}

function NMEA_2000_129027.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 129027 (Position Delta, Rapid Update)"
    local subtree = tree:add(NMEA_2000_129027, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(sid, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(timeDelta, buffer(str_offset + 1, 1), buffer(str_offset + 1, 1):le_uint() * 0.005)
    end
    if buffer:len() >= (str_offset + 2 + 3) then
        subtree:add(latitudeDelta, buffer(str_offset + 2, 3), buffer(str_offset + 2, 3):le_int() * 2.77778e-09)
    end
    if buffer:len() >= (str_offset + 5 + 3) then
        subtree:add(longitudeDelta, buffer(str_offset + 5, 3), buffer(str_offset + 5, 3):le_int() * 2.77778e-09)
    end
end

return NMEA_2000_129027
