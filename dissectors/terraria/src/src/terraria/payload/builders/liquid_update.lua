-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/liquid_update.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local x = ProtoField.int16("terraria.liquid_update.x", "X", base.DEC)
local y = ProtoField.int16("terraria.liquid_update.y", "Y", base.DEC)
local liquid = ProtoField.uint8("terraria.liquid_update.liquid", "Liquid", base.DEC)
local liquid_type = ProtoField.uint8(
	"terraria.liquid_update.liquid_type",
	"Liquid Type",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(x)
	payload:int16_le(y)
	payload:uint8(liquid)
	payload:uint8(liquid_type)
end

return {
	id = 48,
	build = build,
	fields = {
		x,
		y,
		liquid,
		liquid_type,
	},
}
