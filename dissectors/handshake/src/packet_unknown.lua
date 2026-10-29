-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/htools-org/wireshark-handshake-protocol,
-- commit ba7915c2b788e34d084f7151f2000aa9ff3b305f du 11/01/2026.
-- Licence amont : MIT — voir README.md et LICENSE.txt.

-- Unknown Packet
local packet = {}

packet.name = "unknown"
packet.type = 30

packet.fields = {
    data = ProtoField.bytes("handshake.unknown.data", "Data", base.NONE)
}

function packet.parse(protocol, tree, buffer, offset)
    -- Data
    local length = buffer:len() - offset
    local data_buf = buffer(offset, length)
    tree:add_le(packet.fields.data, data_buf)
    offset = offset + length

    -- Info column string
    local info = "data=" .. data_buf:range(0, math.min(length, 6)) .. "..."

    return offset, info
end

return packet
