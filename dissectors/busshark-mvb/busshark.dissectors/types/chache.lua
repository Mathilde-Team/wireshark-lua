-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://gitlab.com/busshark/busshark.dissectors.mvb (plugins/busshark.dissectors/types/chache.lua),
-- commit 25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c du 11/07/2025.
-- Licence amont : GPL-2.0-only (LICENSE amont) — voir README.md.
local api = {}


function api.new()
    return {}
end

function api.get(
    source, -- [[cache table]]
    ...     -- [[ cahce keys]]
)
    local args = { ... }

    local item = source

    for _, key in ipairs(args) do
        item = item[key]
        if item == nil then
            return nil
        end
    end

    return item
end

function api.update(
    source, -- [[cache table]]
    value,  -- [[ cache entry]]
    ...     -- [[ cachce keys]]
)
    local args = { ... }
    local arg_size = #args
    local item = source

    for i, key in ipairs(args) do
        if i == arg_size then
            item[key] = value
            break
        end

        local new_item  = item[key]
        if new_item == nil then
            new_item = {}
            item[key] = new_item
        end

        item = new_item
    end

    -- luacheck: push ignore source
    source = item;
    -- luacheck: pop
end

return api
