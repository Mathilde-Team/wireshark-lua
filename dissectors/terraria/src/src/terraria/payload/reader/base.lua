-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/reader/base.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local M = {}

---@param tree TreeItem
---@param field ProtoField
---@param range TvbRange
---@param value any?
---@return TreeItem
local function add_field(tree, field, range, value)
	if value == nil then
		return tree:add(field, range)
	end
	return tree:add(field, range, value)
end

---@param tree TreeItem
---@param field ProtoField
---@param range TvbRange
---@param value any?
---@return TreeItem
local function add_le_field(tree, field, range, value)
	if value == nil then
		return tree:add_le(field, range)
	end
	return tree:add_le(field, range, value)
end

---@return integer
function M:remaining()
	return self.reader:remaining()
end

---@return integer
function M:peek_uint16_le()
	return self.reader:peek_uint16_le()
end

---@param field ProtoField
---@return string
function M:string(field)
	local value, range = self.reader:string()
	add_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return integer r
---@return integer g
---@return integer b
function M:color(field)
	local range = self.reader:range(3)
	add_field(self.tree, field, range)
	return range(0, 1):uint(), range(1, 1):uint(), range(2, 1):uint()
end

---@param field ProtoField
---@return boolean
function M:bool(field)
	local value, range = self.reader:bool()
	add_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return integer
function M:uint8(field)
	local value, range = self.reader:uint8()
	add_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return integer
function M:sbyte(field)
	local value, range = self.reader:sbyte()
	add_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return integer
function M:uint16_le(field)
	local value, range = self.reader:uint16_le()
	add_le_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return integer
function M:int16_le(field)
	local value, range = self.reader:int16_le()
	add_le_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return integer
function M:uint32_le(field)
	local value, range = self.reader:uint32_le()
	add_le_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return integer
function M:int32_le(field)
	local value, range = self.reader:int32_le()
	add_le_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return UInt64
function M:uint64_le(field)
	local value, range = self.reader:uint64_le()
	add_le_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return number
function M:single_le(field)
	local value, range = self.reader:single_le()
	add_le_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return integer
function M:var_u32(field)
	local value, range = self.reader:var_u32()
	add_field(self.tree, field, range, value)
	return value
end

local UINT_LE_READER_BY_WIDTH = {
	[1] = "uint8",
	[2] = "uint16_le",
	[4] = "uint32_le",
}

--- `bit_fields` must be declared with a mask.
---@param field ProtoField
---@param bit_fields ProtoField[]
---@param size? integer width in bytes: 1 (default), 2 or 4
---@return integer
function M:bits(field, bit_fields, size)
	local read = assert(UINT_LE_READER_BY_WIDTH[size or 1], "bitfield width must be 1, 2 or 4 bytes")
	local value, range = self.reader[read](self.reader)
	local item = add_le_field(self.tree, field, range, value)

	for _, bit_field in ipairs(bit_fields) do
		item:add_le(bit_field, range)
	end

	return value
end

---@param group_field ProtoField
---@param x_field ProtoField
---@param y_field ProtoField
---@return number x
---@return number y
function M:vector2(group_field, x_field, y_field)
	local x, y
	self:group(group_field, function(payload)
		x = payload:single_le(x_field)
		y = payload:single_le(y_field)
	end)
	return x, y
end

--- .NET Guid.ToByteArray stores the first three groups little-endian.
---@param field ProtoField
function M:guid(field)
	local range = self.reader:range(16)
	add_le_field(self.tree, field, range)
end

---@param field ProtoField
---@param len integer
---@return string
function M:bytes(field, len)
	local value, range = self.reader:bytes(len)
	add_field(self.tree, field, range, value)
	return value
end

---@param field ProtoField
---@return string
function M:remaining_bytes(field)
	return self:bytes(field, self.reader:remaining())
end

return M
