-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_127488.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_127488 = Proto("nmea-2000-127488", "Engine Parameters, Rapid Update (127488)")
local instance = ProtoField.uint8("nmea-2000-127488.instance", "Instance", base.DEC, NULL, 0xff)
local speed = ProtoField.float("nmea-2000-127488.speed", "Speed (rpm)")
local boostPressure = ProtoField.float("nmea-2000-127488.boostPressure", "Boost Pressure (Pa)")
local tiltTrim = ProtoField.int8("nmea-2000-127488.tiltTrim", "Tilt/Trim (%)")

NMEA_2000_127488.fields = {instance,speed,boostPressure,tiltTrim}

function NMEA_2000_127488.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 127488 (Engine Parameters, Rapid Update)"
    local subtree = tree:add(NMEA_2000_127488, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(instance, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 2) then
        subtree:add(speed, buffer(str_offset + 1, 2), buffer(str_offset + 1, 2):le_uint() * 0.25)
    end
    if buffer:len() >= (str_offset + 3 + 2) then
        subtree:add(boostPressure, buffer(str_offset + 3, 2), buffer(str_offset + 3, 2):le_uint() * 100)
    end
    if buffer:len() >= (str_offset + 5 + 1) then
        subtree:add(tiltTrim, buffer(str_offset + 5, 1))
    end
end

return NMEA_2000_127488
