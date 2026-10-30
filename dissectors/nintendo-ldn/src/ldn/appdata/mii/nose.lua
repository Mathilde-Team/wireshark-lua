-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/appdata/mii/nose.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS == nil or GLOBALS.modules.mii.nose ~= false then
    return
end
GLOBALS.modules.mii.nose = true

-- Module table
local nose = {}

-- ProtoField definitions
nose.type = ProtoField.uint8("mii.nose.type", "Type", base.DEC)
nose.scale = ProtoField.uint8("mii.nose.scale", "Scale", base.DEC)
nose.y = ProtoField.uint8("mii.nose.y", "Pos y", base.DEC)

-- Return the module
return nose
