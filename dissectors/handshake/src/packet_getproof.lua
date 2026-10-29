-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/htools-org/wireshark-handshake-protocol,
-- commit ba7915c2b788e34d084f7151f2000aa9ff3b305f du 11/01/2026.
-- Licence amont : MIT — voir README.md et LICENSE.txt.

-- GetProof Packet
local packet = {}

packet.name = "getproof"
packet.type = 26

packet.fields = {
    root = ProtoField.bytes("handshake.getproof.root", "Root", base.NONE),
    key = ProtoField.bytes("handshake.getproof.key", "Key", base.NONE)
}

function packet.parse(protocol, tree, buffer, offset)
    -- Root
    local root_buf = buffer(offset, 32)
    tree:add_le(packet.fields.root, root_buf)
    offset = offset + 32

    -- Key
    local key_buf = buffer(offset, 32)
    tree:add_le(packet.fields.key, key_buf)
    offset = offset + 32

    -- Info column string
    local info = "root=..." .. root_buf:range(28, 4) .. " key=..." ..
                     key_buf:range(28, 4)

    return offset, info
end

return packet
