-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/item_owner.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local item_id = ProtoField.int16("terraria.item_owner.item_id", "Item ID", base.DEC)
local player_id = ProtoField.uint8("terraria.item_owner.player_id", "Player ID", base.DEC)
local keep_reservation = ProtoField.uint32(
	"terraria.item_owner.keep_reservation",
	"Keep Reservation Ticks",
	base.DEC
)
local grab_delay_player = ProtoField.uint8(
	"terraria.item_owner.grab_delay_player",
	"Grab Delay Player",
	base.DEC
)
local grab_delay = ProtoField.uint32(
	"terraria.item_owner.grab_delay",
	"Grab Delay Ticks",
	base.DEC
)
local position = ProtoField.bytes("terraria.item_owner.position", "Position")
local position_x = ProtoField.float("terraria.item_owner.position_x", "Position X")
local position_y = ProtoField.float("terraria.item_owner.position_y", "Position Y")

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(item_id)
	payload:uint8(player_id)
	payload:var_u32(keep_reservation)
	payload:uint8(grab_delay_player)
	payload:var_u32(grab_delay)
	payload:vector2(position, position_x, position_y)
end

return {
	id = 22,
	build = build,
	fields = {
		item_id,
		player_id,
		keep_reservation,
		grab_delay_player,
		grab_delay,
		position,
		position_x,
		position_y,
	},
}
