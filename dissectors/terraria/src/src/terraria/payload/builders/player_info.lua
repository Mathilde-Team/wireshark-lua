-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/player_info.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.player_info.player_id",
	"Player ID",
	base.DEC
)
local check_bytes_in_client_loop = ProtoField.bool(
	"terraria.player_info.check_bytes_in_client_loop",
	"Check Bytes In Client Loop"
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:bool(check_bytes_in_client_loop)
end

return {
	id = 3,
	build = build,
	fields = {
		player_id,
		check_bytes_in_client_loop,
	},
}
