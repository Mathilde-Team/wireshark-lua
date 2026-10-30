-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/open_sign_response.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local sign_id = ProtoField.int16(
	"terraria.open_sign_response.sign_id",
	"Sign ID",
	base.DEC
)
local x = ProtoField.int16("terraria.open_sign_response.x", "X", base.DEC)
local y = ProtoField.int16("terraria.open_sign_response.y", "Y", base.DEC)
local text = ProtoField.string("terraria.open_sign_response.text", "Text")
local player_id = ProtoField.uint8(
	"terraria.open_sign_response.player_id",
	"Player ID",
	base.DEC
)
local sign_flags = ProtoField.uint8(
	"terraria.open_sign_response.sign_flags",
	"Sign Flags",
	base.HEX
)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(sign_id)
	payload:int16_le(x)
	payload:int16_le(y)
	payload:string(text)
	payload:uint8(player_id)
	payload:uint8(sign_flags)
end

return {
	id = 47,
	build = build,
	fields = {
		sign_id,
		x,
		y,
		text,
		player_id,
		sign_flags,
	},
}
