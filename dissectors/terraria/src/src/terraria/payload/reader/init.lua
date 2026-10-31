-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/reader/init.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local base = require("terraria.payload.reader.base")
local groups = require("terraria.payload.reader.groups")

--- Every read consumes bytes, shows them as one tree item and returns the value. `reader` and
--- `tree` are private so that no decoder consumes bytes without showing them.
---@class PayloadReader
---@field private reader ByteReader
---@field private tree TreeItem
---@field remaining fun(self: PayloadReader): integer
---@field peek_uint16_le fun(self: PayloadReader): integer
---@field string fun(self: PayloadReader, field: ProtoField): string
---@field color fun(self: PayloadReader, field: ProtoField): integer, integer, integer
---@field bool fun(self: PayloadReader, field: ProtoField): boolean
---@field uint8 fun(self: PayloadReader, field: ProtoField): integer
---@field sbyte fun(self: PayloadReader, field: ProtoField): integer
---@field uint16_le fun(self: PayloadReader, field: ProtoField): integer
---@field int16_le fun(self: PayloadReader, field: ProtoField): integer
---@field uint32_le fun(self: PayloadReader, field: ProtoField): integer
---@field int32_le fun(self: PayloadReader, field: ProtoField): integer
---@field uint64_le fun(self: PayloadReader, field: ProtoField): UInt64
---@field single_le fun(self: PayloadReader, field: ProtoField): number
---@field var_u32 fun(self: PayloadReader, field: ProtoField): integer
---@field bits fun(self: PayloadReader, field: ProtoField, bit_fields: ProtoField[], size: integer?): integer
---@field vector2 fun(self: PayloadReader, group_field: ProtoField, x_field: ProtoField, y_field: ProtoField): number, number
---@field guid fun(self: PayloadReader, field: ProtoField)
---@field bytes fun(self: PayloadReader, field: ProtoField, len: integer): string
---@field remaining_bytes fun(self: PayloadReader, field: ProtoField): string
---@field group fun(self: PayloadReader, field: ProtoField, read: fun(payload: PayloadReader)): TreeItem
local PayloadReader = {}
PayloadReader.__index = PayloadReader

for _, module in ipairs({ base, groups }) do
	for name, fn in pairs(module) do
		PayloadReader[name] = fn
	end
end

---@param reader ByteReader
---@param tree TreeItem
---@return PayloadReader
function PayloadReader.new(reader, tree)
	return setmetatable({
		reader = reader,
		tree = tree,
	}, PayloadReader)
end

return PayloadReader
