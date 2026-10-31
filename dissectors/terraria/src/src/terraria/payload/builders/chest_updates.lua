-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/chest_updates.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local action = ProtoField.uint8("terraria.chest_updates.action", "Action", base.DEC)
local tile_x = ProtoField.int16("terraria.chest_updates.tile_x", "Tile X", base.DEC)
local tile_y = ProtoField.int16("terraria.chest_updates.tile_y", "Tile Y", base.DEC)
local style = ProtoField.int16("terraria.chest_updates.style", "Style", base.DEC)
local chest_id_to_destroy = ProtoField.int16(
	"terraria.chest_updates.chest_id_to_destroy",
	"Chest ID to Destroy",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(action)
	payload:int16_le(tile_x)
	payload:int16_le(tile_y)
	payload:int16_le(style)
	payload:int16_le(chest_id_to_destroy)
end

return {
	id = 34,
	build = build,
	fields = {
		action,
		tile_x,
		tile_y,
		style,
		chest_id_to_destroy,
	},
}
