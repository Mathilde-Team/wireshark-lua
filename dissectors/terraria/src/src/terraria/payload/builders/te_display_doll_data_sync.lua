-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/te_display_doll_data_sync.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.te_display_doll_data_sync.player_id", "Player ID", base.DEC)
local tile_entity_id = ProtoField.int32(
	"terraria.te_display_doll_data_sync.tile_entity_id",
	"Tile Entity ID",
	base.DEC
)
local item_index = ProtoField.uint8("terraria.te_display_doll_data_sync.item_index", "Item Index", base.DEC)
local command = ProtoField.uint8(
	"terraria.te_display_doll_data_sync.command",
	"Command",
	base.DEC,
	{ [0] = "Equip", [1] = "Dye", [2] = "Pose", [3] = "Misc" }
)
local pose = ProtoField.uint8("terraria.te_display_doll_data_sync.pose", "Pose", base.DEC)
local item_id = ProtoField.uint16("terraria.te_display_doll_data_sync.item_id", "Item ID", base.DEC)
local stack = ProtoField.uint16("terraria.te_display_doll_data_sync.stack", "Stack", base.DEC)
local prefix = ProtoField.uint8("terraria.te_display_doll_data_sync.prefix", "Prefix", base.DEC)

local POSE = 2

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int32_le(tile_entity_id)
	payload:uint8(item_index)

	local command_value = payload:uint8(command)

	if command_value == POSE then
		payload:uint8(pose)
	else
		payload:uint16_le(item_id)
		payload:uint16_le(stack)
		payload:uint8(prefix)
	end
end

return {
	id = 121,
	build = build,
	fields = {
		player_id,
		tile_entity_id,
		item_index,
		command,
		pose,
		item_id,
		stack,
		prefix,
	},
}
