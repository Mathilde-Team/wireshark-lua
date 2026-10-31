-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_129291.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_129291 = Proto("nmea-2000-129291", "Set & Drift, Rapid Update (129291)")
local sid = ProtoField.uint8("nmea-2000-129291.sid", "SID")
local setReference = ProtoField.uint8("nmea-2000-129291.setReference", "Set Reference", base.DEC, NULL, 0x3)
local set = ProtoField.float("nmea-2000-129291.set", "Set (rad)")
local drift = ProtoField.float("nmea-2000-129291.drift", "Drift (m/s)")

NMEA_2000_129291.fields = {sid,setReference,set,drift}

function NMEA_2000_129291.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 129291 (Set & Drift, Rapid Update)"
    local subtree = tree:add(NMEA_2000_129291, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(sid, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(setReference, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 2 + 2) then
        subtree:add(set, buffer(str_offset + 2, 2), buffer(str_offset + 2, 2):le_uint() * 0.0001)
    end
    if buffer:len() >= (str_offset + 4 + 2) then
        subtree:add(drift, buffer(str_offset + 4, 2), buffer(str_offset + 4, 2):le_uint() * 0.01)
    end
end

return NMEA_2000_129291
