-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/tile_section.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local compressed = ProtoField.bool(
	"terraria.tile_section.compressed",
	"Compressed"
)
local section_data = ProtoField.bytes(
	"terraria.tile_section.data",
	"Section Data"
)

---@param payload PayloadReader
local function build(payload)
	payload:bool(compressed)
	payload:remaining_bytes(section_data)
end

return {
	id = 10,
	build = build,
	fields = {
		compressed,
		section_data,
	},
}
