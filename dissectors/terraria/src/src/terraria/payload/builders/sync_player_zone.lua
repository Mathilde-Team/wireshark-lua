-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_player_zone.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.sync_player_zone.player_id", "Player ID", base.DEC)
local zones = {}
for index = 1, 5 do
	zones[index] = ProtoField.uint8(
		string.format("terraria.sync_player_zone.zone_%d", index),
		string.format("Zone Flags %d", index),
		base.HEX
	)
end
local town_npcs = ProtoField.uint8("terraria.sync_player_zone.town_npcs", "Nearby Town NPCs", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	for index = 1, #zones do
		payload:uint8(zones[index])
	end
	payload:uint8(town_npcs)
end

local fields = { player_id }
for index = 1, #zones do
	fields[#fields + 1] = zones[index]
end
fields[#fields + 1] = town_npcs

return {
	id = 36,
	build = build,
	fields = fields,
}
