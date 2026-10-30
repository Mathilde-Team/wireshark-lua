-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/appdata/mii/faceline.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS == nil or GLOBALS.modules.mii.faceline ~= false then
    return
end
GLOBALS.modules.mii.faceline = true

-- Module table
local faceline = {}

-- ProtoField definitions
faceline.type = ProtoField.uint8("mii.faceline.type", "Type", base.DEC)
faceline.color = ProtoField.uint8("mii.faceline.color", "Color", base.DEC)
faceline.wrinkle = ProtoField.uint8("mii.faceline.wrinkle", "Wrinkle", base.DEC)
faceline.make = ProtoField.uint8("mii.faceline.make", "Make", base.DEC)

-- Return the module
return faceline
