-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_revenge_marker.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local unique_id = ProtoField.int32("terraria.sync_revenge_marker.unique_id", "Unique ID", base.DEC)
local x = ProtoField.float("terraria.sync_revenge_marker.x", "X")
local y = ProtoField.float("terraria.sync_revenge_marker.y", "Y")
local npc_id = ProtoField.int32("terraria.sync_revenge_marker.npc_id", "NPC ID", base.DEC)
local npc_hp_percent = ProtoField.float(
	"terraria.sync_revenge_marker.npc_hp_percent",
	"NPC HP Percent"
)
local npc_type = ProtoField.int32("terraria.sync_revenge_marker.npc_type", "NPC Type", base.DEC)
local npc_ai = ProtoField.int32("terraria.sync_revenge_marker.npc_ai", "NPC AI", base.DEC)
local coin_value = ProtoField.int32("terraria.sync_revenge_marker.coin_value", "Coin Value", base.DEC)
local base_value = ProtoField.float("terraria.sync_revenge_marker.base_value", "Base Value")
local spawned_from_statue = ProtoField.bool(
	"terraria.sync_revenge_marker.spawned_from_statue",
	"Spawned From Statue"
)

---@param payload PayloadReader
local function build(payload)
	payload:int32_le(unique_id)
	payload:single_le(x)
	payload:single_le(y)
	payload:int32_le(npc_id)
	payload:single_le(npc_hp_percent)
	payload:int32_le(npc_type)
	payload:int32_le(npc_ai)
	payload:int32_le(coin_value)
	payload:single_le(base_value)
	payload:bool(spawned_from_statue)
end

return {
	id = 126,
	build = build,
	fields = {
		unique_id,
		x,
		y,
		npc_id,
		npc_hp_percent,
		npc_type,
		npc_ai,
		coin_value,
		base_value,
		spawned_from_statue,
	},
}
