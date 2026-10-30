-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn_mitm/decompress.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

function DecompressData(array, length)
    local output = ByteArray.new()
    output:set_size(length)

    local i = 0
    local outputIndex = 0
    while i < array:len() and outputIndex + 1 < length do
        local inputByte = array:get_index(i)
        output:set_index(outputIndex, inputByte)

        i = i + 1
        outputIndex = outputIndex + 1

        if inputByte == 0 then
            if i == array:len() then
                return {}
            end

            local count = array:get_index(i)
            i = i + 1

            for j = 1, count, 1 do
                if outputIndex + 1 == length then
                    break
                end

                output:set_index(outputIndex, inputByte)
                outputIndex = outputIndex + 1
            end
        end
    end

    return output
end
