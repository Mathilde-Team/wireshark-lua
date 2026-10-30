-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/eldarkg/lineage2wireshark (decrypt/rsa.lua),
-- commit 44762d9fa378b5f0b23d5346dfbd854fc5c5eb41 du 19/10/2025.
-- Licence amont : GPL-3.0 (LICENSE amont) — voir README.md.

--[[
    License: GPL3
    Author: Eldar Khayrullin
    Email: eldar.khayrullin@mail.ru
    Date: 2024-2025
    Description: RSA
]]--

local _M = {}

---@param mod ByteArray
---@return ByteArray unscrambled
function _M.unscramble_mod(mod)
    for i = 0, 63, 1 do
        local xor = mod:get_index(0x40 + i) ~ mod:get_index(i)
        mod:set_index(0x40 + i, xor)
    end
    -- step 3 : xor bytes 0x0D-0x10 with bytes 0x34-0x38
    for i = 0, 3, 1 do
        local xor = mod:get_index(0x0D + i) ~ mod:get_index(0x34 + i)
        mod:set_index(0x0D + i, xor)
    end
    -- step 2 : xor first 0x40 bytes with  last 0x40 bytes
    for i = 0, 63, 1 do
        local xor = mod:get_index(i) ~ mod:get_index(0x40 + i)
        mod:set_index(i, xor)
    end
    -- step 1 : 0x4D-0x50 <-> 0x00-0x04
    for i = 0, 3, 1 do
        local temp = mod:get_index(0x00 + i)
        mod:set_index(0x00 + i, mod:get_index(0x4D + i))
        mod:set_index(0x4D + i, temp)
    end
    return mod
end

return _M