-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_129283.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_129283 = Proto("nmea-2000-129283", "Cross Track Error (129283)")
local sid = ProtoField.uint8("nmea-2000-129283.sid", "SID")
local xteMode = ProtoField.uint8("nmea-2000-129283.xteMode", "XTE mode", base.DEC, NULL, 0xf)
local navigationTerminated = ProtoField.uint8("nmea-2000-129283.navigationTerminated", "Navigation Terminated", base.DEC, NULL, 0xc0)
local xte = ProtoField.float("nmea-2000-129283.xte", "XTE (m)")

NMEA_2000_129283.fields = {sid,xteMode,navigationTerminated,xte}

function NMEA_2000_129283.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 129283 (Cross Track Error)"
    local subtree = tree:add(NMEA_2000_129283, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(sid, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(xteMode, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(navigationTerminated, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 2 + 4) then
        subtree:add(xte, buffer(str_offset + 2, 4), buffer(str_offset + 2, 4):le_int() * 0.01)
    end
end

return NMEA_2000_129283
