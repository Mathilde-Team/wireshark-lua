-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/spawn_boss_use_license_start_event.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.int16(
	"terraria.spawn_boss_use_license_start_event.player_id",
	"Player ID",
	base.DEC
)
local invasion_type = ProtoField.int16(
	"terraria.spawn_boss_use_license_start_event.invasion_type",
	"Invasion Type",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(player_id)
	payload:int16_le(invasion_type)
end

return {
	id = 61,
	build = build,
	fields = {
		player_id,
		invasion_type,
	},
}
