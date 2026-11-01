-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/kick.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local network_text = require("terraria.payload.structures.network_text")

local reason = ProtoField.string(
	"terraria.kick.reason",
	"Reason"
)

---@param payload PayloadReader
local function build(payload)
	network_text.read(payload, reason)
end

return {
	id = 2,
	build = build,
	fields = {
		reason,
	},
}
