-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/player_heal.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.player_heal.player_id", "Player ID", base.DEC)
local heal_amount = ProtoField.int16("terraria.player_heal.heal_amount", "Heal Amount", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int16_le(heal_amount)
end

return {
	id = 35,
	build = build,
	fields = {
		player_id,
		heal_amount,
	},
}
