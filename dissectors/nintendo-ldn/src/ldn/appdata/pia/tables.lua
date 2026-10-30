-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/appdata/pia/tables.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS == nil or GLOBALS.modules.pia.tables ~= false then
    return
end
GLOBALS.modules.pia.tables = true

-- Module table
local pia_tables = {}

-- Source: https://github.com/kinnay/NintendoClients/wiki/LDN-Application-Data-(Pia)

-- mapping table: systemCommunicationVersion to PIA version
pia_tables.version_map = {
    [1] = "5.2-5.7",
    [2] = "5.9",
    [3] = "5.10",
    [4] = "5.11-5.17",
    [5] = "5.18",
    [8] = "5.39"
}

-- Return the module
return pia_tables
