-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/eldarkg/lineage2wireshark (common/protoexperts.lua),
-- commit 44762d9fa378b5f0b23d5346dfbd854fc5c5eb41 du 19/10/2025.
-- Licence amont : GPL-3.0 (LICENSE amont) — voir README.md.

--[[
    License: GPL3
    Author: Eldar Khayrullin
    Email: eldar.khayrullin@mail.ru
    Date: 2024
    Description: Proto Experts
]]--

---Workaround: skip 1st pass without root path
if not package.searchpath("common.protoexperts", package.path) then
    return
end

local _M = {}

---@param name string
---@return table
function _M.init(name)
    return {
        undecoded = ProtoExpert.new(name .. ".undecoded",
                                    "Decode error",
                                    expert.group.UNDECODED,
                                    expert.severity.ERROR),

        unk_opcode = ProtoExpert.new(name .. ".unknown_opcode",
                                     "Unknown Opcode",
                                     expert.group.UNDECODED,
                                     expert.severity.ERROR),
    }
end

return _M