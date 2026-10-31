-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_128780.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_128780 = Proto("nmea-2000-128780", "Linear Actuator Control/Status (128780)")
local actuatorIdentifier = ProtoField.uint8("nmea-2000-128780.actuatorIdentifier", "Actuator Identifier")
local commandedDevicePosition = ProtoField.uint8("nmea-2000-128780.commandedDevicePosition", "Commanded Device Position")
local devicePosition = ProtoField.uint8("nmea-2000-128780.devicePosition", "Device Position")
local maximumDeviceTravel = ProtoField.uint16("nmea-2000-128780.maximumDeviceTravel", "Maximum Device Travel")
local directionOfTravel = ProtoField.uint8("nmea-2000-128780.directionOfTravel", "Direction of Travel")

NMEA_2000_128780.fields = {actuatorIdentifier,commandedDevicePosition,devicePosition,maximumDeviceTravel,directionOfTravel}

function NMEA_2000_128780.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 128780 (Linear Actuator Control/Status)"
    local subtree = tree:add(NMEA_2000_128780, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(actuatorIdentifier, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(commandedDevicePosition, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 2 + 1) then
        subtree:add(devicePosition, buffer(str_offset + 2, 1))
    end
    if buffer:len() >= (str_offset + 3 + 2) then
        subtree:add_le(maximumDeviceTravel, buffer(str_offset + 3, 2))
    end
    if buffer:len() >= (str_offset + 5 + 1) then
        subtree:add(directionOfTravel, buffer(str_offset + 5, 1))
    end
end

return NMEA_2000_128780
