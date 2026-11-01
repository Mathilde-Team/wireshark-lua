-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/tile_frame_section.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local start_position = ProtoField.bytes("terraria.tile_frame_section.start", "Start")
local start_x = ProtoField.int16(
	"terraria.tile_frame_section.start_x",
	"Start X",
	base.DEC
)
local start_y = ProtoField.int16(
	"terraria.tile_frame_section.start_y",
	"Start Y",
	base.DEC
)
local end_position = ProtoField.bytes("terraria.tile_frame_section.end", "End")
local end_x = ProtoField.int16(
	"terraria.tile_frame_section.end_x",
	"End X",
	base.DEC
)
local end_y = ProtoField.int16(
	"terraria.tile_frame_section.end_y",
	"End Y",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:group(start_position, function(payload)
		payload:int16_le(start_x)
		payload:int16_le(start_y)
	end)
	payload:group(end_position, function(payload)
		payload:int16_le(end_x)
		payload:int16_le(end_y)
	end)
end

return {
	id = 11,
	build = build,
	fields = {
		start_position,
		start_x,
		start_y,
		end_position,
		end_x,
		end_y,
	},
}
