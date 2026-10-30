-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/tile_entity_sharing.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local fields = {}

---@param factory fun(name: string, label: string, display: any, valuestring: any?): ProtoField
---@param name string
---@param label string
---@param display any
---@param valuestring any?
---@return ProtoField
local function define(factory, name, label, display, valuestring)
	local field = factory("terraria.tile_entity_sharing." .. name, label, display, valuestring)
	fields[#fields + 1] = field
	return field
end

local TRAINING_DUMMY = 0
local ITEM_FRAME = 1
local LOGIC_SENSOR = 2
local DISPLAY_DOLL = 3
local WEAPONS_RACK = 4
local HAT_RACK = 5
local FOOD_PLATTER = 6
local TELEPORTATION_PYLON = 7
local DEAD_CELLS_DISPLAY_JAR = 8
local KITE_ANCHOR = 9
local CRITTER_ANCHOR = 10

local HOLDS_ONE_ITEM = {
	[ITEM_FRAME] = true,
	[WEAPONS_RACK] = true,
	[FOOD_PLATTER] = true,
	[DEAD_CELLS_DISPLAY_JAR] = true,
}
local ANCHORS = { [KITE_ANCHOR] = true, [CRITTER_ANCHOR] = true }
local SENDS_NO_DATA = { [LOGIC_SENSOR] = true, [TELEPORTATION_PYLON] = true }

local tile_entity_id = define(ProtoField.int32, "tile_entity_id", "Tile Entity ID", base.DEC)
local entity_present = define(ProtoField.bool, "update_tile_flag", "Entity Present")
local tile_entity_type = define(ProtoField.uint8, "tile_entity_type", "Tile Entity Type", base.DEC, {
	[0] = "TrainingDummy",
	[1] = "ItemFrame",
	[2] = "LogicSensor",
	[3] = "DisplayDoll",
	[4] = "WeaponsRack",
	[5] = "HatRack",
	[6] = "FoodPlatter",
	[7] = "TeleportationPylon",
	[8] = "DeadCellsDisplayJar",
	[9] = "KiteAnchor",
	[10] = "CritterAnchor",
})
local x = define(ProtoField.int16, "x", "X", base.DEC)
local y = define(ProtoField.int16, "y", "Y", base.DEC)
local extra_data = define(ProtoField.bytes, "extra_data", "Extra Data")
local npc_index = define(ProtoField.int16, "npc_index", "NPC Index", base.DEC)
local item = define(ProtoField.bytes, "item", "Item")
local item_id = define(ProtoField.int16, "item_id", "Item ID", base.DEC)
local item_prefix = define(ProtoField.uint8, "item_prefix", "Prefix", base.DEC)
local item_stack = define(ProtoField.int16, "item_stack", "Stack", base.DEC)
local equip_flags = define(ProtoField.uint8, "equip_flags", "Equip Flags", base.HEX)
local dye_flags = define(ProtoField.uint8, "dye_flags", "Dye Flags", base.HEX)
local pose = define(ProtoField.uint8, "pose", "Pose", base.DEC)
local extra_flags = define(ProtoField.uint8, "extra_flags", "Extra Slot Flags", base.HEX)
local rack_flags = define(ProtoField.uint8, "rack_flags", "Slot Flags", base.HEX)
local anchor_item = define(ProtoField.int16, "anchor_item", "Anchored Item", base.DEC)

---@param payload PayloadReader
---@param label string
local function read_item(payload, label)
	local tree = payload:group(item, function(payload)
		payload:int16_le(item_id)
		payload:uint8(item_prefix)
		payload:int16_le(item_stack)
	end)
	tree:set_text(label)
end

---@param payload PayloadReader
---@param flags integer
---@param first_bit integer
---@param count integer
---@param label string
local function read_slots(payload, flags, first_bit, count, label)
	for slot = 1, count do
		if (flags & (1 << (first_bit + slot - 1))) ~= 0 then
			read_item(payload, string.format("%s %d", label, slot))
		end
	end
end

---@param payload PayloadReader
local function read_display_doll(payload)
	local equip = payload:uint8(equip_flags)
	local dyes = payload:uint8(dye_flags)
	payload:uint8(pose)
	local extra = payload:uint8(extra_flags)

	read_slots(payload, equip, 0, 8, "Equip")
	if (extra & 0x02) ~= 0 then
		read_item(payload, "Equip 9")
	end
	read_slots(payload, dyes, 0, 8, "Dye")
	if (extra & 0x04) ~= 0 then
		read_item(payload, "Dye 9")
	end
	if (extra & 0x01) ~= 0 then
		read_item(payload, "Misc")
	end
end

---@param payload PayloadReader
local function read_hat_rack(payload)
	local flags = payload:uint8(rack_flags)
	read_slots(payload, flags, 0, 2, "Hat")
	read_slots(payload, flags, 2, 2, "Dye")
end

---@param payload PayloadReader
---@param kind integer
local function read_extra_data(payload, kind)
	if SENDS_NO_DATA[kind] then
		return
	end

	payload:group(extra_data, function(payload)
		if kind == TRAINING_DUMMY then
			payload:int16_le(npc_index)
		elseif HOLDS_ONE_ITEM[kind] then
			read_item(payload, "Item")
		elseif kind == DISPLAY_DOLL then
			read_display_doll(payload)
		elseif kind == HAT_RACK then
			read_hat_rack(payload)
		elseif ANCHORS[kind] then
			payload:int16_le(anchor_item)
		else
			error(string.format("unsupported tile entity type: %d", kind), 0)
		end
	end)
end

---@param payload PayloadReader
local function build(payload)
	payload:int32_le(tile_entity_id)

	if payload:bool(entity_present) then
		local kind = payload:uint8(tile_entity_type)
		payload:int16_le(x)
		payload:int16_le(y)
		read_extra_data(payload, kind)
	end
end

return {
	id = 86,
	build = build,
	fields = fields,
}
