-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/teleport_player_through_portal.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.teleport_player_through_portal.player_id",
	"Player ID",
	base.DEC
)
local portal_color_index = ProtoField.int16(
	"terraria.teleport_player_through_portal.portal_color_index",
	"Portal Color Index",
	base.DEC
)
local new_position_x = ProtoField.float(
	"terraria.teleport_player_through_portal.new_position_x",
	"New Position X"
)
local new_position_y = ProtoField.float(
	"terraria.teleport_player_through_portal.new_position_y",
	"New Position Y"
)
local velocity_x = ProtoField.float(
	"terraria.teleport_player_through_portal.velocity_x",
	"Velocity X"
)
local velocity_y = ProtoField.float(
	"terraria.teleport_player_through_portal.velocity_y",
	"Velocity Y"
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int16_le(portal_color_index)
	payload:single_le(new_position_x)
	payload:single_le(new_position_y)
	payload:single_le(velocity_x)
	payload:single_le(velocity_y)
end

return {
	id = 96,
	build = build,
	fields = {
		player_id,
		portal_color_index,
		new_position_x,
		new_position_y,
		velocity_x,
		velocity_y,
	},
}
