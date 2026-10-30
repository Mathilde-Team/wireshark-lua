-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/invasion_progress_report.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local progress = ProtoField.int32(
	"terraria.invasion_progress_report.progress",
	"Progress",
	base.DEC
)
local max_progress = ProtoField.int32(
	"terraria.invasion_progress_report.max_progress",
	"Max Progress",
	base.DEC
)
local icon = ProtoField.int8("terraria.invasion_progress_report.icon", "Icon", base.DEC)
local wave = ProtoField.int8("terraria.invasion_progress_report.wave", "Wave", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int32_le(progress)
	payload:int32_le(max_progress)
	payload:sbyte(icon)
	payload:sbyte(wave)
end

return {
	id = 78,
	build = build,
	fields = {
		progress,
		max_progress,
		icon,
		wave,
	},
}
