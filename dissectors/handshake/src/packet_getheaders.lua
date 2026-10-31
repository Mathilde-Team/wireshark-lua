-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/htools-org/wireshark-handshake-protocol,
-- commit ba7915c2b788e34d084f7151f2000aa9ff3b305f du 11/01/2026.
-- Licence amont : MIT — voir README.md et LICENSE.txt.

-- GetHeaders Packet
local packet = {}

packet.name = "getheaders"
packet.type = 10

packet.fields = {
    count = ProtoField.uint64("handshake.getheaders.count", "Hash Count",
                              base.DEC),
    hash = ProtoField.bytes("handshake.getheaders.hash", "Hash", base.NONE),
    stop = ProtoField.bytes("handshake.getheaders.stop", "Stop", base.NONE)
}

function packet.parse(protocol, tree, buffer, offset)
    -- Hash count
    local count_size, count_value = utils.get_varint_value(buffer, offset)
    tree:add_le(packet.fields.count, buffer(offset, count_size))
    offset = offset + count_size

    -- Loop for every hash
    for i = 0, count_value - 1, 1 do
        tree:add_le(packet.fields.hash, buffer(offset, 32))
        offset = offset + 32
    end

    -- Stop
    tree:add_le(packet.fields.stop, buffer(offset, 32))
    offset = offset + 32

    -- Info column string
    local info = "requested_headers=" .. count_value

    return offset, info
end

return packet
