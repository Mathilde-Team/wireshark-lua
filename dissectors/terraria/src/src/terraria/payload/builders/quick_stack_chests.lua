-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/quick_stack_chests.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local count = ProtoField.int32(
	"terraria.quick_stack_chests.count",
	"Count",
	base.DEC
)
local slots = ProtoField.bytes("terraria.quick_stack_chests.slots", "Slots")
local slot = ProtoField.int16("terraria.quick_stack_chests.slot", "Inventory Slot / Chest", base.DEC)
local smart = ProtoField.bool("terraria.quick_stack_chests.smart", "Smart Stack")

--- QuickStackChests: the client lists inventory slots to stack (plus a trailing smart flag);
--- the server answers with the chests that refused, in the same count-prefixed shape.
---@param payload PayloadReader
local function build(payload)
	local count_value = payload:int32_le(count)

	if count_value < 0 or count_value * 2 > payload:remaining() then
		error(string.format("quick stack count %d does not fit the payload", count_value), 0)
	end

	if count_value > 0 then
		payload:group(slots, function(payload)
			for _ = 1, count_value do
				payload:int16_le(slot)
			end
		end)
	end

	if payload:remaining() > 0 then
		payload:bool(smart)
	end
end

return {
	id = 85,
	build = build,
	fields = {
		count,
		slots,
		slot,
		smart,
	},
}
