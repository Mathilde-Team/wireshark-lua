-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/eldarkg/lineage2wireshark (common/id.lua),
-- commit 44762d9fa378b5f0b23d5346dfbd854fc5c5eb41 du 19/10/2025.
-- Licence amont : GPL-3.0 (LICENSE amont) — voir README.md.

--[[
    License: GPL3
    Author: Eldar Khayrullin
    Email: eldar.khayrullin@mail.ru
    Date: 2024
    Description: ID
]]--

---Workaround: skip 1st pass without root path
if not package.searchpath("common.id", package.path) then
    return
end

local ini = require("thirdparty.ini")

local _M = {}

---@param path string
---@param offset integer
---@return table id_desc
function _M.load(path, offset)
    local tbl = ini.parse(path)
    local id_desc = {}
    for id, desc in pairs(tbl) do
        id_desc[tonumber(id) + offset] = desc
    end
    return id_desc
end

return _M