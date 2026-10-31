-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/player_spawn.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.player_spawn.player_id",
	"Player ID",
	base.DEC
)
local spawn_position = ProtoField.bytes("terraria.player_spawn.position", "Spawn Position")
local spawn_x = ProtoField.int16(
	"terraria.player_spawn.spawn_x",
	"Spawn X",
	base.DEC
)
local spawn_y = ProtoField.int16(
	"terraria.player_spawn.spawn_y",
	"Spawn Y",
	base.DEC
)
local spawn_state = ProtoField.bytes("terraria.player_spawn.state", "Spawn State")
local respawn_time = ProtoField.int32(
	"terraria.player_spawn.respawn_time",
	"Respawn Time Remaining",
	base.DEC
)
local deaths_pve = ProtoField.int16("terraria.player_spawn.deaths_pve", "PvE Deaths", base.DEC)
local deaths_pvp = ProtoField.int16("terraria.player_spawn.deaths_pvp", "PvP Deaths", base.DEC)
local team = ProtoField.uint8("terraria.player_spawn.team", "Team", base.DEC)
local spawn_context = ProtoField.uint8(
	"terraria.player_spawn.context",
	"Player Spawn Context",
	base.DEC,
	{
		[0] = "ReviveFromDeath",
		[1] = "SpawningIntoWorld",
		[2] = "RecallFromItem",
	}
)

---@param payload PayloadReader
local function build_spawn_state(payload)
	payload:int32_le(respawn_time)
	payload:int16_le(deaths_pve)
	payload:int16_le(deaths_pvp)
	payload:uint8(team)
	payload:uint8(spawn_context)
end

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:group(spawn_position, function(payload)
		payload:int16_le(spawn_x)
		payload:int16_le(spawn_y)
	end)
	payload:group(spawn_state, build_spawn_state)
end

return {
	id = 12,
	build = build,
	fields = {
		player_id,
		spawn_position,
		spawn_x,
		spawn_y,
		spawn_state,
		respawn_time,
		deaths_pve,
		deaths_pvp,
		team,
		spawn_context,
	},
}
