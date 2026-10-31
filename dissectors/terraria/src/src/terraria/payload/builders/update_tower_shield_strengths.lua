-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/update_tower_shield_strengths.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local solar = ProtoField.uint16(
	"terraria.update_tower_shield_strengths.solar",
	"Solar Tower Shield Strength",
	base.DEC
)
local vortex = ProtoField.uint16(
	"terraria.update_tower_shield_strengths.vortex",
	"Vortex Tower Shield Strength",
	base.DEC
)
local nebula = ProtoField.uint16(
	"terraria.update_tower_shield_strengths.nebula",
	"Nebula Tower Shield Strength",
	base.DEC
)
local stardust = ProtoField.uint16(
	"terraria.update_tower_shield_strengths.stardust",
	"Stardust Tower Shield Strength",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint16_le(solar)
	payload:uint16_le(vortex)
	payload:uint16_le(nebula)
	payload:uint16_le(stardust)
end

return {
	id = 101,
	build = build,
	fields = {
		solar,
		vortex,
		nebula,
		stardust,
	},
}
