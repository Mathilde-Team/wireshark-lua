-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/wire/byte_reader.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local M = {}

-- Level 0 keeps the Lua file and line out of a message that ends up in the packet tree.
---@param message string
local function fail(message)
	error(message, 0)
end

---@class ByteReader
---@field source TvbRange
---@field cursor integer
local ByteReader = {}
ByteReader.__index = ByteReader

---@param source TvbRange
---@return ByteReader
function M.new(source)
	return setmetatable({
		source = source,
		cursor = 0,
	}, ByteReader)
end

---@return integer
function ByteReader:position()
	return self.cursor
end

---@return integer
function ByteReader:remaining()
	return self.source:len() - self.cursor
end

---@param len integer
---@return TvbRange
function ByteReader:range(len)
	if len < 0 then
		fail("byte reader range length must be non-negative")
	end
	if self:remaining() < len then
		fail(string.format(
			"byte reader out of bounds: position=%d len=%d remaining=%d",
			self.cursor,
			len,
			self:remaining()
		))
	end

	local range = self.source:range(self.cursor, len)
	self.cursor = self.cursor + len
	return range
end

---@param start integer
---@return TvbRange
function ByteReader:range_from(start)
	if start < 0 or start > self.cursor then
		fail(string.format("byte reader range start %d is outside 0..%d", start, self.cursor))
	end
	return self.source:range(start, self.cursor - start)
end

---@return integer
---@return TvbRange
function ByteReader:uint8()
	local range = self:range(1)
	return range:uint(), range
end

---@return integer
---@return TvbRange
function ByteReader:sbyte()
	local range = self:range(1)
	return range:int(), range
end

---@return integer
---@return TvbRange
function ByteReader:uint16_le()
	local range = self:range(2)
	return range:le_uint(), range
end

---@return integer
function ByteReader:peek_uint16_le()
	local start = self.cursor
	local value = self:uint16_le()
	self.cursor = start
	return value
end

---@return integer
---@return TvbRange
function ByteReader:int16_le()
	local range = self:range(2)
	return range:le_int(), range
end

---@return integer
---@return TvbRange
function ByteReader:uint32_le()
	local range = self:range(4)
	return range:le_uint(), range
end

---@return integer
---@return TvbRange
function ByteReader:int32_le()
	local range = self:range(4)
	return range:le_int(), range
end

---@return UInt64
---@return TvbRange
function ByteReader:uint64_le()
	local range = self:range(8)
	return range:le_uint64(), range
end

---@return number
---@return TvbRange
function ByteReader:single_le()
	local range = self:range(4)
	return range:le_float(), range
end

--- .NET Write7BitEncodedInt.
---@return integer
---@return TvbRange
function ByteReader:var_u32()
	local start = self.cursor
	local result = 0
	local shift = 0

	for _ = 1, 5 do
		local byte = self:uint8()
		result = result | ((byte & 0x7F) << shift)
		if (byte & 0x80) == 0 then
			return result, self:range_from(start)
		end
		shift = shift + 7
	end

	error("invalid 7-bit encoded integer", 0)
end

--- .NET BinaryWriter.Write(string).
---@return string
---@return TvbRange
function ByteReader:string()
	local start = self.cursor
	local len = self:var_u32()
	local text = self:range(len):string(ENC_UTF_8)
	return text, self:range_from(start)
end

---@return boolean
---@return TvbRange
function ByteReader:bool()
	local value, range = self:uint8()
	return value ~= 0, range
end

---@param len integer
---@return string
---@return TvbRange
function ByteReader:bytes(len)
	local range = self:range(len)
	return range:raw(), range
end

return M
