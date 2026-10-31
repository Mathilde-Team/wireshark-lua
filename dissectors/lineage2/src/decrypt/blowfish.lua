-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/eldarkg/lineage2wireshark (decrypt/blowfish.lua),
-- commit 44762d9fa378b5f0b23d5346dfbd854fc5c5eb41 du 19/10/2025.
-- Licence amont : GPL-3.0 (LICENSE amont) — voir README.md.

--[[
    License: GPL3
    Author: Eldar Khayrullin
    Email: eldar.khayrullin@mail.ru
    Date: 2024-2025
    Description: Blowfish ECB crypto
]] --

local cipher = GcryptCipher.open(GCRY_CIPHER_BLOWFISH, GCRY_CIPHER_MODE_ECB, 0)

local _M = {}

---@param data ByteArray
---@param bs integer
---@return ByteArray
local function align_size(data, bs)
    local alen = (bs - data:len() % bs) % bs
    data:set_size(data:len() + alen)
    return data
end

---@param data ByteArray
---@param bs integer
---@return ByteArray
local function swap_endian(data, bs)
    local swapped = ByteArray.new()
    swapped:set_size(data:len())

    for i = 0, data:len() - 1, bs do
        for j = i + bs - 1, i, -1 do
            local b = (j < data:len()) and data:get_index(j) or 0
            swapped:set_index(2 * i + bs - 1 - j, b)
        end
    end

    return swapped
end

---@param pk ByteArray
function _M.set_key(pk)
    cipher:setkey(pk)
end

---@param enc ByteArray
---@return ByteArray
function _M.decrypt(enc)
    local bf_bs = 8
    enc = align_size(enc, bf_bs)
    local bs = 4
    local enc_be = swap_endian(enc, bs)

    local dec_be = cipher:decrypt(NULL, enc_be)
    local dec = swap_endian(dec_be, bs)
    return dec
end

return _M
