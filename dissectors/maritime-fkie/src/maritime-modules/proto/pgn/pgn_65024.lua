-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_65024.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_65024 = Proto("nmea-2000-65024", "Generator Phase B Basic AC Quantities (65024)")
local lineLineAcRmsVoltage = ProtoField.uint16("nmea-2000-65024.lineLineAcRmsVoltage", "Line-Line AC RMS Voltage (V)")
local lineNeutralAcRmsVoltage = ProtoField.uint16("nmea-2000-65024.lineNeutralAcRmsVoltage", "Line-Neutral AC RMS Voltage (V)")
local acFrequency = ProtoField.float("nmea-2000-65024.acFrequency", "AC Frequency (Hz)")
local acRmsCurrent = ProtoField.uint16("nmea-2000-65024.acRmsCurrent", "AC RMS Current (A)")

NMEA_2000_65024.fields = {lineLineAcRmsVoltage,lineNeutralAcRmsVoltage,acFrequency,acRmsCurrent}

function NMEA_2000_65024.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 65024 (Generator Phase B Basic AC Quantities)"
    local subtree = tree:add(NMEA_2000_65024, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 2) then
        subtree:add_le(lineLineAcRmsVoltage, buffer(str_offset, 2))
    end
    if buffer:len() >= (str_offset + 2 + 2) then
        subtree:add_le(lineNeutralAcRmsVoltage, buffer(str_offset + 2, 2))
    end
    if buffer:len() >= (str_offset + 4 + 2) then
        subtree:add(acFrequency, buffer(str_offset + 4, 2), buffer(str_offset + 4, 2):le_uint() * 0.0078125)
    end
    if buffer:len() >= (str_offset + 6 + 2) then
        subtree:add_le(acRmsCurrent, buffer(str_offset + 6, 2))
    end
end

return NMEA_2000_65024
