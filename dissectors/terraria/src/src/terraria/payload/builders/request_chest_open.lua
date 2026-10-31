-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/request_chest_open.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local tile_x = ProtoField.int16("terraria.request_chest_open.tile_x", "Tile X", base.DEC)
local tile_y = ProtoField.int16("terraria.request_chest_open.tile_y", "Tile Y", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(tile_x)
	payload:int16_le(tile_y)
end

return {
	id = 31,
	build = build,
	fields = {
		tile_x,
		tile_y,
	},
}
