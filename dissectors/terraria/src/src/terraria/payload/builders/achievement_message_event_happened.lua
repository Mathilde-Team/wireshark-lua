-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/achievement_message_event_happened.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local event_id = ProtoField.int16(
	"terraria.achievement_message_event_happened.event_id",
	"Event ID",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(event_id)
end

return {
	id = 98,
	build = build,
	fields = {
		event_id,
	},
}
