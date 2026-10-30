-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/item_tweaker.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local item_index = ProtoField.int16(
	"terraria.item_tweaker.item_index",
	"Item Index",
	base.DEC
)
local flags1 = ProtoField.uint8("terraria.item_tweaker.flags1", "Flags 1", base.HEX)
local packed_color_value = ProtoField.uint32(
	"terraria.item_tweaker.packed_color_value",
	"Packed Color Value",
	base.DEC
)
local damage = ProtoField.uint16("terraria.item_tweaker.damage", "Damage", base.DEC)
local knockback = ProtoField.float("terraria.item_tweaker.knockback", "Knockback")
local use_animation = ProtoField.uint16(
	"terraria.item_tweaker.use_animation",
	"Use Animation",
	base.DEC
)
local use_time = ProtoField.uint16("terraria.item_tweaker.use_time", "Use Time", base.DEC)
local shoot = ProtoField.int16("terraria.item_tweaker.shoot", "Shoot", base.DEC)
local shoot_speed = ProtoField.float("terraria.item_tweaker.shoot_speed", "Shoot Speed")
local flags2 = ProtoField.uint8("terraria.item_tweaker.flags2", "Flags 2", base.HEX)
local width = ProtoField.int16("terraria.item_tweaker.width", "Width", base.DEC)
local height = ProtoField.int16("terraria.item_tweaker.height", "Height", base.DEC)
local scale = ProtoField.float("terraria.item_tweaker.scale", "Scale")
local ammo = ProtoField.int16("terraria.item_tweaker.ammo", "Ammo", base.DEC)
local use_ammo = ProtoField.int16("terraria.item_tweaker.use_ammo", "Use Ammo", base.DEC)
local not_ammo = ProtoField.bool("terraria.item_tweaker.not_ammo", "Not Ammo")

---@param payload PayloadReader
---@param flags_value integer
local function read_flagged_fields(payload, flags_value)
	if (flags_value & 0x01) ~= 0 then payload:uint32_le(packed_color_value) end
	if (flags_value & 0x02) ~= 0 then payload:uint16_le(damage) end
	if (flags_value & 0x04) ~= 0 then payload:single_le(knockback) end
	if (flags_value & 0x08) ~= 0 then payload:uint16_le(use_animation) end
	if (flags_value & 0x10) ~= 0 then payload:uint16_le(use_time) end
	if (flags_value & 0x20) ~= 0 then payload:int16_le(shoot) end
	if (flags_value & 0x40) ~= 0 then payload:single_le(shoot_speed) end
end

---@param payload PayloadReader
local function read_extended_fields(payload)
	local flags2_value = payload:uint8(flags2)

	if (flags2_value & 0x01) ~= 0 then payload:int16_le(width) end
	if (flags2_value & 0x02) ~= 0 then payload:int16_le(height) end
	if (flags2_value & 0x04) ~= 0 then payload:single_le(scale) end
	if (flags2_value & 0x08) ~= 0 then payload:int16_le(ammo) end
	if (flags2_value & 0x10) ~= 0 then payload:int16_le(use_ammo) end
	if (flags2_value & 0x20) ~= 0 then payload:bool(not_ammo) end
end

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(item_index)
	local flags1_value = payload:uint8(flags1)
	read_flagged_fields(payload, flags1_value)
	if (flags1_value & 0x80) ~= 0 then
		read_extended_fields(payload)
	end
end

return {
	id = 88,
	build = build,
	fields = {
		item_index,
		flags1,
		packed_color_value,
		damage,
		knockback,
		use_animation,
		use_time,
		shoot,
		shoot_speed,
		flags2,
		width,
		height,
		scale,
		ammo,
		use_ammo,
		not_ammo,
	},
}
