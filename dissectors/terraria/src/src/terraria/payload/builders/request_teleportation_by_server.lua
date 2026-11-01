-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/request_teleportation_by_server.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local potion_type = ProtoField.uint8(
	"terraria.request_teleportation_by_server.type",
	"Type",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(potion_type)
end

return {
	id = 73,
	build = build,
	fields = {
		potion_type,
	},
}
