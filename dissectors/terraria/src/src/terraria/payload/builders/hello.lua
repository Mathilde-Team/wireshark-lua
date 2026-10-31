-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/hello.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local version = ProtoField.string(
	"terraria.hello.version",
	"Client Version"
)

---@param payload PayloadReader
local function build(payload)
	payload:string(version)
end

return {
	id = 1,
	build = build,
	fields = {
		version,
	},
}
