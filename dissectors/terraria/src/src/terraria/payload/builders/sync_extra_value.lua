-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_extra_value.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local npc_index = ProtoField.int16("terraria.sync_extra_value.npc_index", "NPC Index", base.DEC)
local extra_value = ProtoField.int32("terraria.sync_extra_value.extra_value", "Extra Value", base.DEC)
local x = ProtoField.float("terraria.sync_extra_value.x", "X")
local y = ProtoField.float("terraria.sync_extra_value.y", "Y")

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(npc_index)
	payload:int32_le(extra_value)
	payload:single_le(x)
	payload:single_le(y)
end

return {
	id = 92,
	build = build,
	fields = {
		npc_index,
		extra_value,
		x,
		y,
	},
}
