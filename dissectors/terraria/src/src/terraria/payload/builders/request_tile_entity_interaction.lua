-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/request_tile_entity_interaction.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local tile_entity_id = ProtoField.int32(
	"terraria.request_tile_entity_interaction.tile_entity_id",
	"Tile Entity ID",
	base.DEC
)
local player_id = ProtoField.uint8("terraria.request_tile_entity_interaction.player_id", "Player ID", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int32_le(tile_entity_id)
	payload:uint8(player_id)
end

return {
	id = 122,
	build = build,
	fields = {
		tile_entity_id,
		player_id,
	},
}
