-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/add_npc_buff.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local npc_id = ProtoField.int16("terraria.add_npc_buff.npc_id", "NPC ID", base.DEC)
local buff = ProtoField.uint16("terraria.add_npc_buff.buff", "Buff", base.DEC)
local time = ProtoField.int16("terraria.add_npc_buff.time", "Time", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(npc_id)
	payload:uint16_le(buff)
	payload:int16_le(time)
end

return {
	id = 53,
	build = build,
	fields = {
		npc_id,
		buff,
		time,
	},
}
