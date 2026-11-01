-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/travel_merchant_items.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local items = ProtoField.bytes(
	"terraria.travel_merchant_items.items",
	"Items"
)
local item_fields = {}

for index = 1, 40 do
	item_fields[index] = ProtoField.int16(
		string.format("terraria.travel_merchant_items.item_%02d", index),
		string.format("Item %02d", index),
		base.DEC
	)
end

---@param payload PayloadReader
local function build_items(payload)
	for index = 1, 40 do
		payload:int16_le(item_fields[index])
	end
end

---@param payload PayloadReader
local function build(payload)
	payload:group(items, build_items)
end

local fields = {
	items,
}

for index = 1, 40 do
	fields[#fields + 1] = item_fields[index]
end

return {
	id = 72,
	build = build,
	fields = fields,
}
