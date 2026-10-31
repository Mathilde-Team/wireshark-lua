-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/special_fx.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local effect_flags = ProtoField.uint8("terraria.special_fx.effect_flags", "Effect Flags", base.HEX)
local x = ProtoField.int32("terraria.special_fx.x", "X", base.DEC)
local y = ProtoField.int32("terraria.special_fx.y", "Y", base.DEC)
local data = ProtoField.uint8("terraria.special_fx.data", "Data", base.DEC)
local tree_gore = ProtoField.int16("terraria.special_fx.tree_gore", "Tree Gore", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(effect_flags)
	payload:int32_le(x)
	payload:int32_le(y)
	payload:uint8(data)
	payload:int16_le(tree_gore)
end

return {
	id = 112,
	build = build,
	fields = {
		effect_flags,
		x,
		y,
		data,
		tree_gore,
	},
}
