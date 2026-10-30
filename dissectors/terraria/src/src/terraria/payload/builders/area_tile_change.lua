-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/area_tile_change.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local tile_sets = require("terraria.game.tile_sets")

local fields = {}

---@param factory fun(name: string, label: string, display: any): ProtoField
---@param name string
---@param label string
---@param display any
---@return ProtoField
local function define(factory, name, label, display)
	local field = factory("terraria.area_tile_change." .. name, label, display)
	fields[#fields + 1] = field
	return field
end

local root = define(ProtoField.bytes, "root", "Area Tile Change")
local header = define(ProtoField.bytes, "header", "Header")
local tile_x = define(ProtoField.int16, "tile_x", "Tile X", base.DEC)
local tile_y = define(ProtoField.int16, "tile_y", "Tile Y", base.DEC)
local width = define(ProtoField.uint8, "width", "Width", base.DEC)
local height = define(ProtoField.uint8, "height", "Height", base.DEC)
local tile_change_type = define(ProtoField.uint8, "tile_change_type", "Tile Change Type", base.DEC)
local tiles = define(ProtoField.bytes, "tiles", "Tiles")
local tile = define(ProtoField.bytes, "tile", "Tile")
local flags1 = define(ProtoField.uint8, "flags1", "Flags 1", base.HEX)
local flags2 = define(ProtoField.uint8, "flags2", "Flags 2", base.HEX)
local flags3 = define(ProtoField.uint8, "flags3", "Flags 3", base.HEX)
local color = define(ProtoField.uint8, "color", "Tile Color", base.DEC)
local wall_color = define(ProtoField.uint8, "wall_color", "Wall Color", base.DEC)
local tile_type = define(ProtoField.uint16, "type", "Tile Type", base.DEC)
local frame_x = define(ProtoField.int16, "frame_x", "Frame X", base.DEC)
local frame_y = define(ProtoField.int16, "frame_y", "Frame Y", base.DEC)
local wall = define(ProtoField.uint16, "wall", "Wall Type", base.DEC)
local liquid = define(ProtoField.uint8, "liquid", "Liquid Amount", base.DEC)
local liquid_type = define(ProtoField.uint8, "liquid_type", "Liquid Type", base.DEC)

local ACTIVE = 0x01
local HAS_WALL = 0x04
local HAS_LIQUID = 0x08
local HAS_COLOR = 0x04
local HAS_WALL_COLOR = 0x08

---@param payload PayloadReader
local function build_tile(payload)
	local flags1_value = payload:uint8(flags1)
	local flags2_value = payload:uint8(flags2)
	payload:uint8(flags3)

	if (flags2_value & HAS_COLOR) ~= 0 then
		payload:uint8(color)
	end
	if (flags2_value & HAS_WALL_COLOR) ~= 0 then
		payload:uint8(wall_color)
	end
	if (flags1_value & ACTIVE) ~= 0 then
		local type_value = payload:uint16_le(tile_type)
		if tile_sets.is_frame_important(type_value) then
			payload:int16_le(frame_x)
			payload:int16_le(frame_y)
		end
	end
	if (flags1_value & HAS_WALL) ~= 0 then
		payload:uint16_le(wall)
	end
	if (flags1_value & HAS_LIQUID) ~= 0 then
		payload:uint8(liquid)
		payload:uint8(liquid_type)
	end
end

---@param payload PayloadReader
local function build_square(payload)
	local x, y, w, h
	payload:group(header, function(payload)
		x = payload:int16_le(tile_x)
		y = payload:int16_le(tile_y)
		w = payload:uint8(width)
		h = payload:uint8(height)
		payload:uint8(tile_change_type)
	end)

	if w * h == 0 then
		return
	end

	-- Column-major, as the game writes them.
	payload:group(tiles, function(payload)
		for dx = 0, w - 1 do
			for dy = 0, h - 1 do
				local item = payload:group(tile, build_tile)
				item:set_text(string.format("Tile (%d, %d)", x + dx, y + dy))
			end
		end
	end)
end

---@param payload PayloadReader
local function build(payload)
	payload:group(root, build_square)
end

return {
	id = 20,
	build = build,
	fields = fields,
}
