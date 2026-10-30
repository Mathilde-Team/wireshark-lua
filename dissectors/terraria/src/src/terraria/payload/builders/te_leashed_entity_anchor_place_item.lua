-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/te_leashed_entity_anchor_place_item.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local x = ProtoField.int16("terraria.te_leashed_entity_anchor_place_item.x", "X", base.DEC)
local y = ProtoField.int16("terraria.te_leashed_entity_anchor_place_item.y", "Y", base.DEC)
local item_id = ProtoField.int16("terraria.te_leashed_entity_anchor_place_item.item_id", "Item ID", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(x)
	payload:int16_le(y)
	payload:int16_le(item_id)
end

return {
	id = 156,
	build = build,
	fields = {
		x,
		y,
		item_id,
	},
}
