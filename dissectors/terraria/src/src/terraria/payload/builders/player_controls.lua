-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/player_controls.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local fields = {}

---@param factory fun(name: string, label: string, display: any): ProtoField
---@param name string
---@param label string
---@param display any
---@return ProtoField
local function define(factory, name, label, display)
	local field = factory("terraria.player_controls." .. name, label, display)
	fields[#fields + 1] = field
	return field
end

---@param name string
---@param label string
---@return { group: ProtoField, x: ProtoField, y: ProtoField }
local function define_vector(name, label)
	return {
		group = define(ProtoField.bytes, name, label),
		x = define(ProtoField.float, name .. "_x", label .. " X"),
		y = define(ProtoField.float, name .. "_y", label .. " Y"),
	}
end

local root = define(ProtoField.bytes, "root", "Update Player")
local player_id = define(ProtoField.uint8, "player_id", "Player ID", base.DEC)
local control = define(ProtoField.uint8, "control", "Control", base.HEX)
local pulley = define(ProtoField.uint8, "pulley", "Pulley", base.HEX)
local misc = define(ProtoField.uint8, "misc", "Misc", base.HEX)
local sleeping_info = define(ProtoField.uint8, "sleeping_info", "Sleeping Info", base.HEX)
local selected_item = define(ProtoField.uint8, "selected_item", "Selected Item", base.DEC)
local position = define_vector("position", "Position")
local velocity = define_vector("velocity", "Velocity")
local original_position = define_vector("original_position", "Original Position")
local home_position = define_vector("home_position", "Home Position")
local mount_type = define(ProtoField.uint16, "mount_type", "Mount Type", base.DEC)
local camera_target = define_vector("camera_target", "Camera Target")

local UPDATE_VELOCITY = 0x04
local HAS_MOUNT = 0x80
local USED_POTION_OF_RETURN = 0x40
local HAS_CAMERA_TARGET = 0x20

---@param payload PayloadReader
---@param vector { group: ProtoField, x: ProtoField, y: ProtoField }
local function read_vector(payload, vector)
	payload:vector2(vector.group, vector.x, vector.y)
end

---@param payload PayloadReader
local function build_player(payload)
	payload:uint8(player_id)
	payload:uint8(control)
	local pulley_value = payload:uint8(pulley)
	local misc_value = payload:uint8(misc)
	local sleeping_value = payload:uint8(sleeping_info)
	payload:uint8(selected_item)
	read_vector(payload, position)

	if (pulley_value & UPDATE_VELOCITY) ~= 0 then
		read_vector(payload, velocity)
	end
	if (pulley_value & HAS_MOUNT) ~= 0 then
		payload:uint16_le(mount_type)
	end
	if (misc_value & USED_POTION_OF_RETURN) ~= 0 then
		read_vector(payload, original_position)
		read_vector(payload, home_position)
	end
	if (sleeping_value & HAS_CAMERA_TARGET) ~= 0 then
		read_vector(payload, camera_target)
	end
end

---@param payload PayloadReader
local function build(payload)
	payload:group(root, build_player)
end

return {
	id = 13,
	build = build,
	fields = fields,
}
