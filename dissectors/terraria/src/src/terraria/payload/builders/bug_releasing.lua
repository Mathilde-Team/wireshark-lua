-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/bug_releasing.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local x = ProtoField.int32("terraria.bug_releasing.x", "X", base.DEC)
local y = ProtoField.int32("terraria.bug_releasing.y", "Y", base.DEC)
local npc_type = ProtoField.int16("terraria.bug_releasing.npc_type", "NPC Type", base.DEC)
local style = ProtoField.uint8("terraria.bug_releasing.style", "Style", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int32_le(x)
	payload:int32_le(y)
	payload:int16_le(npc_type)
	payload:uint8(style)
end

return {
	id = 71,
	build = build,
	fields = {
		x,
		y,
		npc_type,
		style,
	},
}
