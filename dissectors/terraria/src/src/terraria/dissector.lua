-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/dissector.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local PayloadDissector = require("terraria.payload.dissector")
local context = require("terraria.context")
local packet_catalog = require("terraria.game.packet_catalog")

local M = {}

---@class FrameInfo
---@field pinfo PInfo
---@field written boolean
local FrameInfo = {}
FrameInfo.__index = FrameInfo

---@param pinfo PInfo
---@return FrameInfo
function FrameInfo.new(pinfo)
	return setmetatable({ pinfo = pinfo, written = false }, FrameInfo)
end

---@param text string
function FrameInfo:add(text)
	---@diagnostic disable: undefined-field, inject-field
	if self.written then
		self.pinfo.cols.info:append("; " .. text)
	else
		self.pinfo.cols.protocol = "Terraria"
		self.pinfo.cols.info:set(text)
		self.written = true
	end
	---@diagnostic enable: undefined-field, inject-field
end

---@class TerrariaDissector
---@field proto Proto
---@field fields TerrariaFields
---@field payload_dissector PayloadDissector
local TerrariaDissector = {}
TerrariaDissector.__index = TerrariaDissector

---@param proto Proto
---@param fields TerrariaFields
---@return TerrariaDissector
function M.new(proto, fields)
	return setmetatable({
		proto = proto,
		fields = fields,
		payload_dissector = PayloadDissector.new(fields),
	}, TerrariaDissector)
end

---@param ctx PacketContext
---@param tree TreeItem
---@param title string
---@return TreeItem
function TerrariaDissector:add_packet_tree(ctx, tree, title)
	local subtree = tree:add(self.proto, ctx:full_range(), title)
	subtree:add_le(self.fields.length, ctx:length_range())
	subtree:add(self.fields.packet_id, ctx:id_range())
	return subtree
end

---@param ctx PacketContext
---@param tree TreeItem
---@param info FrameInfo
---@return integer
function TerrariaDissector:dissect_malformed(ctx, tree, info)
	info:add(string.format("Malformed packet id=%d len=%d", ctx.id, ctx.len))
	local subtree = self:add_packet_tree(ctx, tree, "Terraria Malformed Packet")
	subtree:add_proto_expert_info(
		self.fields.malformed_payload,
		string.format("Frame length %d is shorter than the %d-byte header", ctx.len, context.header_size())
	)
	return ctx.tvb:captured_len()
end

---@param ctx PacketContext
---@param tree TreeItem
---@param info FrameInfo
---@return integer
function TerrariaDissector:dissect_unknown(ctx, tree, info)
	info:add(string.format("Unknown packet id=%d len=%d", ctx.id, ctx.len))
	local subtree = self:add_packet_tree(ctx, tree, "Terraria Unknown Packet")
	if ctx.payload_len > 0 then
		subtree:add(self.fields.payload, ctx:payload_range())
	end
	return ctx.len
end

---@param ctx PacketContext
---@param tree TreeItem
---@param info FrameInfo
---@param packet PacketDef
---@return integer
function TerrariaDissector:dissect_known(ctx, tree, info, packet)
	info:add(string.format("Terraria %s id=%d len=%d", packet.name, ctx.id, ctx.len))

	local subtree = self:add_packet_tree(ctx, tree, "Terraria " .. packet.name)
	local payload_tree = subtree:add(self.fields.payload, ctx:payload_range())
	payload_tree:set_text("Payload")
	self.payload_dissector:dissect(ctx, payload_tree)

	return ctx.len
end

---@param tvb Tvb
---@param tree TreeItem
---@param info FrameInfo
---@return integer
function TerrariaDissector:dissect_pdu(tvb, tree, info)
	local ctx = context.new(tvb)

	if ctx:is_malformed() then
		return self:dissect_malformed(ctx, tree, info)
	end

	local packet = packet_catalog[ctx.id]
	if not packet then
		return self:dissect_unknown(ctx, tree, info)
	end

	return self:dissect_known(ctx, tree, info, packet)
end

---@param tvb Tvb
---@param pinfo PInfo
---@param tree TreeItem
function TerrariaDissector:dissect(tvb, pinfo, tree)
	local info = FrameInfo.new(pinfo)

	dissect_tcp_pdus(tvb, tree, context.header_size(), context.pdu_len, function(pdu_tvb, _, pdu_tree)
		return self:dissect_pdu(pdu_tvb, pdu_tree, info)
	end, true)
end

return M
