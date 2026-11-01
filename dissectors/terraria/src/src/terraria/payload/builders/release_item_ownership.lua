-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/release_item_ownership.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local item_index = ProtoField.int16("terraria.release_item_ownership.item_index", "Item Index", base.DEC)
local force_to_server = ProtoField.bool(
	"terraria.release_item_ownership.force_to_server",
	"Force To Server"
)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(item_index)
	payload:bool(force_to_server)
end

return {
	id = 39,
	build = build,
	fields = {
		item_index,
		force_to_server,
	},
}
