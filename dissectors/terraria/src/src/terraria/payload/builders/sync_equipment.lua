-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_equipment.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local slot = ProtoField.bytes("terraria.sync_equipment.slot", "Slot")
local player_id = ProtoField.uint8(
	"terraria.sync_equipment.player_id",
	"Player ID",
	base.DEC
)
local slot_id = ProtoField.uint16(
	"terraria.sync_equipment.slot_id",
	"Slot ID",
	base.DEC
)
local item = ProtoField.bytes("terraria.sync_equipment.item", "Item")
local stack = ProtoField.int16(
	"terraria.sync_equipment.stack",
	"Stack",
	base.DEC
)
local prefix = ProtoField.uint8(
	"terraria.sync_equipment.prefix",
	"Prefix",
	base.DEC
)
local item_net_id = ProtoField.int16(
	"terraria.sync_equipment.item_net_id",
	"Item Net ID",
	base.DEC
)
---@type BaseEnum
---@diagnostic disable-next-line: assign-type-mismatch
local PARENT_FIELD_BITS = 8
local slot_flags = ProtoField.uint8(
	"terraria.sync_equipment.flags",
	"Slot Flags",
	base.HEX
)
local favorited = ProtoField.bool(
	"terraria.sync_equipment.favorited",
	"Favorited",
	PARENT_FIELD_BITS,
	nil,
	0x01
)
local blocked = ProtoField.bool(
	"terraria.sync_equipment.blocked",
	"Blocked",
	PARENT_FIELD_BITS,
	nil,
	0x02
)

---@param payload PayloadReader
local function build_slot(payload)
	payload:uint8(player_id)
	payload:uint16_le(slot_id)
end

---@param payload PayloadReader
local function build_item(payload)
	payload:int16_le(stack)
	payload:uint8(prefix)
	payload:int16_le(item_net_id)
end

---@param payload PayloadReader
local function build(payload)
	payload:group(slot, build_slot)
	payload:group(item, build_item)

	payload:bits(slot_flags, { favorited, blocked })
end

return {
	id = 5,
	build = build,
	fields = {
		slot,
		player_id,
		slot_id,
		item,
		stack,
		prefix,
		item_net_id,
		slot_flags,
		favorited,
		blocked,
	},
}
