-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_tile_paint_or_coating.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local x = ProtoField.int16("terraria.sync_tile_paint_or_coating.x", "X", base.DEC)
local y = ProtoField.int16("terraria.sync_tile_paint_or_coating.y", "Y", base.DEC)
local color = ProtoField.uint8("terraria.sync_tile_paint_or_coating.color", "Color", base.DEC)
local coating = ProtoField.bool("terraria.sync_tile_paint_or_coating.coating", "Is Coating")

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(x)
	payload:int16_le(y)
	payload:uint8(color)

	if payload:remaining() > 0 then
		payload:bool(coating)
	end
end

return {
	id = 63,
	build = build,
	fields = {
		x,
		y,
		color,
		coating,
	},
}
