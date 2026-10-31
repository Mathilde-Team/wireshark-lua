-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/htools-org/wireshark-handshake-protocol,
-- commit ba7915c2b788e34d084f7151f2000aa9ff3b305f du 11/01/2026.
-- Licence amont : MIT — voir README.md et LICENSE.txt.

local utils = require("handshake.utils")

local TxPacket = require("handshake.packet_tx")
local HeadersPacket = require("handshake.packet_headers")

-- Block Packet
local packet = {}

packet.name = "block"
packet.type = 13

packet.fields = {
    txcount = ProtoField.uint64("handshake.block.txcount", "Tx Count", base.DEC)
}

function packet.parse(protocol, tree, buffer, offset)
    -- Block Header
    local hSubtree = tree:add(protocol,
                              buffer(offset, constants.BLOCK_HEADER_LEN),
                              "Block Header")

    offset = HeadersPacket.parse_header(protocol, hSubtree, buffer, offset)

    -- Tx count
    local txcount_size, txcount_value = utils.get_varint_value(buffer, offset)
    tree:add_le(packet.fields.txcount, buffer(offset, txcount_size))
    offset = offset + txcount_size

    local bodySubtree = tree:add(protocol, buffer(offset), "Block Contents")

    -- Loop for every transaction
    for tx_idx = 0, txcount_value - 1, 1 do

        -- Note when it starts
        local offset_tx_start = offset

        local txSubtree = bodySubtree:add(protocol, buffer(offset),
                                          "Transaction " .. tx_idx)

        offset = TxPacket.parse_tx(protocol, txSubtree, buffer, offset)

        txSubtree.len = offset - offset_tx_start
    end

    -- Info column string
    local info = "transactions=" .. txcount_value

    return offset, info
end

return packet
