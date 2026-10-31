-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/appdata/mii/mouth.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS == nil or GLOBALS.modules.mii.mouth ~= false then
    return
end
GLOBALS.modules.mii.mouth = true

-- Module table
local mouth = {}

-- ProtoField definitions
mouth.type = ProtoField.uint8("mii.mouth.type", "Type", base.DEC)
mouth.color = ProtoField.uint8("mii.mouth.color", "Color", base.DEC)
mouth.scale = ProtoField.uint8("mii.mouth.scale", "Scale", base.DEC)
mouth.aspect = ProtoField.uint8("mii.mouth.aspect", "Aspect", base.DEC)
mouth.y = ProtoField.uint8("mii.mouth.y", "Pos y", base.DEC)

-- Return the module
return mouth
