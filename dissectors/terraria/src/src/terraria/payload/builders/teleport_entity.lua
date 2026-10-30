-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/teleport_entity.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local flags = ProtoField.uint8("terraria.teleport_entity.flags", "Flags", base.HEX)
local target_id = ProtoField.int16(
	"terraria.teleport_entity.target_id",
	"Target ID",
	base.DEC
)
local x = ProtoField.float("terraria.teleport_entity.x", "X")
local y = ProtoField.float("terraria.teleport_entity.y", "Y")
local style = ProtoField.uint8("terraria.teleport_entity.style", "Style", base.DEC)
local extra_info = ProtoField.int32(
	"terraria.teleport_entity.extra_info",
	"Extra Info",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	local flags_value = payload:uint8(flags)
	payload:int16_le(target_id)
	payload:single_le(x)
	payload:single_le(y)
	payload:uint8(style)

	if (flags_value & 0x08) ~= 0 then
		payload:int32_le(extra_info)
	end
end

return {
	id = 65,
	build = build,
	fields = {
		flags,
		target_id,
		x,
		y,
		style,
		extra_info,
	},
}
