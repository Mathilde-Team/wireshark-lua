-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/mass_wire_operation_pay.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local item_type = ProtoField.int16("terraria.mass_wire_operation_pay.item_type", "Item Type", base.DEC)
local quantity = ProtoField.int16("terraria.mass_wire_operation_pay.quantity", "Quantity", base.DEC)
local player_id = ProtoField.uint8(
	"terraria.mass_wire_operation_pay.player_id",
	"Player ID",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(item_type)
	payload:int16_le(quantity)
	payload:uint8(player_id)
end

return {
	id = 110,
	build = build,
	fields = {
		item_type,
		quantity,
		player_id,
	},
}
