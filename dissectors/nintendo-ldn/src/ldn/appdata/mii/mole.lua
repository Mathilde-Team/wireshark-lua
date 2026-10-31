-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/appdata/mii/mole.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS == nil or GLOBALS.modules.mii.mole ~= false then
    return
end
GLOBALS.modules.mii.mole = true

-- Module table
local mole = {}

-- ProtoField definitions
mole.hasMole = ProtoField.bool("mii.mole.hasMole", "Has mole")
mole.scale = ProtoField.uint8("mii.mole.scale", "Scale", base.DEC)
mole.x = ProtoField.uint8("mii.mole.x", "Pos x", base.DEC)
mole.y = ProtoField.uint8("mii.mole.y", "Pos y", base.DEC)

-- Return the module
return mole
