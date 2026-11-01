-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/instrument_sound.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.instrument_sound.player_id",
	"Player ID",
	base.DEC
)
local note = ProtoField.float("terraria.instrument_sound.note", "Note")

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:single_le(note)
end

return {
	id = 58,
	build = build,
	fields = {
		player_id,
		note,
	},
}
