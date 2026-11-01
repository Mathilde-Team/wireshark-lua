-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/request_section.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local section_x = ProtoField.uint16("terraria.request_section.section_x", "Section X", base.DEC)
local section_y = ProtoField.uint16("terraria.request_section.section_y", "Section Y", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint16_le(section_x)
	payload:uint16_le(section_y)
end

return {
	id = 159,
	build = build,
	fields = {
		section_x,
		section_y,
	},
}
