-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/chest_name.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local chest_id = ProtoField.int16("terraria.chest_name.chest_id", "Chest ID", base.DEC)
local chest_x = ProtoField.int16("terraria.chest_name.chest_x", "Chest X", base.DEC)
local chest_y = ProtoField.int16("terraria.chest_name.chest_y", "Chest Y", base.DEC)
local name = ProtoField.string("terraria.chest_name.name", "Name")

--- A client request carries only the chest; the server's answer appends the name.
---@param payload PayloadReader
local function build(payload)
	payload:int16_le(chest_id)
	payload:int16_le(chest_x)
	payload:int16_le(chest_y)

	if payload:remaining() > 0 then
		payload:string(name)
	end
end

return {
	id = 69,
	build = build,
	fields = {
		chest_id,
		chest_x,
		chest_y,
		name,
	},
}
