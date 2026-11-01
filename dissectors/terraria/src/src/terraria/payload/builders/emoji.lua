-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/emoji.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_index = ProtoField.uint8(
	"terraria.emoji.player_index",
	"Player Index",
	base.DEC
)
local emoticon_id = ProtoField.uint8(
	"terraria.emoji.emoticon_id",
	"Emoticon ID",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_index)
	payload:uint8(emoticon_id)
end

return {
	id = 120,
	build = build,
	fields = {
		player_index,
		emoticon_id,
	},
}
