-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/mana_effect.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.mana_effect.player_id",
	"Player ID",
	base.DEC
)
local mana_amount = ProtoField.int16(
	"terraria.mana_effect.mana_amount",
	"Mana Amount",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int16_le(mana_amount)
end

return {
	id = 43,
	build = build,
	fields = {
		player_id,
		mana_amount,
	},
}
