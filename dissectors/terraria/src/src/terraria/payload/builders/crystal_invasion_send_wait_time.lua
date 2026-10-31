-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/crystal_invasion_send_wait_time.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local time_until_next_wave = ProtoField.int32(
	"terraria.crystal_invasion_send_wait_time.time_until_next_wave",
	"Time Until Next Wave",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int32_le(time_until_next_wave)
end

return {
	id = 116,
	build = build,
	fields = {
		time_until_next_wave,
	},
}
