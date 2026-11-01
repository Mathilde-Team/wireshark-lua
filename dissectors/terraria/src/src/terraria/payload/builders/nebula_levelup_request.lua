-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/nebula_levelup_request.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.nebula_levelup_request.player_id", "Player ID", base.DEC)
local level_up_type = ProtoField.uint16(
	"terraria.nebula_levelup_request.level_up_type",
	"Level Up Type",
	base.DEC
)
local origin_x = ProtoField.float("terraria.nebula_levelup_request.origin_x", "Origin X")
local origin_y = ProtoField.float("terraria.nebula_levelup_request.origin_y", "Origin Y")

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:uint16_le(level_up_type)
	payload:single_le(origin_x)
	payload:single_le(origin_y)
end

return {
	id = 102,
	build = build,
	fields = {
		player_id,
		level_up_type,
		origin_x,
		origin_y,
	},
}
