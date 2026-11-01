-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_127748.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_127748 = Proto("nmea-2000-127748", "AC Voltage / Frequency - Phase B (127748)")
local sid = ProtoField.uint8("nmea-2000-127748.sid", "SID")
local connectionNumber = ProtoField.uint8("nmea-2000-127748.connectionNumber", "Connection Number")
local acVoltageLineToNeutral = ProtoField.float("nmea-2000-127748.acVoltageLineToNeutral", "AC Voltage Line to Neutral (V)")
local acVoltageLineToLine = ProtoField.float("nmea-2000-127748.acVoltageLineToLine", "AC Voltage Line to Line (V)")
local frequency = ProtoField.float("nmea-2000-127748.frequency", "Frequency (Hz)")

NMEA_2000_127748.fields = {sid,connectionNumber,acVoltageLineToNeutral,acVoltageLineToLine,frequency}

function NMEA_2000_127748.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 127748 (AC Voltage / Frequency - Phase B)"
    local subtree = tree:add(NMEA_2000_127748, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(sid, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(connectionNumber, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 2 + 2) then
        subtree:add(acVoltageLineToNeutral, buffer(str_offset + 2, 2), buffer(str_offset + 2, 2):le_uint() * 0.1)
    end
    if buffer:len() >= (str_offset + 4 + 2) then
        subtree:add(acVoltageLineToLine, buffer(str_offset + 4, 2), buffer(str_offset + 4, 2):le_uint() * 0.1)
    end
    if buffer:len() >= (str_offset + 6 + 2) then
        subtree:add(frequency, buffer(str_offset + 6, 2), buffer(str_offset + 6, 2):le_uint() * 0.1)
    end
end

return NMEA_2000_127748
