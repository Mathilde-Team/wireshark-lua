-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_126992.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_126992 = Proto("nmea-2000-126992", "System Time (126992)")
local sid = ProtoField.uint8("nmea-2000-126992.sid", "SID")
local source = ProtoField.uint8("nmea-2000-126992.source", "Source", base.DEC, NULL, 0xf)
local date = ProtoField.uint16("nmea-2000-126992.date", "Date (d)")
local time = ProtoField.float("nmea-2000-126992.time", "Time (s)")

NMEA_2000_126992.fields = {sid,source,date,time}

function NMEA_2000_126992.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 126992 (System Time)"
    local subtree = tree:add(NMEA_2000_126992, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(sid, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(source, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 2 + 2) then
        subtree:add_le(date, buffer(str_offset + 2, 2))
    end
    if buffer:len() >= (str_offset + 4 + 4) then
        subtree:add(time, buffer(str_offset + 4, 4), buffer(str_offset + 4, 4):le_uint() * 0.0001)
    end
end

return NMEA_2000_126992
