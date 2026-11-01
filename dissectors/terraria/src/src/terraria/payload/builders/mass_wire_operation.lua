-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/mass_wire_operation.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local start_x = ProtoField.int16("terraria.mass_wire_operation.start_x", "Start X", base.DEC)
local start_y = ProtoField.int16("terraria.mass_wire_operation.start_y", "Start Y", base.DEC)
local end_x = ProtoField.int16("terraria.mass_wire_operation.end_x", "End X", base.DEC)
local end_y = ProtoField.int16("terraria.mass_wire_operation.end_y", "End Y", base.DEC)
local tool_mode = ProtoField.uint8("terraria.mass_wire_operation.tool_mode", "Tool Mode", base.HEX)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(start_x)
	payload:int16_le(start_y)
	payload:int16_le(end_x)
	payload:int16_le(end_y)
	payload:uint8(tool_mode)
end

return {
	id = 109,
	build = build,
	fields = {
		start_x,
		start_y,
		end_x,
		end_y,
		tool_mode,
	},
}
