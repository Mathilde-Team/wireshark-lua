-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_loadout.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.sync_loadout.player_id", "Player ID", base.DEC)
local loadout_index = ProtoField.uint8("terraria.sync_loadout.loadout_index", "Loadout Index", base.DEC)
local hidden_accessories = ProtoField.uint16(
	"terraria.sync_loadout.hidden_accessories",
	"Hidden Accessories",
	base.HEX
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:uint8(loadout_index)
	payload:uint16_le(hidden_accessories)
end

return {
	id = 147,
	build = build,
	fields = {
		player_id,
		loadout_index,
		hidden_accessories,
	},
}
