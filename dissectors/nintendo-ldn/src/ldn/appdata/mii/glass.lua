-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/appdata/mii/glass.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS == nil or GLOBALS.modules.mii.glass ~= false then
    return
end
GLOBALS.modules.mii.glass = true

-- Module table
local glass = {}

-- ProtoField definitions
glass.type = ProtoField.uint8("mii.glass.type", "Type", base.DEC)
glass.color = ProtoField.uint8("mii.glass.color", "Color", base.DEC)
glass.scale = ProtoField.uint8("mii.glass.scale", "Scale", base.DEC)
glass.y = ProtoField.uint8("mii.glass.y", "Pos y", base.DEC)

-- Return the module
return glass
