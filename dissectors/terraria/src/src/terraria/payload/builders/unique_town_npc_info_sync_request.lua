-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/unique_town_npc_info_sync_request.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local npc_id = ProtoField.int16("terraria.unique_town_npc_info_sync_request.npc_id", "NPC ID", base.DEC)
local name = ProtoField.string("terraria.unique_town_npc_info_sync_request.name", "Name")
local town_npc_variation_index = ProtoField.int32(
	"terraria.unique_town_npc_info_sync_request.town_npc_variation_index",
	"Town NPC Variation Index",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(npc_id)

	if payload:remaining() == 0 then
		return
	end

	payload:string(name)

	if payload:remaining() >= 4 then
		payload:int32_le(town_npc_variation_index)
	end
end

return {
	id = 56,
	build = build,
	fields = {
		npc_id,
		name,
		town_npc_variation_index,
	},
}
