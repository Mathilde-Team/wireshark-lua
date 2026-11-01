-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://gitlab.com/busshark/busshark.dissectors.mvb (plugins/busshark.dissectors/meta/meta-analyse.lua),
-- commit 25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c du 11/07/2025.
-- Licence amont : GPL-2.0-only (LICENSE amont) — voir README.md.
local analyse = {}

local dissector_root_path = string.sub(debug.getinfo(1).source, 2, string.len("/meta/meta-analyse.lua") * -1)
package.path = package.path .. ';' .. dissector_root_path .. '/?.lua;'
local cache = require "types/chache"

local last_time_frame_cache = cache.new()

local delta_times_cache = cache.new()

function analyse.run(pinfo, tree, config)
    local proto_id = config.post_proto()
    local line_id = config.post_line()
    if line_id == nil then
        line_id = config.post_pins()
    end

    local current_time = config.post_receive_time()
    if current_time == nil then
        current_time = { value = NSTime.new(0, 0), }
    end
    local frame_duration = config.post_frame_duration()
    if frame_duration == nil then
        frame_duration = { value = NSTime.new(0, 0), }
    end

    local end_time = current_time.value + frame_duration.value

    local subtree = tree:add(config.ana_protocol, "Analysed data")
    subtree:add(config.ana_protocol.fields.frame_end_time, end_time)

    if not pinfo.visited then
        cache.update(delta_times_cache, NSTime.new(0, 0), pinfo.number)

        local last_time = cache.get(last_time_frame_cache, proto_id.value, line_id.value)
        if last_time == nil then
            last_time = { time = current_time.value, duration = frame_duration.value, id = pinfo.number }
        end

        cache.update(
            delta_times_cache,
            current_time.value - last_time.time - last_time.duration,
            last_time.id
        )

        -- update last time
        cache.update(
            last_time_frame_cache,
            {
                time = current_time.value,
                duration = frame_duration.value,
                id = pinfo.number
            },
            proto_id.value,
            line_id.value
        )
    end

    local delta_time = cache.get(delta_times_cache, pinfo.number)
    subtree:add(config.ana_protocol.fields.delta_receive_time, delta_time)
    return { tree = subtree, delta_receive_time = delta_time, analyse = analyse }
end

-- Check status codes containing any error
--
--@param: status_codes, bit field
function analyse.contains_errors(status_codes)
    local last_index = status_codes:len() - 1
    for i = 0, last_index do
        local status_code = status_codes:get_index(i)
        local without_line = extract_line(status_code)
        if without_line == 4 or (without_line == 5 and i ~= last_index) then
            return true
        end
    end
    return false
end

function extract_line(status_code)
    return bit.band(status_code, 0x07)
end

return analyse
