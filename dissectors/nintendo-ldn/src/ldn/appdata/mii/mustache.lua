-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://codeberg.org/TSRBerry/ldn_utils (wireshark/ldn/appdata/mii/mustache.lua),
-- commit 1ee820b4f068e2ef85d2c227222b04996961b3dd du 17/10/2022.
-- Licence amont : GPLv2 (LICENSE, sans clause « or later ») — voir README.md.

if GLOBALS == nil or GLOBALS.modules.mii.mustache ~= false then
    return
end
GLOBALS.modules.mii.mustache = true

-- Module table
local mustache = {}

-- ProtoField definitions
mustache.type = ProtoField.uint8("mii.mustache.type", "Type", base.DEC)
mustache.scale = ProtoField.uint8("mii.mustache.scale", "Scale", base.DEC)
mustache.y = ProtoField.uint8("mii.mustache.y", "Pos y", base.DEC)

-- Return the module
return mustache
