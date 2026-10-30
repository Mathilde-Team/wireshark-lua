-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/npc_debuff_damage.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local npc_index = ProtoField.uint8("terraria.npc_debuff_damage.npc_index", "NPC Index", base.DEC)
local amount = ProtoField.int16("terraria.npc_debuff_damage.amount", "Damage", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(npc_index)
	payload:int16_le(amount)
end

return {
	id = 153,
	build = build,
	fields = {
		npc_index,
		amount,
	},
}
