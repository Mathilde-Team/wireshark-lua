-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/appdata/mii/beard.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS == nil or GLOBALS.modules.mii.beard ~= false then
    return
end
GLOBALS.modules.mii.beard = true

-- Module table
local beard = {}

-- ProtoField definitions
beard.type = ProtoField.uint8("mii.beard.type", "Type", base.DEC)
beard.color = ProtoField.uint8("mii.beard.color", "Color", base.DEC)

-- Return the module
return beard
