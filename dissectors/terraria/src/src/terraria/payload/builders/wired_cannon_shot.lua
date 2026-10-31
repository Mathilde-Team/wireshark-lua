-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/wired_cannon_shot.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local damage = ProtoField.int16("terraria.wired_cannon_shot.damage", "Damage", base.DEC)
local knockback = ProtoField.float("terraria.wired_cannon_shot.knockback", "Knockback")
local x = ProtoField.int16("terraria.wired_cannon_shot.x", "X", base.DEC)
local y = ProtoField.int16("terraria.wired_cannon_shot.y", "Y", base.DEC)
local angle = ProtoField.int16("terraria.wired_cannon_shot.angle", "Angle", base.DEC)
local ammo = ProtoField.int16("terraria.wired_cannon_shot.ammo", "Ammo", base.DEC)
local player_id = ProtoField.uint8(
	"terraria.wired_cannon_shot.player_id",
	"Player ID",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(damage)
	payload:single_le(knockback)
	payload:int16_le(x)
	payload:int16_le(y)
	payload:int16_le(angle)
	payload:int16_le(ammo)
	payload:uint8(player_id)
end

return {
	id = 108,
	build = build,
	fields = {
		damage,
		knockback,
		x,
		y,
		angle,
		ammo,
		player_id,
	},
}
