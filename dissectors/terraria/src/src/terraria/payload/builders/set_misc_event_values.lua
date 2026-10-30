-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/set_misc_event_values.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local unused = ProtoField.uint8("terraria.set_misc_event_values.unused", "Unused", base.DEC)
local credits_roll_remaining_time = ProtoField.int32(
	"terraria.set_misc_event_values.credits_roll_remaining_time",
	"Credits Roll Remaining Time",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(unused)
	payload:int32_le(credits_roll_remaining_time)
end

return {
	id = 140,
	build = build,
	fields = {
		unused,
		credits_roll_remaining_time,
	},
}
