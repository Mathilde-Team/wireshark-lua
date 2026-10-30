-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/player_buffs.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.player_buffs.player_id",
	"Player ID",
	base.DEC
)
local buffs = ProtoField.bytes("terraria.player_buffs.buffs", "Buffs")
local buff_type = ProtoField.uint16("terraria.player_buffs.buff_type", "Buff Type", base.DEC)
local terminator = ProtoField.uint16(
	"terraria.player_buffs.terminator",
	"End Of List",
	base.DEC
)

---@param payload PayloadReader
local function build_buffs(payload)
	while payload:peek_uint16_le() ~= 0 do
		payload:uint16_le(buff_type)
	end

	payload:uint16_le(terminator)
end

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:group(buffs, build_buffs)
end

return {
	id = 50,
	build = build,
	fields = {
		player_id,
		buffs,
		buff_type,
		terminator,
	},
}
