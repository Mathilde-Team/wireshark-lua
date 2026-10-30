-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/poof_of_smoke.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local packed_vector = ProtoField.uint32(
	"terraria.poof_of_smoke.packed_vector",
	"Packed Vector",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint32_le(packed_vector)
end

return {
	id = 106,
	build = build,
	fields = {
		packed_vector,
	},
}
