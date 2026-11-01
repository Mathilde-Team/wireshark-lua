-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn_mitm/types/networkId.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

-- Proto fields
local f_session_id = ProtoField.bytes("ldn_mitm.network.session_id", "Session ID", base.NONE)

-- Proto
local p_network_id = Proto("ldn_mitm.network", "Network ID")
p_network_id.fields = {f_session_id}

-- Dissector
function p_network_id.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then
        return
    end

    local subtree = tree:add(p_network_id, buffer(0, 32), "Network ID")
    Dissector.get("ldn_mitm.intent"):call(buffer, pinfo, subtree)
    subtree:add_le(f_session_id, buffer(16, 16))
end
