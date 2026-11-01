-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/fields.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local decoder_fields = require("terraria.payload.fields")
local packet_catalog = require("terraria.game.packet_catalog")

---@class TerrariaFields
---@field length ProtoField
---@field packet_id ProtoField
---@field payload ProtoField
---@field unread_payload ProtoField
---@field malformed_payload ProtoExpert
---@field unread_payload_expert ProtoExpert
---@field experts ProtoExpert[]
---@field list ProtoField[]

local packet_names = {}
for id, packet in pairs(packet_catalog) do
	packet_names[id] = packet.name
end

local length = ProtoField.uint16("terraria.length", "Frame Length", base.DEC)
local packet_id = ProtoField.uint8("terraria.id", "Packet ID", base.DEC, packet_names)
local payload = ProtoField.bytes("terraria.payload", "Payload")
local unread_payload = ProtoField.bytes("terraria.payload.unread", "Unread Payload")

local malformed_payload = ProtoExpert.new(
	"terraria.expert.malformed_payload",
	"Malformed Terraria payload",
	expert.group.MALFORMED,
	expert.severity.ERROR
)
local unread_payload_expert = ProtoExpert.new(
	"terraria.expert.unread_payload",
	"Payload contains unread bytes",
	expert.group.PROTOCOL,
	expert.severity.WARN
)

local list = { length, packet_id, payload, unread_payload }
for _, field in ipairs(decoder_fields) do
	list[#list + 1] = field
end

---@type TerrariaFields
return {
	length = length,
	packet_id = packet_id,
	payload = payload,
	unread_payload = unread_payload,
	malformed_payload = malformed_payload,
	unread_payload_expert = unread_payload_expert,
	experts = { malformed_payload, unread_payload_expert },
	list = list,
}
