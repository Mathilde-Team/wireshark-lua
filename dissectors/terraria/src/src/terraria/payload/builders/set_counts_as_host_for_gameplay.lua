-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/set_counts_as_host_for_gameplay.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.set_counts_as_host_for_gameplay.player_id",
	"Player ID",
	base.DEC
)
local counts_as_host = ProtoField.bool(
	"terraria.set_counts_as_host_for_gameplay.counts_as_host",
	"Counts As Host"
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:bool(counts_as_host)
end

return {
	id = 139,
	build = build,
	fields = {
		player_id,
		counts_as_host,
	},
}
