-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_chest_item.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local chest_id = ProtoField.int16("terraria.sync_chest_item.chest_id", "Chest ID", base.DEC)
local item_slot = ProtoField.uint8("terraria.sync_chest_item.item_slot", "Item Slot", base.DEC)
local stack = ProtoField.int16("terraria.sync_chest_item.stack", "Stack", base.DEC)
local prefix = ProtoField.uint8("terraria.sync_chest_item.prefix", "Prefix", base.DEC)
local item_net_id = ProtoField.int16("terraria.sync_chest_item.item_net_id", "Item Net ID", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(chest_id)
	payload:uint8(item_slot)
	payload:int16_le(stack)
	payload:uint8(prefix)
	payload:int16_le(item_net_id)
end

return {
	id = 32,
	build = build,
	fields = {
		chest_id,
		item_slot,
		stack,
		prefix,
		item_net_id,
	},
}
