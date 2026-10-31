-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/te_hat_rack_item_sync.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.te_hat_rack_item_sync.player_id", "Player ID", base.DEC)
local tile_entity_id = ProtoField.int32(
	"terraria.te_hat_rack_item_sync.tile_entity_id",
	"Tile Entity ID",
	base.DEC
)
local item_index = ProtoField.uint8("terraria.te_hat_rack_item_sync.item_index", "Item Index", base.DEC)
local item_id = ProtoField.uint16("terraria.te_hat_rack_item_sync.item_id", "Item ID", base.DEC)
local stack = ProtoField.uint16("terraria.te_hat_rack_item_sync.stack", "Stack", base.DEC)
local prefix = ProtoField.uint8("terraria.te_hat_rack_item_sync.prefix", "Prefix", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int32_le(tile_entity_id)
	payload:uint8(item_index)
	payload:uint16_le(item_id)
	payload:uint16_le(stack)
	payload:uint8(prefix)
end

return {
	id = 124,
	build = build,
	fields = {
		player_id,
		tile_entity_id,
		item_index,
		item_id,
		stack,
		prefix,
	},
}
