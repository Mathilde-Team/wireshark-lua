-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_130580.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_130580 = Proto("nmea-2000-130580", "System Configuration (deprecated) (130580)")
local power = ProtoField.uint8("nmea-2000-130580.power", "Power", base.DEC, NULL, 0x3)
local defaultSettings = ProtoField.uint8("nmea-2000-130580.defaultSettings", "Default Settings", base.DEC, NULL, 0xc)
local tunerRegions = ProtoField.uint8("nmea-2000-130580.tunerRegions", "Tuner regions", base.DEC, NULL, 0xf0)
local maxFavorites = ProtoField.uint8("nmea-2000-130580.maxFavorites", "Max favorites")

NMEA_2000_130580.fields = {power,defaultSettings,tunerRegions,maxFavorites}

function NMEA_2000_130580.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 130580 (System Configuration (deprecated))"
    local subtree = tree:add(NMEA_2000_130580, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        subtree:add(power, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1) then
        subtree:add(defaultSettings, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1) then
        subtree:add(tunerRegions, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 1) then
        subtree:add(maxFavorites, buffer(str_offset + 1, 1))
    end
end

return NMEA_2000_130580
