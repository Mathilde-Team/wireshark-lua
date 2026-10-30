-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (maritime-modules/proto/pgn/pgn_127505.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['maritimedissector'] then return end

-- WARNING: This file is generated automatically by ./pgn.py --

NMEA_2000_127505 = Proto("nmea-2000-127505", "Fluid Level (127505)")
local instance = ProtoField.uint32("nmea-2000-127505.instance", "Instance")
local type = ProtoField.uint8("nmea-2000-127505.type", "Type", base.DEC, NULL, 0xf0)
local level = ProtoField.float("nmea-2000-127505.level", "Level (%)")
local capacity = ProtoField.float("nmea-2000-127505.capacity", "Capacity (L)")

NMEA_2000_127505.fields = {instance,type,level,capacity}

function NMEA_2000_127505.dissector(buffer, pinfo, tree)
    local subtree_title = "PGN 127505 (Fluid Level)"
    local subtree = tree:add(NMEA_2000_127505, buffer(), subtree_title)
    local str_offset = 0

    if buffer:len() >= (str_offset + 1) then
        local _rng = buffer(str_offset, 1)
        local _raw = _rng:le_uint()
        local _val = math.floor(_raw / (2 ^ 0)) % (2 ^ 4)
        subtree:add(instance, _rng, _val)
    end
    if buffer:len() >= (str_offset + 1) then
        subtree:add(type, buffer(str_offset, 1))
    end
    if buffer:len() >= (str_offset + 1 + 2) then
        subtree:add(level, buffer(str_offset + 1, 2), buffer(str_offset + 1, 2):le_int() * 0.004)
    end
    if buffer:len() >= (str_offset + 3 + 4) then
        subtree:add(capacity, buffer(str_offset + 3, 4), buffer(str_offset + 3, 4):le_uint() * 0.1)
    end
end

return NMEA_2000_127505
