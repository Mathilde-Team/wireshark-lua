-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_talk_npc.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.sync_talk_npc.player_id", "Player ID", base.DEC)
local npc_talk_target = ProtoField.int16(
	"terraria.sync_talk_npc.npc_talk_target",
	"NPC Talk Target",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int16_le(npc_talk_target)
end

return {
	id = 40,
	build = build,
	fields = {
		player_id,
		npc_talk_target,
	},
}
