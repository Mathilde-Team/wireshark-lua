-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/toggle_door_state.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local action = ProtoField.uint8("terraria.toggle_door_state.action", "Action", base.DEC)
local tile_position = ProtoField.bytes("terraria.toggle_door_state.position", "Tile Position")
local tile_x = ProtoField.int16("terraria.toggle_door_state.tile_x", "Tile X", base.DEC)
local tile_y = ProtoField.int16("terraria.toggle_door_state.tile_y", "Tile Y", base.DEC)
local direction = ProtoField.uint8("terraria.toggle_door_state.direction", "Direction", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(action)
	payload:group(tile_position, function(payload)
		payload:int16_le(tile_x)
		payload:int16_le(tile_y)
	end)
	payload:uint8(direction)
end

return {
	id = 19,
	build = build,
	fields = {
		action,
		tile_position,
		tile_x,
		tile_y,
		direction,
	},
}
