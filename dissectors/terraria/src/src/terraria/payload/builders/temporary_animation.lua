-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/temporary_animation.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local animation_type = ProtoField.int16(
	"terraria.temporary_animation.animation_type",
	"Animation Type",
	base.DEC
)
local tile_type = ProtoField.uint16(
	"terraria.temporary_animation.tile_type",
	"Tile Type",
	base.DEC
)
local x = ProtoField.int16("terraria.temporary_animation.x", "X", base.DEC)
local y = ProtoField.int16("terraria.temporary_animation.y", "Y", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(animation_type)
	payload:uint16_le(tile_type)
	payload:int16_le(x)
	payload:int16_le(y)
end

return {
	id = 77,
	build = build,
	fields = {
		animation_type,
		tile_type,
		x,
		y,
	},
}
