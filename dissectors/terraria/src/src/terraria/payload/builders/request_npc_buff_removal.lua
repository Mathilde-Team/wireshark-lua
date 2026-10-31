-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/request_npc_buff_removal.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local npc_id = ProtoField.int16("terraria.request_npc_buff_removal.npc_id", "NPC ID", base.DEC)
local buff_id = ProtoField.uint16("terraria.request_npc_buff_removal.buff_id", "Buff ID", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(npc_id)
	payload:uint16_le(buff_id)
end

return {
	id = 137,
	build = build,
	fields = {
		npc_id,
		buff_id,
	},
}
