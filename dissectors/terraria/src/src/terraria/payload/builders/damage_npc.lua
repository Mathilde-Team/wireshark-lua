-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/damage_npc.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local npc_index = ProtoField.uint8("terraria.damage_npc.npc_index", "NPC Index", base.DEC)
local generation = ProtoField.uint8("terraria.damage_npc.generation", "Generation", base.DEC)
local damage = ProtoField.int16("terraria.damage_npc.damage", "Damage", base.DEC)
local knockback = ProtoField.float("terraria.damage_npc.knockback", "Knockback")
local hit_direction = ProtoField.uint8(
	"terraria.damage_npc.hit_direction",
	"Hit Direction",
	base.DEC,
	{ [0] = "Left", [1] = "None", [2] = "Right" }
)
local crit = ProtoField.bool("terraria.damage_npc.crit", "Crit")

---@param payload PayloadReader
local function build(payload)
	payload:uint8(npc_index)
	payload:uint8(generation)
	payload:int16_le(damage)
	payload:single_le(knockback)
	payload:uint8(hit_direction)
	payload:bool(crit)
end

return {
	id = 28,
	build = build,
	fields = {
		npc_index,
		generation,
		damage,
		knockback,
		hit_direction,
		crit,
	},
}
