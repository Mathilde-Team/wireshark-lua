-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/tamper_with_npc.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local npc_id = ProtoField.uint16("terraria.tamper_with_npc.npc_id", "NPC ID", base.DEC)
local set_npc_immunity = ProtoField.bool(
	"terraria.tamper_with_npc.set_npc_immunity",
	"Set NPC Immunity"
)
local immunity_time = ProtoField.int32(
	"terraria.tamper_with_npc.immunity_time",
	"Immunity Time",
	base.DEC
)
local immunity_player_id = ProtoField.int16(
	"terraria.tamper_with_npc.immunity_player_id",
	"Immunity Player ID",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint16_le(npc_id)
	local enabled = payload:bool(set_npc_immunity)

	if enabled then
		payload:int32_le(immunity_time)
	end

	payload:int16_le(immunity_player_id)
end

return {
	id = 131,
	build = build,
	fields = {
		npc_id,
		set_npc_immunity,
		immunity_time,
		immunity_player_id,
	},
}
