-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/npc_home.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local npc_id = ProtoField.int16("terraria.npc_home.npc_id", "NPC ID", base.DEC)
local home_tile_x = ProtoField.int16(
	"terraria.npc_home.home_tile_x",
	"Home Tile X",
	base.DEC
)
local home_tile_y = ProtoField.int16(
	"terraria.npc_home.home_tile_y",
	"Home Tile Y",
	base.DEC
)
local homeless = ProtoField.uint8("terraria.npc_home.homeless", "Homeless", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(npc_id)
	payload:int16_le(home_tile_x)
	payload:int16_le(home_tile_y)
	payload:uint8(homeless)
end

return {
	id = 60,
	build = build,
	fields = {
		npc_id,
		home_tile_x,
		home_tile_y,
		homeless,
	},
}
