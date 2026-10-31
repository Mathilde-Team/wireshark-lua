-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/spawn_tile_data.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local position = ProtoField.bytes("terraria.spawn_tile_data.position", "Tile Position")
local x = ProtoField.int32("terraria.spawn_tile_data.x", "X", base.DEC)
local y = ProtoField.int32("terraria.spawn_tile_data.y", "Y", base.DEC)
local team = ProtoField.uint8("terraria.spawn_tile_data.team", "Team", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:group(position, function(payload)
		payload:int32_le(x)
		payload:int32_le(y)
	end)
	payload:uint8(team)
end

return {
	id = 8,
	build = build,
	fields = {
		position,
		x,
		y,
		team,
	},
}
