-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/land_golf_ball_in_cup.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.land_golf_ball_in_cup.player_id", "Player ID", base.DEC)
local x = ProtoField.uint16("terraria.land_golf_ball_in_cup.x", "X", base.DEC)
local y = ProtoField.uint16("terraria.land_golf_ball_in_cup.y", "Y", base.DEC)
local number_of_hits = ProtoField.uint16(
	"terraria.land_golf_ball_in_cup.number_of_hits",
	"Number of Hits",
	base.DEC
)
local proj_id = ProtoField.uint16("terraria.land_golf_ball_in_cup.proj_id", "Proj ID", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:uint16_le(x)
	payload:uint16_le(y)
	payload:uint16_le(number_of_hits)
	payload:uint16_le(proj_id)
end

return {
	id = 128,
	build = build,
	fields = {
		player_id,
		x,
		y,
		number_of_hits,
		proj_id,
	},
}
