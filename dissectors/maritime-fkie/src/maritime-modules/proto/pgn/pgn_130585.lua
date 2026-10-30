-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_130585.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_130585 = Proto("nmea-2000-130585", "Bluetooth source status (130585)")
local sourceNumber = ProtoField.uint8("nmea-2000-130585.sourceNumber", "Source number")
local status = ProtoField.uint8("nmea-2000-130585.status", "Status", base.DEC, NULL, 0xf)
local forgetDevice = ProtoField.uint8("nmea-2000-130585.forgetDevice", "Forget device", base.DEC, NULL, 0x30)
local discovering = ProtoField.uint8("nmea-2000-130585.discovering", "Discovering", base.DEC, NULL, 0xc0)
local bluetoothAddress = ProtoField.bytes("nmea-2000-130585.bluetoothAddress", "Bluetooth address")

NMEA_2000_130585.fields = {sourceNumber,status,forgetDevice,discovering,bluetoothAddress}

function NMEA_2000_130585.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 130585 (Bluetooth source status)"
    local subtree = tree:add(NMEA_2000_130585, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(sourceNumber, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(status, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(forgetDevice, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(discovering, buffer(str_offset + 1, 1))
    end
    if buffer:len() >= (str_offset + 2 + 6) then
        subtree:add(bluetoothAddress, buffer(str_offset + 2, 6))
    end
end

return NMEA_2000_130585
