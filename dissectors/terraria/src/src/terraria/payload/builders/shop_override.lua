-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/shop_override.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local slot = ProtoField.uint8("terraria.shop_override.slot", "Slot", base.DEC)
local item_type = ProtoField.int16("terraria.shop_override.item_type", "Item Type", base.DEC)
local stack = ProtoField.int16("terraria.shop_override.stack", "Stack", base.DEC)
local prefix = ProtoField.uint8("terraria.shop_override.prefix", "Prefix", base.DEC)
local value = ProtoField.int32("terraria.shop_override.value", "Value", base.DEC)
local flags = ProtoField.uint8("terraria.shop_override.flags", "Flags", base.HEX)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(slot)
	payload:int16_le(item_type)
	payload:int16_le(stack)
	payload:uint8(prefix)
	payload:int32_le(value)
	payload:uint8(flags)
end

return {
	id = 104,
	build = build,
	fields = {
		slot,
		item_type,
		stack,
		prefix,
		value,
		flags,
	},
}
