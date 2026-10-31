-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/player_hurt_v2.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local death_reason = require("terraria.payload.structures.death_reason")

local player_id = ProtoField.uint8("terraria.player_hurt_v2.player_id", "Player ID", base.DEC)
local reason = death_reason.fields("terraria.player_hurt_v2")
local damage = ProtoField.int16("terraria.player_hurt_v2.damage", "Damage", base.DEC)
local hit_direction = ProtoField.uint8(
	"terraria.player_hurt_v2.hit_direction",
	"Hit Direction",
	base.DEC
)
local flags = ProtoField.uint8("terraria.player_hurt_v2.flags", "Flags", base.HEX)
local cooldown_counter = ProtoField.int8(
	"terraria.player_hurt_v2.cooldown_counter",
	"Cooldown Counter",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	death_reason.read(payload, reason)
	payload:int16_le(damage)
	payload:uint8(hit_direction)
	payload:uint8(flags)
	payload:sbyte(cooldown_counter)
end

local fields = { player_id }
for _, field in ipairs(death_reason.list(reason)) do
	fields[#fields + 1] = field
end
for _, field in ipairs({ damage, hit_direction, flags, cooldown_counter }) do
	fields[#fields + 1] = field
end

return {
	id = 117,
	build = build,
	fields = fields,
}
