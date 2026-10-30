-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_item.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local fields = {}

---@param factory fun(name: string, label: string, display: any): ProtoField
---@param name string
---@param label string
---@param display any
---@return ProtoField
local function define(factory, name, label, display)
	local field = factory("terraria.sync_item." .. name, label, display)
	fields[#fields + 1] = field
	return field
end

local root = define(ProtoField.bytes, "root", "Sync Item")
local item_id = define(ProtoField.int16, "item_id", "Item ID", base.DEC)
local position = define(ProtoField.bytes, "position", "Position")
local position_x = define(ProtoField.float, "position_x", "Position X")
local position_y = define(ProtoField.float, "position_y", "Position Y")
local velocity = define(ProtoField.bytes, "velocity", "Velocity")
local velocity_x = define(ProtoField.float, "velocity_x", "Velocity X")
local velocity_y = define(ProtoField.float, "velocity_y", "Velocity Y")
local item = define(ProtoField.bytes, "item", "Item")
local stack_size = define(ProtoField.int16, "stack_size", "Stack Size", base.DEC)
local prefix = define(ProtoField.uint8, "prefix", "Prefix", base.DEC)
local item_flags = define(ProtoField.uint8, "flags", "Item Flags", base.HEX)
local item_net_id = define(ProtoField.int16, "item_net_id", "Item Net ID", base.DEC)
local shimmered = define(ProtoField.bool, "shimmered", "Shimmered")
local shimmer_time = define(ProtoField.float, "shimmer_time", "Shimmer Time")
local enemy_grab_delay = define(ProtoField.uint8, "enemy_grab_delay", "Enemy Grab Delay", base.DEC)

local HAS_SHIMMER = 0x04
local HAS_GRAB_DELAY = 0x08

---@param payload PayloadReader
local function build_item(payload)
	payload:int16_le(stack_size)
	payload:uint8(prefix)
	local flags = payload:uint8(item_flags)
	payload:int16_le(item_net_id)

	if (flags & HAS_SHIMMER) ~= 0 then
		payload:bool(shimmered)
		payload:single_le(shimmer_time)
	end
	if (flags & HAS_GRAB_DELAY) ~= 0 then
		payload:uint8(enemy_grab_delay)
	end
end

---@param payload PayloadReader
local function build(payload)
	payload:group(root, function(payload)
		payload:int16_le(item_id)
		payload:vector2(position, position_x, position_y)
		payload:vector2(velocity, velocity_x, velocity_y)
		payload:group(item, build_item)
	end)
end

return {
	id = 21,
	build = build,
	fields = fields,
}
