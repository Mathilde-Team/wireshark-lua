-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/htools-org/wireshark-handshake-protocol,
-- commit ba7915c2b788e34d084f7151f2000aa9ff3b305f du 11/01/2026.
-- Licence amont : MIT — voir README.md et LICENSE.txt.

-- SendHeaders Packet
local packet = {}

packet.name = "sendheaders"
packet.type = 12

packet.fields = {}

function packet.parse(protocol, tree, buffer, offset)
    -- No data
    return offset, nil
end

return packet
