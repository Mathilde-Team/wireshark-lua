-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/send_password.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local password = ProtoField.string("terraria.send_password.password", "Password")

---@param payload PayloadReader
local function build(payload)
	payload:string(password)
end

return {
	id = 38,
	build = build,
	fields = {
		password,
	},
}
