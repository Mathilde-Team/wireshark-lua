-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/htools-org/wireshark-handshake-protocol,
-- commit ba7915c2b788e34d084f7151f2000aa9ff3b305f du 11/01/2026.
-- Licence amont : MIT — voir README.md et LICENSE.txt.

-- Claim Packet
local packet = {}

packet.name = "claim"
packet.type = 28

packet.fields = {
    size = ProtoField.uint16("handshake.claim.size", "Size", base.DEC),
    blob = ProtoField.bytes("handshake.claim.blob", "Blob", base.NONE)
}

function packet.parse(protocol, tree, buffer, offset)
    -- Size
    local size_buf = buffer(offset, 2)
    local size = size_buf:le_uint()
    tree:add_le(packet.fields.size, size_buf)
    offset = offset + 2

    -- Blob
    tree:add_le(packet.fields.blob, buffer(offset, size))
    offset = offset + size

    -- Info column string
    local info = "size=" .. size

    return offset, info
end

return packet
