-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_player_chest.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local active_chest = ProtoField.bytes("terraria.sync_player_chest.active_chest", "Active Chest")
local chest_id = ProtoField.int16("terraria.sync_player_chest.chest_id", "Chest ID", base.DEC)
local chest_position = ProtoField.bytes("terraria.sync_player_chest.position", "Chest Position")
local chest_x = ProtoField.int16("terraria.sync_player_chest.chest_x", "Chest X", base.DEC)
local chest_y = ProtoField.int16("terraria.sync_player_chest.chest_y", "Chest Y", base.DEC)
local name_length = ProtoField.uint8("terraria.sync_player_chest.name_length", "Name Length", base.DEC)
local chest_name = ProtoField.string("terraria.sync_player_chest.name", "Chest Name")

local MAX_NAME_LENGTH = 20

---@param payload PayloadReader
local function build_active_chest(payload)
	payload:int16_le(chest_id)
	payload:group(chest_position, function(payload)
		payload:int16_le(chest_x)
		payload:int16_le(chest_y)
	end)
	local name_length_value = payload:uint8(name_length)

	-- The length byte only says whether a name follows; the name carries its own prefix.
	if name_length_value >= 1 and name_length_value <= MAX_NAME_LENGTH then
		payload:string(chest_name)
	end
end

---@param payload PayloadReader
local function build(payload)
	payload:group(active_chest, build_active_chest)
end

return {
	id = 33,
	build = build,
	fields = {
		active_chest,
		chest_id,
		chest_position,
		chest_x,
		chest_y,
		name_length,
		chest_name,
	},
}
