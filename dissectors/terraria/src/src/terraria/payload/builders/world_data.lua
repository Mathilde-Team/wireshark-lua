-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/world_data.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local fields = {}

---@param factory fun(name: string, label: string, display: any, valuestring: any?, mask: integer?): ProtoField
---@param name string
---@param label string
---@param display any
---@param valuestring any?
---@param mask integer?
---@return ProtoField
local function define(factory, name, label, display, valuestring, mask)
	local field = factory("terraria.world_data." .. name, label, display, valuestring, mask)
	fields[#fields + 1] = field
	return field
end

---@param name string
---@param label string
---@param count integer
---@param factory fun(name: string, label: string, display: any): ProtoField
---@param display any
---@return ProtoField[]
local function define_series(name, label, count, factory, display)
	local series = {}
	for index = 1, count do
		series[index] = define(
			factory,
			string.format("%s_%d", name, index),
			string.format("%s %d", label, index),
			display
		)
	end
	return series
end

local time_state = define(ProtoField.bytes, "time_state", "Time State")
local time = define(ProtoField.int32, "time", "Time", base.DEC)
local day_flags = define(ProtoField.uint8, "day_moon_info", "Day and Moon Info", base.HEX)
local day_time = define(ProtoField.bool, "day_time", "Day Time", 8, nil, 0x01)
local blood_moon = define(ProtoField.bool, "blood_moon", "Blood Moon", 8, nil, 0x02)
local eclipse = define(ProtoField.bool, "eclipse", "Eclipse", 8, nil, 0x04)
local moon_phase = define(ProtoField.uint8, "moon_phase", "Moon Phase", base.DEC)

local geometry = define(ProtoField.bytes, "geometry", "Geometry")
local max_tiles_x = define(ProtoField.int16, "max_tiles_x", "Max Tiles X", base.DEC)
local max_tiles_y = define(ProtoField.int16, "max_tiles_y", "Max Tiles Y", base.DEC)
local spawn_x = define(ProtoField.int16, "spawn_x", "Spawn X", base.DEC)
local spawn_y = define(ProtoField.int16, "spawn_y", "Spawn Y", base.DEC)
local world_surface = define(ProtoField.int16, "world_surface", "World Surface", base.DEC)
local rock_layer = define(ProtoField.int16, "rock_layer", "Rock Layer", base.DEC)

local identity = define(ProtoField.bytes, "identity", "Identity")
local world_id = define(ProtoField.int32, "world_id", "World ID", base.DEC)
local world_name = define(ProtoField.string, "world_name", "World Name")
local game_mode = define(
	ProtoField.uint8,
	"game_mode",
	"Game Mode",
	base.DEC,
	{ [0] = "Classic", [1] = "Expert", [2] = "Master", [3] = "Journey" }
)
local unique_id = define(ProtoField.guid, "unique_id", "World Unique ID")
local generator_version = define(ProtoField.uint64, "generator_version", "World Generator Version", base.DEC)
local moon_type = define(ProtoField.uint8, "moon_type", "Moon Type", base.DEC)

local backgrounds = define(ProtoField.bytes, "backgrounds", "Backgrounds")
local BACKGROUND_STYLES_IN_WIRE_ORDER = { 0, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
local background_styles = {}
for index, bg in ipairs(BACKGROUND_STYLES_IN_WIRE_ORDER) do
	background_styles[index] = define(
		ProtoField.uint8,
		string.format("background_%d", bg),
		string.format("Background Style %d", bg),
		base.DEC
	)
end
local ice_back_style = define(ProtoField.uint8, "ice_back_style", "Ice Back Style", base.DEC)
local jungle_back_style = define(ProtoField.uint8, "jungle_back_style", "Jungle Back Style", base.DEC)
local hell_back_style = define(ProtoField.uint8, "hell_back_style", "Hell Back Style", base.DEC)
local wind_speed = define(ProtoField.float, "wind_speed", "Wind Speed Target")
local cloud_number = define(ProtoField.uint8, "cloud_number", "Cloud Number", base.DEC)

local tree_layout = define(ProtoField.bytes, "tree_layout", "Tree Layout")
local tree_x = define_series("tree", "Tree X", 3, ProtoField.int32, base.DEC)
local tree_styles = define_series("tree_style", "Tree Style", 4, ProtoField.uint8, base.DEC)
local cave_back_x = define_series("cave_back", "Cave Back X", 3, ProtoField.int32, base.DEC)
local cave_styles = define_series("cave_style", "Cave Back Style", 4, ProtoField.uint8, base.DEC)
local tree_tops = define(ProtoField.bytes, "tree_tops", "Tree Tops")
local tree_top_styles = define_series("tree_top", "Tree Top Style", 13, ProtoField.uint8, base.DEC)

local events = define(ProtoField.bytes, "events", "Events")
local rain = define(ProtoField.float, "rain", "Max Raining")
local world_flags = define(ProtoField.bytes, "world_flags", "World Flags")

local UNDOCUMENTED_BIT = false
local BIT_ORDER_UNDOCUMENTED = {}

local FLAG_NAMES = {
	{ "shadow_orb_smashed", "downed_boss1", "downed_boss2", "downed_boss3", "hard_mode", "downed_clown", "server_side_character", "downed_plantera" },
	{ "downed_mech1", "downed_mech2", "downed_mech3", "downed_mech_any", "cloud_background", "crimson", "pumpkin_moon", "snow_moon" },
	{ UNDOCUMENTED_BIT, "fast_forward_to_dawn", "slime_rain", "downed_king_slime", "downed_queen_bee", "downed_fishron", "downed_martians", "downed_ancient_cultist" },
	{ "downed_moon_lord", "downed_halloween_king", "downed_halloween_tree", "downed_christmas_ice_queen", "downed_christmas_santank", "downed_christmas_tree", "downed_golem", "party_is_up" },
	{ "downed_pirates", "downed_frost_legion", "downed_goblins", "sandstorm", "army_ongoing", "downed_army_tier1", "downed_army_tier2", "downed_army_tier3" },
	{ "combat_book_used", "lantern_night", "downed_tower_solar", "downed_tower_vortex", "downed_tower_nebula", "downed_tower_stardust", "halloween_today", "christmas_today" },
	{ "bought_cat", "bought_dog", "bought_bunny", "free_cake", "drunk_world", "downed_empress_of_light", "downed_queen_slime", "get_good_world" },
	{ "tenth_anniversary", "dont_starve", "downed_deerclops", "not_the_bees", "remix_world", "unlocked_slime_blue_spawn", "combat_book_two_used", UNDOCUMENTED_BIT },
	{ "unlocked_slime_green_spawn", "unlocked_slime_old_spawn", "unlocked_slime_purple_spawn", "unlocked_slime_rainbow_spawn", "unlocked_slime_red_spawn", "unlocked_slime_yellow_spawn", "unlocked_slime_copper_spawn", "fast_forward_to_dusk" },
	BIT_ORDER_UNDOCUMENTED,
	BIT_ORDER_UNDOCUMENTED,
}

---@param name string
---@return string
local function label_of(name)
	return (name:gsub("_", " "):gsub("(%a)(%w*)", function(first, rest)
		return first:upper() .. rest
	end))
end

local flag_bytes = {}
local flag_bits = {}
for index, names in ipairs(FLAG_NAMES) do
	flag_bytes[index] = define(
		ProtoField.uint8,
		string.format("flags_%d", index),
		string.format("World Flags %d", index),
		base.HEX
	)
	flag_bits[index] = {}
	for bit, name in ipairs(names) do
		if name ~= UNDOCUMENTED_BIT then
			flag_bits[index][#flag_bits[index] + 1] = define(
				ProtoField.bool,
				"flag." .. name,
				label_of(name),
				8,
				nil,
				1 << (bit - 1)
			)
		end
	end
end

local sundial_cooldown = define(ProtoField.uint8, "sundial_cooldown", "Sundial Cooldown", base.DEC)
local moondial_cooldown = define(ProtoField.uint8, "moondial_cooldown", "Moondial Cooldown", base.DEC)

local ore_tiers = define(ProtoField.bytes, "ore_tiers", "Ore Tiers")
local ORES = { "copper", "iron", "silver", "gold", "cobalt", "mythril", "adamantite" }
local ore_fields = {}
for index, ore in ipairs(ORES) do
	ore_fields[index] = define(ProtoField.int16, ore .. "_ore", label_of(ore) .. " Ore Tier", base.DEC)
end

local invasion_type = define(ProtoField.int8, "invasion_type", "Invasion Type", base.DEC)
local lobby_id = define(ProtoField.uint64, "lobby_id", "Lobby ID", base.DEC)
local sandstorm_severity = define(ProtoField.float, "sandstorm_severity", "Sandstorm Severity")

local extra_spawns = define(ProtoField.bytes, "extra_spawns", "Extra Spawn Points")
local extra_spawn_count = define(ProtoField.uint8, "extra_spawn_count", "Extra Spawn Point Count", base.DEC)
local extra_spawn = define(ProtoField.bytes, "extra_spawn", "Extra Spawn Point")
local extra_spawn_x = define(ProtoField.int16, "extra_spawn_x", "X", base.DEC)
local extra_spawn_y = define(ProtoField.int16, "extra_spawn_y", "Y", base.DEC)

local dungeon = define(ProtoField.bytes, "dungeon", "Dungeon Position")
local dungeon_x = define(ProtoField.int16, "dungeon_x", "Dungeon X", base.DEC)
local dungeon_y = define(ProtoField.int16, "dungeon_y", "Dungeon Y", base.DEC)

---@param payload PayloadReader
---@param series ProtoField[]
---@param read fun(payload: PayloadReader, field: ProtoField)
local function read_series(payload, series, read)
	for _, field in ipairs(series) do
		read(payload, field)
	end
end

---@param payload PayloadReader
local function build_time_state(payload)
	payload:group(time_state, function(payload)
		payload:int32_le(time)
		payload:bits(day_flags, { day_time, blood_moon, eclipse })
		payload:uint8(moon_phase)
	end)
end

---@param payload PayloadReader
local function build_geometry(payload)
	payload:group(geometry, function(payload)
		payload:int16_le(max_tiles_x)
		payload:int16_le(max_tiles_y)
		payload:int16_le(spawn_x)
		payload:int16_le(spawn_y)
		payload:int16_le(world_surface)
		payload:int16_le(rock_layer)
	end)
end

---@param payload PayloadReader
local function build_identity(payload)
	payload:group(identity, function(payload)
		payload:int32_le(world_id)
		payload:string(world_name)
		payload:uint8(game_mode)
		payload:guid(unique_id)
		payload:uint64_le(generator_version)
		payload:uint8(moon_type)
	end)
end

---@param payload PayloadReader
local function build_backgrounds(payload)
	payload:group(backgrounds, function(payload)
		read_series(payload, background_styles, payload.uint8)
		payload:uint8(ice_back_style)
		payload:uint8(jungle_back_style)
		payload:uint8(hell_back_style)
		payload:single_le(wind_speed)
		payload:uint8(cloud_number)
	end)
end

---@param payload PayloadReader
local function build_tree_layout(payload)
	payload:group(tree_layout, function(payload)
		read_series(payload, tree_x, payload.int32_le)
		read_series(payload, tree_styles, payload.uint8)
		read_series(payload, cave_back_x, payload.int32_le)
		read_series(payload, cave_styles, payload.uint8)
	end)
	payload:group(tree_tops, function(payload)
		read_series(payload, tree_top_styles, payload.uint8)
	end)
end

---@param payload PayloadReader
local function build_world_flags(payload)
	payload:group(world_flags, function(payload)
		for index, byte_field in ipairs(flag_bytes) do
			payload:bits(byte_field, flag_bits[index])
		end
	end)
end

---@param payload PayloadReader
local function build_events(payload)
	payload:group(events, function(payload)
		payload:single_le(rain)
		build_world_flags(payload)
		payload:uint8(sundial_cooldown)
		payload:uint8(moondial_cooldown)
	end)
end

---@param payload PayloadReader
local function build_progression(payload)
	payload:group(ore_tiers, function(payload)
		read_series(payload, ore_fields, payload.int16_le)
	end)
	payload:sbyte(invasion_type)
	payload:uint64_le(lobby_id)
	payload:single_le(sandstorm_severity)
end

---@param payload PayloadReader
local function build_spawn_points(payload)
	payload:group(extra_spawns, function(payload)
		local count = payload:uint8(extra_spawn_count)

		for _ = 1, count do
			payload:group(extra_spawn, function(payload)
				payload:int16_le(extra_spawn_x)
				payload:int16_le(extra_spawn_y)
			end)
		end
	end)
	payload:group(dungeon, function(payload)
		payload:int16_le(dungeon_x)
		payload:int16_le(dungeon_y)
	end)
end

---@param payload PayloadReader
local function build(payload)
	build_time_state(payload)
	build_geometry(payload)
	build_identity(payload)
	build_backgrounds(payload)
	build_tree_layout(payload)
	build_events(payload)
	build_progression(payload)
	build_spawn_points(payload)
end

return {
	id = 7,
	build = build,
	fields = fields,
}
