-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/place_object.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local x = ProtoField.int16("terraria.place_object.x", "X", base.DEC)
local y = ProtoField.int16("terraria.place_object.y", "Y", base.DEC)
local object_type = ProtoField.int16("terraria.place_object.type", "Type", base.DEC)
local style = ProtoField.int16("terraria.place_object.style", "Style", base.DEC)
local alternate = ProtoField.uint8("terraria.place_object.alternate", "Alternate", base.DEC)
local random = ProtoField.int8("terraria.place_object.random", "Random", base.DEC)
local direction = ProtoField.bool("terraria.place_object.direction", "Direction")

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(x)
	payload:int16_le(y)
	payload:int16_le(object_type)
	payload:int16_le(style)
	payload:uint8(alternate)
	payload:sbyte(random)
	payload:bool(direction)
end

return {
	id = 79,
	build = build,
	fields = {
		x,
		y,
		object_type,
		style,
		alternate,
		random,
		direction,
	},
}
