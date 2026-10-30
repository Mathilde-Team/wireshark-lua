-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/add_player_buff_pvp.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.add_player_buff_pvp.player_id",
	"Player ID",
	base.DEC
)
local buff = ProtoField.uint16("terraria.add_player_buff_pvp.buff", "Buff", base.DEC)
local time = ProtoField.int32("terraria.add_player_buff_pvp.time", "Time", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:uint16_le(buff)
	payload:int32_le(time)
end

return {
	id = 55,
	build = build,
	fields = {
		player_id,
		buff,
		time,
	},
}
