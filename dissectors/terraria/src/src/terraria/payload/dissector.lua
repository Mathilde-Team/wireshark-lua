-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/dissector.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local decoders = require("terraria.payload.registry")
local byte_reader = require("terraria.payload.wire.byte_reader")
local payload_reader = require("terraria.payload.reader")

---@alias PayloadBuilder fun(payload: PayloadReader)

local M = {}

---@class PayloadDissector
---@field fields TerrariaFields
local PayloadDissector = {}
PayloadDissector.__index = PayloadDissector

---@param fields TerrariaFields
---@return PayloadDissector
function M.new(fields)
	return setmetatable({ fields = fields }, PayloadDissector)
end

--- Only for packets in the catalog: the registry guarantees each has a decoder.
---@param ctx PacketContext
---@param tree TreeItem
function PayloadDissector:dissect(ctx, tree)
	local reader = byte_reader.new(ctx:payload_range())
	local ok, err = pcall(decoders[ctx.id], payload_reader.new(reader, tree))

	if not ok then
		self:report_malformed_payload(ctx, tree, err)
		return
	end

	self:report_unread_payload(ctx, tree, reader)
end

---@param ctx PacketContext
---@param tree TreeItem
---@param err any
function PayloadDissector:report_malformed_payload(ctx, tree, err)
	tree:add_proto_expert_info(
		self.fields.malformed_payload,
		string.format("Failed to decode payload for packet id=%d: %s", ctx.id, tostring(err))
	)
end

---@param ctx PacketContext
---@param tree TreeItem
---@param reader ByteReader
function PayloadDissector:report_unread_payload(ctx, tree, reader)
	local remaining = reader:remaining()
	if remaining == 0 then
		return
	end

	local item = tree:add(self.fields.unread_payload, reader:range(remaining))
	item:add_proto_expert_info(
		self.fields.unread_payload_expert,
		string.format("Packet id=%d has %d unread payload byte(s)", ctx.id, remaining)
	)
end

return M
