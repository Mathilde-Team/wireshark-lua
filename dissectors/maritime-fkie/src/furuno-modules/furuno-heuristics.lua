-- SPDX-License-Identifier: LicenseRef-FKIE-MIT-supplemented
-- Importé de https://github.com/fkie-cad/maritime-dissector,
-- commit 8fdd466580ef6279971a9090c542284ea7959869 du 24/03/2026 (furuno-modules/furuno-heuristics.lua).
-- Licence amont : MIT complétée par Fraunhofer FKIE (LICENSE amont) — voir README.md.

-- prevent wireshark loading this file as plugin
if not _G['furuno-dissector'] then return end

local proto_img = require "furuno-modules.furuno-img"

local function img_checker(buffer, pinfo, tree)
    local msgid = buffer(0, 1):uint()           -- Message type? 
    local furuno_marker = buffer(2, 6):uint64() -- Furuno specific Tag?
    -- For now, we only support message type 2 here
    if furuno_marker ~= UInt64(0x00000000, 0x00000001) or msgid ~= 0x2 or pinfo.dst_port ~= 10024 then return false end

    proto_img.dissector(buffer, pinfo, tree)
    return true
end

local heuristics = {
    img_checker = img_checker,
}

return heuristics
