-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_npc.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local fields = {}

---@param factory fun(name: string, label: string, display: any): ProtoField
---@param name string
---@param label string
---@param display any
---@return ProtoField
local function define(factory, name, label, display)
	local field = factory("terraria.sync_npc." .. name, label, display)
	fields[#fields + 1] = field
	return field
end

local root = define(ProtoField.bytes, "root", "NPC Update")
local npc_index = define(ProtoField.uint8, "npc_index", "NPC Index", base.DEC)
local generation = define(ProtoField.uint8, "generation", "Generation", base.DEC)
local position = define(ProtoField.bytes, "position", "Position")
local position_x = define(ProtoField.float, "position_x", "Position X")
local position_y = define(ProtoField.float, "position_y", "Position Y")
local velocity = define(ProtoField.bytes, "velocity", "Velocity")
local velocity_x = define(ProtoField.float, "velocity_x", "Velocity X")
local velocity_y = define(ProtoField.float, "velocity_y", "Velocity Y")
local target = define(ProtoField.uint16, "target", "Target", base.DEC)
local flags1 = define(ProtoField.uint8, "flags1", "NPC Flags 1", base.HEX)
local flags2 = define(ProtoField.uint8, "flags2", "NPC Flags 2", base.HEX)
local ai_group = define(ProtoField.bytes, "ai", "AI")
local ai = {
	define(ProtoField.float, "ai0", "AI 0"),
	define(ProtoField.float, "ai1", "AI 1"),
	define(ProtoField.float, "ai2", "AI 2"),
	define(ProtoField.float, "ai3", "AI 3"),
}
local npc_net_id = define(ProtoField.int16, "npc_net_id", "NPC Net ID", base.DEC)
local difficulty_player_count = define(
	ProtoField.uint8,
	"difficulty_player_count",
	"Difficulty Player Count",
	base.DEC
)
local strength_multiplier = define(ProtoField.float, "strength_multiplier", "Strength Multiplier")
local life_group = define(ProtoField.bytes, "life_group", "Life")
local life_bytes = define(ProtoField.uint8, "life_bytes", "Life Bytes", base.DEC)
local life = define(ProtoField.int32, "life", "Life", base.DEC)
local life_raw = define(ProtoField.bytes, "life_raw", "Raw Life")
local release_owner = define(ProtoField.uint8, "release_owner", "Release Owner", base.DEC)

local AI_FLAGS = { 0x04, 0x08, 0x10, 0x20 }
local LIFE_MAX = 0x80
local STATS_SCALED = 0x01
local STRENGTH_MULTIPLIER = 0x04

local LIFE_READER_BY_SIZE = {
	[1] = "sbyte",
	[2] = "int16_le",
	[4] = "int32_le",
}

---@param payload PayloadReader
---@param flags integer
local function build_ai(payload, flags)
	local any = false
	for _, flag in ipairs(AI_FLAGS) do
		any = any or (flags & flag) ~= 0
	end
	if not any then
		return
	end

	payload:group(ai_group, function(payload)
		for index, flag in ipairs(AI_FLAGS) do
			if (flags & flag) ~= 0 then
				payload:single_le(ai[index])
			end
		end
	end)
end

---@param payload PayloadReader
local function build_life(payload)
	payload:group(life_group, function(payload)
		local size = payload:uint8(life_bytes)
		local read = LIFE_READER_BY_SIZE[size]

		if read then
			payload[read](payload, life)
		elseif size > 0 then
			payload:bytes(life_raw, size)
		end
	end)
end

---@param payload PayloadReader
local function build_npc(payload)
	payload:uint8(npc_index)
	payload:uint8(generation)
	payload:vector2(position, position_x, position_y)
	payload:vector2(velocity, velocity_x, velocity_y)
	payload:uint16_le(target)
	local flags1_value = payload:uint8(flags1)
	local flags2_value = payload:uint8(flags2)

	build_ai(payload, flags1_value)
	payload:int16_le(npc_net_id)

	if (flags2_value & STATS_SCALED) ~= 0 then
		payload:uint8(difficulty_player_count)
	end
	if (flags2_value & STRENGTH_MULTIPLIER) ~= 0 then
		payload:single_le(strength_multiplier)
	end
	if (flags1_value & LIFE_MAX) == 0 then
		build_life(payload)
	end

	-- Only catchable critters carry it; without the game's table, presence is the only sign.
	if payload:remaining() > 0 then
		payload:uint8(release_owner)
	end
end

---@param payload PayloadReader
local function build(payload)
	payload:group(root, build_npc)
end

return {
	id = 23,
	build = build,
	fields = fields,
}
