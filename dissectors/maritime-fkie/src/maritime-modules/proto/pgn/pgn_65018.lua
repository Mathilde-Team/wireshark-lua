-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_65018.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_65018 = Proto("nmea-2000-65018", "Generator Total AC Energy (65018)")
local totalEnergyExport = ProtoField.uint32("nmea-2000-65018.totalEnergyExport", "Total Energy Export (kWh)")
local totalEnergyImport = ProtoField.uint32("nmea-2000-65018.totalEnergyImport", "Total Energy Import (kWh)")

NMEA_2000_65018.fields = {totalEnergyExport,totalEnergyImport}

function NMEA_2000_65018.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 65018 (Generator Total AC Energy)"
    local subtree = tree:add(NMEA_2000_65018, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 4) then
        subtree:add_le(totalEnergyExport, buffer(str_offset, 4))
    end
    if buffer:len() >= (str_offset + 4 + 4) then
        subtree:add_le(totalEnergyImport, buffer(str_offset + 4, 4))
    end
end

return NMEA_2000_65018
