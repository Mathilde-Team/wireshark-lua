-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/net_modules.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local module_id = ProtoField.uint16(
	"terraria.net_modules.module_id",
	"Net Module ID",
	base.DEC
)
local module_data = ProtoField.bytes(
	"terraria.net_modules.module_data",
	"Net Module Data"
)

---@param payload PayloadReader
local function build(payload)
	payload:uint16_le(module_id)
	payload:remaining_bytes(module_data)
end

return {
	id = 82,
	build = build,
	fields = {
		module_id,
		module_data,
	},
}
