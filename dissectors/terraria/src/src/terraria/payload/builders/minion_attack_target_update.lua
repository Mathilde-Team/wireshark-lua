-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/minion_attack_target_update.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.minion_attack_target_update.player_id",
	"Player ID",
	base.DEC
)
local minion_attack_target = ProtoField.int16(
	"terraria.minion_attack_target_update.minion_attack_target",
	"Minion Attack Target",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int16_le(minion_attack_target)
end

return {
	id = 115,
	build = build,
	fields = {
		player_id,
		minion_attack_target,
	},
}
