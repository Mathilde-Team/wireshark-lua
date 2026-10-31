-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/common/tables.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS == nil or GLOBALS.modules.tables ~= false then
    return
end
GLOBALS.modules.tables = true

GLOBALS.tables = {}

GLOBALS.tables.protocol_id = {
    [4] = "LDN"
}

GLOBALS.tables.packet_type = {
    [257] = "Advertisement"
}

GLOBALS.tables.encryption_type = {
    [1] = "Plain",
    [2] = "AES-CTR"
}

GLOBALS.tables.security_level = {
    [1] = "Retail (Encrypted)",
    [2] = "Development (Encrypted advertisement frames)",
    [3] = "Development (Plaintext)"
}

GLOBALS.tables.station_accept_policy = {
    [0] = "Open participation",
    [1] = "Closed participation",
    [2] = "Blacklist",
    [3] = "Whitelist"
}
