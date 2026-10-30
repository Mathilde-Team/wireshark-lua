-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/toggle_pvp.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.toggle_pvp.player_id", "Player ID", base.DEC)
local enabled = ProtoField.bool("terraria.toggle_pvp.enabled", "PVP Enabled")

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:bool(enabled)
end

return {
	id = 30,
	build = build,
	fields = {
		player_id,
		enabled,
	},
}
