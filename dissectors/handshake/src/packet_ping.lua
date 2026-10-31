-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/htools-org/wireshark-handshake-protocol,
-- commit ba7915c2b788e34d084f7151f2000aa9ff3b305f du 11/01/2026.
-- Licence amont : MIT — voir README.md et LICENSE.txt.

-- Ping Packet
local packet = {}

packet.name = "ping"
packet.type = 2

packet.fields = {
    nonce = ProtoField.uint64("handshake.ping.nonce", "Nonce", base.HEX)
}

function packet.parse(protocol, tree, buffer, offset)
    -- Nonce
    local nonce_buf = buffer(offset, 8)
    tree:add_le(packet.fields.nonce, nonce_buf)
    offset = offset + 8

    -- Info column string
    local info = "nonce=" .. nonce_buf

    return offset, info
end

return packet
