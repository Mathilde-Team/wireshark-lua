-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/common/init.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS ~= nil then
    return
end

GLOBALS = {
    modules = {
        utils = false,
        sessionInfo = false,
        participants = false,
        advertisementData = false,
        advertisementFrame = false,
        tables = false
    },
    dissectors = {
        SessionInfo = nil,
        AdvertisementData = nil,
        Participants = nil
    },
    tables = nil
}

-- >>> DissectorTables <<<

GLOBALS.LDN_APP_DATA_TABLE = DissectorTable.get("ldn.appdata")
if GLOBALS.LDN_APP_DATA_TABLE == nil then
    GLOBALS.LDN_APP_DATA_TABLE = DissectorTable.new("ldn.appdata", "LDN application data", ftypes.STRING, base.HEX)
end

GLOBALS.LDN_COMMON_DATA_TABLE = DissectorTable.get("ldn.appdata.common")
if GLOBALS.LDN_COMMON_DATA_TABLE == nil then
    GLOBALS.LDN_COMMON_DATA_TABLE =
        DissectorTable.new("ldn.appdata.common", "LDN common application data", ftypes.STRING, base.NONE)
end

GLOBALS.LDN_PACKETS = DissectorTable.get("ldn.packets")
if GLOBALS.LDN_PACKETS == nil then
    GLOBALS.LDN_PACKETS = DissectorTable.new("ldn.packets", "LDN packets", ftypes.UINT16)
end

-- >>> Constants <<<

GLOBALS.const = {
    NINTENDO_OUI = 0x0022AA
}
