-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/client_uuid.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local uuid = ProtoField.string("terraria.client_uuid.uuid", "UUID")

---@param payload PayloadReader
local function build(payload)
	payload:string(uuid)
end

return {
	id = 68,
	build = build,
	fields = {
		uuid,
	},
}
