-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/appdata/mii/eye.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS == nil or GLOBALS.modules.mii.eye ~= false then
    return
end
GLOBALS.modules.mii.eye = true

-- Module table
local eye = {}

-- ProtoField definitions
eye.type = ProtoField.uint8("mii.eye.type", "Type", base.DEC)
eye.color = ProtoField.uint8("mii.eye.color", "Color", base.DEC)
eye.scale = ProtoField.uint8("mii.eye.scale", "Scale", base.DEC)
eye.aspect = ProtoField.uint8("mii.eye.aspect", "Aspect", base.DEC)
eye.rotate = ProtoField.uint8("mii.eye.rotate", "Rotate", base.DEC)
eye.x = ProtoField.uint8("mii.eye.x", "Pos x", base.DEC)
eye.y = ProtoField.uint8("mii.eye.y", "Pos y", base.DEC)

-- Return the module
return eye
