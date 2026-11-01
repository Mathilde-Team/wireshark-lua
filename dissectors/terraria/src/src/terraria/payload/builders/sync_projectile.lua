-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_projectile.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local projectile_key = require("terraria.payload.structures.projectile_key")

local fields = {}

---@param factory fun(name: string, label: string, display: any): ProtoField
---@param name string
---@param label string
---@param display any
---@return ProtoField
local function define(factory, name, label, display)
	local field = factory("terraria.sync_projectile." .. name, label, display)
	fields[#fields + 1] = field
	return field
end

local root = define(ProtoField.bytes, "root", "Projectile Update")
local key_fields = projectile_key.fields("terraria.sync_projectile")
for _, field in ipairs(projectile_key.list(key_fields)) do
	fields[#fields + 1] = field
end
local position = define(ProtoField.bytes, "position", "Position")
local position_x = define(ProtoField.float, "position_x", "Position X")
local position_y = define(ProtoField.float, "position_y", "Position Y")
local velocity = define(ProtoField.bytes, "velocity", "Velocity")
local velocity_x = define(ProtoField.float, "velocity_x", "Velocity X")
local velocity_y = define(ProtoField.float, "velocity_y", "Velocity Y")
local projectile_type = define(ProtoField.int16, "projectile_type", "Type", base.DEC)
local flags = define(ProtoField.uint8, "flags", "Projectile Flags", base.HEX)
local flags2 = define(ProtoField.uint8, "flags2", "Projectile Flags 2", base.HEX)
local ai0 = define(ProtoField.float, "ai0", "AI 0")
local ai1 = define(ProtoField.float, "ai1", "AI 1")
local banner = define(ProtoField.uint16, "banner", "Banner ID To Respond To", base.DEC)
local damage = define(ProtoField.int16, "damage", "Damage", base.DEC)
local knockback = define(ProtoField.float, "knockback", "Knockback")
local original_damage = define(ProtoField.int16, "original_damage", "Original Damage", base.DEC)
local ai2 = define(ProtoField.float, "ai2", "AI 2")

local AI0 = 0x01
local AI1 = 0x02
local HAS_FLAGS2 = 0x04
local BANNER = 0x08
local DAMAGE = 0x10
local KNOCKBACK = 0x20
local ORIGINAL_DAMAGE = 0x40
local FLAGS2_AI2 = 0x01

---@param payload PayloadReader
local function build_projectile(payload)
	projectile_key.read(payload, key_fields)
	payload:vector2(position, position_x, position_y)
	payload:vector2(velocity, velocity_x, velocity_y)
	payload:int16_le(projectile_type)

	local flags_value = payload:uint8(flags)
	local flags2_value = 0
	if (flags_value & HAS_FLAGS2) ~= 0 then
		flags2_value = payload:uint8(flags2)
	end

	if (flags_value & AI0) ~= 0 then payload:single_le(ai0) end
	if (flags_value & AI1) ~= 0 then payload:single_le(ai1) end
	if (flags_value & BANNER) ~= 0 then payload:uint16_le(banner) end
	if (flags_value & DAMAGE) ~= 0 then payload:int16_le(damage) end
	if (flags_value & KNOCKBACK) ~= 0 then payload:single_le(knockback) end
	if (flags_value & ORIGINAL_DAMAGE) ~= 0 then payload:int16_le(original_damage) end
	if (flags2_value & FLAGS2_AI2) ~= 0 then payload:single_le(ai2) end
end

---@param payload PayloadReader
local function build(payload)
	payload:group(root, build_projectile)
end

return {
	id = 27,
	build = build,
	fields = fields,
}
