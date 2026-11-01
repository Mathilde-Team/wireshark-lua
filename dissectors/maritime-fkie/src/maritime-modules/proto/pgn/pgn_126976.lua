-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_126976.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_126976 = Proto("nmea-2000-126976", "0x1F000-0x1FEFF: Standardized mixed single/fast packet non-addressed (126976)")
local data = ProtoField.bytes("nmea-2000-126976.data", "Data")

NMEA_2000_126976.fields = {data}

function NMEA_2000_126976.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 126976 (0x1F000-0x1FEFF: Standardized mixed single/fast packet non-addressed)"
    local subtree = tree:add(NMEA_2000_126976, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 223) then
        subtree:add(data, buffer(str_offset, 223))
    end
end

return NMEA_2000_126976
