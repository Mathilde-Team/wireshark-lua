-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_tile_picking.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.sync_tile_picking.player_id", "Player ID", base.DEC)
local x = ProtoField.int16("terraria.sync_tile_picking.x", "X", base.DEC)
local y = ProtoField.int16("terraria.sync_tile_picking.y", "Y", base.DEC)
local pick_damage = ProtoField.uint8("terraria.sync_tile_picking.pick_damage", "Pick Damage", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int16_le(x)
	payload:int16_le(y)
	payload:uint8(pick_damage)
end

return {
	id = 125,
	build = build,
	fields = {
		player_id,
		x,
		y,
		pick_damage,
	},
}
