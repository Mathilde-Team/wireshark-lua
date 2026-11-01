-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/remove_revenge_marker.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local unique_id = ProtoField.int32("terraria.remove_revenge_marker.unique_id", "Unique ID", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int32_le(unique_id)
end

return {
	id = 127,
	build = build,
	fields = {
		unique_id,
	},
}
