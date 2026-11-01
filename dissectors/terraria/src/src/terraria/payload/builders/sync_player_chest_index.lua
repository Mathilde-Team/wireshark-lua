-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_player_chest_index.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player = ProtoField.uint8("terraria.sync_player_chest_index.player", "Player", base.DEC)
local chest = ProtoField.int16("terraria.sync_player_chest_index.chest", "Chest", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player)
	payload:int16_le(chest)
end

return {
	id = 80,
	build = build,
	fields = {
		player,
		chest,
	},
}
