-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/item_position.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local item_index = ProtoField.int16("terraria.item_position.item_index", "Item Index", base.DEC)
local position = ProtoField.bytes("terraria.item_position.position", "Position")
local position_x = ProtoField.float("terraria.item_position.position_x", "Position X")
local position_y = ProtoField.float("terraria.item_position.position_y", "Position Y")

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(item_index)
	payload:vector2(position, position_x, position_y)
end

return {
	id = 160,
	build = build,
	fields = {
		item_index,
		position,
		position_x,
		position_y,
	},
}
