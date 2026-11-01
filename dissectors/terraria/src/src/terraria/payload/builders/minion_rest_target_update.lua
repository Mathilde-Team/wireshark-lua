-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/minion_rest_target_update.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.minion_rest_target_update.player_id",
	"Player ID",
	base.DEC
)
local target_x = ProtoField.float("terraria.minion_rest_target_update.target_x", "Target X")
local target_y = ProtoField.float("terraria.minion_rest_target_update.target_y", "Target Y")

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:single_le(target_x)
	payload:single_le(target_y)
end

return {
	id = 99,
	build = build,
	fields = {
		player_id,
		target_x,
		target_y,
	},
}
