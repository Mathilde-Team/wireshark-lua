-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_128267.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_128267 = Proto("nmea-2000-128267", "Water Depth (128267)")
local sid = ProtoField.uint8("nmea-2000-128267.sid", "SID")
local depth = ProtoField.float("nmea-2000-128267.depth", "Depth (m)")
local offset = ProtoField.float("nmea-2000-128267.offset", "Offset (m)")
local range = ProtoField.float("nmea-2000-128267.range", "Range (m)")

NMEA_2000_128267.fields = {sid,depth,offset,range}

function NMEA_2000_128267.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 128267 (Water Depth)"
    local subtree = tree:add(NMEA_2000_128267, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(sid, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 4) then
        subtree:add(depth, buffer(str_offset + 1, 4), buffer(str_offset + 1, 4):le_uint() * 0.01)
    end
    if buffer:len() >= (str_offset + 5 + 2) then
        subtree:add(offset, buffer(str_offset + 5, 2), buffer(str_offset + 5, 2):le_int() * 0.001)
    end
    if buffer:len() >= (str_offset + 7 + 1) then
        subtree:add(range, buffer(str_offset + 7, 1), buffer(str_offset + 7, 1):le_uint() * 10)
    end
end

return NMEA_2000_128267
