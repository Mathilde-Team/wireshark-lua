-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/tile_manipulation.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local action = ProtoField.uint8("terraria.tile_manipulation.action", "Action", base.DEC)
local tile_x = ProtoField.int16("terraria.tile_manipulation.tile_x", "Tile X", base.DEC)
local tile_y = ProtoField.int16("terraria.tile_manipulation.tile_y", "Tile Y", base.DEC)
local flags1 = ProtoField.int16("terraria.tile_manipulation.flags1", "Flags 1", base.DEC)
local flags2 = ProtoField.uint8("terraria.tile_manipulation.flags2", "Flags 2", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(action)
	payload:int16_le(tile_x)
	payload:int16_le(tile_y)
	payload:int16_le(flags1)
	payload:uint8(flags2)
end

return {
	id = 17,
	build = build,
	fields = {
		action,
		tile_x,
		tile_y,
		flags1,
		flags2,
	},
}
