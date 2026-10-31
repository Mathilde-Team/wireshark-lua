-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/combat_text_int.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local x = ProtoField.float("terraria.combat_text_int.x", "X")
local y = ProtoField.float("terraria.combat_text_int.y", "Y")
local color = ProtoField.bytes("terraria.combat_text_int.color", "Color")
local heal_amount = ProtoField.int32(
	"terraria.combat_text_int.heal_amount",
	"Heal Amount",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:single_le(x)
	payload:single_le(y)
	payload:color(color)
	payload:int32_le(heal_amount)
end

return {
	id = 81,
	build = build,
	fields = {
		x,
		y,
		color,
		heal_amount,
	},
}
