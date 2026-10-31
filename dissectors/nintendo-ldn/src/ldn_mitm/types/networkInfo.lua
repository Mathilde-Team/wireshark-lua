-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn_mitm/types/networkInfo.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

-- Proto
local p_network_info = Proto("ldn_mitm.network_info", "Network info")

-- Dissector
function p_network_info.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then
        return
    end

    local subtree = tree:add(p_network_info, buffer(), "Network info")
    Dissector.get("ldn_mitm.network"):call(buffer(0, 32):tvb(), pinfo, subtree)
    Dissector.get("ldn_mitm.common"):call(buffer(32, 48):tvb(), pinfo, subtree)
    Dissector.get("ldn_mitm.ldn_network"):call(buffer(80, 1072):tvb(), pinfo, subtree)
end
