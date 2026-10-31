-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/angler_quest.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local quest = ProtoField.uint8("terraria.angler_quest.quest", "Quest", base.DEC)
local completed = ProtoField.bool("terraria.angler_quest.completed", "Completed")

---@param payload PayloadReader
local function build(payload)
	payload:uint8(quest)
	payload:bool(completed)
end

return {
	id = 74,
	build = build,
	fields = {
		quest,
		completed,
	},
}
