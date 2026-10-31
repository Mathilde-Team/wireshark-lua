-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/unused_melee_strike.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local npc_id = ProtoField.int16(
	"terraria.unused_melee_strike.npc_id",
	"NPC ID",
	base.DEC
)
local player_id = ProtoField.uint8(
	"terraria.unused_melee_strike.player_id",
	"Player ID",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(npc_id)
	payload:uint8(player_id)
end

return {
	id = 24,
	build = build,
	fields = {
		npc_id,
		player_id,
	},
}
