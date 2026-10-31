-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/combat_text_string.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local network_text = require("terraria.payload.structures.network_text")

local x = ProtoField.float("terraria.combat_text_string.x", "X")
local y = ProtoField.float("terraria.combat_text_string.y", "Y")
local color = ProtoField.bytes("terraria.combat_text_string.color", "Color")
local combat_text = ProtoField.string("terraria.combat_text_string.text", "Combat Text")

---@param payload PayloadReader
local function build(payload)
	payload:single_le(x)
	payload:single_le(y)
	payload:color(color)
	network_text.read(payload, combat_text)
end

return {
	id = 119,
	build = build,
	fields = {
		x,
		y,
		color,
		combat_text,
	},
}
