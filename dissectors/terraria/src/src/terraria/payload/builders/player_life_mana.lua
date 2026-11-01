-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/player_life_mana.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.player_life_mana.player_id", "Player ID", base.DEC)
local hp = ProtoField.int16("terraria.player_life_mana.hp", "HP", base.DEC)
local max_hp = ProtoField.int16("terraria.player_life_mana.max_hp", "Max HP", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int16_le(hp)
	payload:int16_le(max_hp)
end

return {
	id = 16,
	build = build,
	fields = {
		player_id,
		hp,
		max_hp,
	},
}
