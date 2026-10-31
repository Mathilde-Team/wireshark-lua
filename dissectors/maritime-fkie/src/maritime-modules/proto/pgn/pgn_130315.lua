-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_130315.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_130315 = Proto("nmea-2000-130315", "Set Pressure (130315)")
local sid = ProtoField.uint8("nmea-2000-130315.sid", "SID")
local instance = ProtoField.uint8("nmea-2000-130315.instance", "Instance")
local source = ProtoField.uint8("nmea-2000-130315.source", "Source", base.DEC, NULL, 0xff)
local pressure = ProtoField.float("nmea-2000-130315.pressure", "Pressure (Pa)")

NMEA_2000_130315.fields = {sid,instance,source,pressure}

function NMEA_2000_130315.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 130315 (Set Pressure)"
    local subtree = tree:add(NMEA_2000_130315, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(sid, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(instance, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 2 + 1) then
        subtree:add(source, buffer(str_offset + 2, 1))
    end
    if buffer:len() >= (str_offset + 3 + 4) then
        subtree:add(pressure, buffer(str_offset + 3, 4), buffer(str_offset + 3, 4):le_int() * 0.1)
    end
end

return NMEA_2000_130315
