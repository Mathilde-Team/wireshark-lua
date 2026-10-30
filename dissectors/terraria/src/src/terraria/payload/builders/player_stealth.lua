-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/player_stealth.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player = ProtoField.uint8("terraria.player_stealth.player", "Player", base.DEC)
local stealth = ProtoField.float("terraria.player_stealth.stealth", "Stealth")

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player)
	payload:single_le(stealth)
end

return {
	id = 84,
	build = build,
	fields = {
		player,
		stealth,
	},
}
