-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/fish_out_npc.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local x = ProtoField.uint16("terraria.fish_out_npc.x", "X", base.DEC)
local y = ProtoField.uint16("terraria.fish_out_npc.y", "Y", base.DEC)
local npc_id = ProtoField.int16("terraria.fish_out_npc.npc_id", "NPC ID", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint16_le(x)
	payload:uint16_le(y)
	payload:int16_le(npc_id)
end

return {
	id = 130,
	build = build,
	fields = {
		x,
		y,
		npc_id,
	},
}
