-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/npc_buffs.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local npc_id = ProtoField.int16("terraria.npc_buffs.npc_id", "NPC ID", base.DEC)
local buff = ProtoField.bytes("terraria.npc_buffs.buff", "Buff")
local buff_id = ProtoField.uint16("terraria.npc_buffs.buff_id", "Buff ID", base.DEC)
local time = ProtoField.uint16("terraria.npc_buffs.time", "Time", base.DEC)
local terminator = ProtoField.uint16("terraria.npc_buffs.terminator", "End Of List", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(npc_id)

	while payload:peek_uint16_le() ~= 0 do
		payload:group(buff, function(payload)
			payload:uint16_le(buff_id)
			payload:uint16_le(time)
		end)
	end

	payload:uint16_le(terminator)
end

return {
	id = 54,
	build = build,
	fields = {
		npc_id,
		buff,
		buff_id,
		time,
		terminator,
	},
}
