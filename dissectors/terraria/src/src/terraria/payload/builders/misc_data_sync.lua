-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/misc_data_sync.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.misc_data_sync.player_id",
	"Player ID",
	base.DEC
)
local effect_type = ProtoField.uint8(
	"terraria.misc_data_sync.effect_type",
	"Effect Type",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:uint8(effect_type)
end

return {
	id = 51,
	build = build,
	fields = {
		player_id,
		effect_type,
	},
}
