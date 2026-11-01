-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_chest_size.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local chest_id = ProtoField.int16("terraria.sync_chest_size.chest_id", "Chest ID", base.DEC)
local slots = ProtoField.int16("terraria.sync_chest_size.slots", "Slots", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(chest_id)
	payload:int16_le(slots)
end

return {
	id = 155,
	build = build,
	fields = {
		chest_id,
		slots,
	},
}
