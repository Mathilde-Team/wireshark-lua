-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://gitlab.com/busshark/busshark.dissectors.mvb (plugins/busshark.dissectors/mvb/mvb-slaveframe.lua),
-- commit 25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c du 11/07/2025.
-- Licence amont : GPL-2.0-only (LICENSE amont) — voir README.md.
-- module Slave frame
--
-- dissector handling of slave frames typ

local slaveframe = {}

-- Get length of provided frame
function slaveframe.size(mvb_frame)
    return mvb_frame:len()
end

-- Extract CRCs from frame_data
--
-- RETURN: frame_data, crc
function slaveframe.extract_crc(mvb_frame)
    local size = slaveframe.size(mvb_frame)
    -- table to store found CRCs
    local checksum = {}
    local frame_data = {}
    -- slave header must be present. frame with 16 or 32 bits of frame_data
    -- -> + 8 bits for appended checksum
    if (size > 0) and (size <= 5) then
        -- starting from 0
        local offset = size - 1
        checksum[1] = mvb_frame(offset, 1)
        frame_data[1] = mvb_frame(0, offset)
    elseif (size > 5) then
        -- frame_data checksum included at each 8 byte
        local offset = 8
        for i = 1, (size / 8) do
            if (mvb_frame:len() > offset) then
                checksum[i] = mvb_frame(offset, 1)
                frame_data[i] = mvb_frame(offset - 8, 8)
                -- frame_data size + crc size
                offset = offset + 9
            else
                print("Slaveframe extract crc reached end of mvb frame data")
                return frame_data, checksum
            end
        end
    else
        print("Frame size not handled!")
    end
    return frame_data, checksum
end

return slaveframe
