-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/tile_entity_placement.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local x = ProtoField.int16("terraria.tile_entity_placement.x", "X", base.DEC)
local y = ProtoField.int16("terraria.tile_entity_placement.y", "Y", base.DEC)
local tile_entity_type = ProtoField.uint8(
	"terraria.tile_entity_placement.tile_entity_type",
	"Tile Entity Type",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(x)
	payload:int16_le(y)
	payload:uint8(tile_entity_type)
end

return {
	id = 87,
	build = build,
	fields = {
		x,
		y,
		tile_entity_type,
	},
}
