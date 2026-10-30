-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/moonlord_horror.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local countdown_max = ProtoField.int32(
	"terraria.moonlord_horror.max",
	"Moon Lord Countdown Max",
	base.DEC
)
local moon_lord_countdown = ProtoField.int32(
	"terraria.moonlord_horror.value",
	"Moon Lord Countdown",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int32_le(countdown_max)
	payload:int32_le(moon_lord_countdown)
end

return {
	id = 103,
	build = build,
	fields = {
		countdown_max,
		moon_lord_countdown,
	},
}
