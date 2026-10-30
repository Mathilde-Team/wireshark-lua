-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_127490.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_127490 = Proto("nmea-2000-127490", "Electric Drive Status, Dynamic (127490)")
local inverterMotorIdentifier = ProtoField.uint8("nmea-2000-127490.inverterMotorIdentifier", "Inverter/Motor Identifier")
local operatingMode = ProtoField.uint32("nmea-2000-127490.operatingMode", "Operating Mode")
local motorTemperature = ProtoField.float("nmea-2000-127490.motorTemperature", "Motor Temperature (K)")
local inverterTemperature = ProtoField.float("nmea-2000-127490.inverterTemperature", "Inverter Temperature (K)")
local coolantTemperature = ProtoField.float("nmea-2000-127490.coolantTemperature", "Coolant Temperature (K)")
local gearTemperature = ProtoField.float("nmea-2000-127490.gearTemperature", "Gear Temperature (K)")
local shaftTorque = ProtoField.uint16("nmea-2000-127490.shaftTorque", "Shaft Torque")

NMEA_2000_127490.fields = {inverterMotorIdentifier,operatingMode,motorTemperature,inverterTemperature,coolantTemperature,gearTemperature,shaftTorque}

function NMEA_2000_127490.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 127490 (Electric Drive Status, Dynamic)"
    local subtree = tree:add(NMEA_2000_127490, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(inverterMotorIdentifier, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        local _rng = buffer(str_offset + 1, 1)
        local _raw = _rng:le_uint()
        local _val = math.floor(_raw / (2 ^ 0)) % (2 ^ 4)
        subtree:add(operatingMode, _rng, _val)
    end
    if buffer:len() >= (str_offset + 2 + 2) then
        subtree:add(motorTemperature, buffer(str_offset + 2, 2), buffer(str_offset + 2, 2):le_uint() * 0.01)
    end
    if buffer:len() >= (str_offset + 4 + 2) then
        subtree:add(inverterTemperature, buffer(str_offset + 4, 2), buffer(str_offset + 4, 2):le_uint() * 0.01)
    end
    if buffer:len() >= (str_offset + 6 + 2) then
        subtree:add(coolantTemperature, buffer(str_offset + 6, 2), buffer(str_offset + 6, 2):le_uint() * 0.01)
    end
    if buffer:len() >= (str_offset + 8 + 2) then
        subtree:add(gearTemperature, buffer(str_offset + 8, 2), buffer(str_offset + 8, 2):le_uint() * 0.01)
    end
    if buffer:len() >= (str_offset + 10 + 2) then
        subtree:add_le(shaftTorque, buffer(str_offset + 10, 2))
    end
end

return NMEA_2000_127490
