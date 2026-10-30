-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/update_player_luck_factors.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local function field(factory, name, label, display)
	return factory("terraria.update_player_luck_factors." .. name, label, display)
end

local player_id = field(ProtoField.uint8, "player_id", "Player ID", base.DEC)
local ladybug_luck_time_remaining = field(
	ProtoField.int32,
	"ladybug_luck_time_remaining",
	"Ladybug Luck Time Remaining",
	base.DEC
)
local torch_luck = field(ProtoField.float, "torch_luck", "Torch Luck")
local luck_potion = field(ProtoField.uint8, "luck_potion", "Luck Potion", base.DEC)
local has_garden_gnome_nearby = field(ProtoField.bool, "has_garden_gnome_nearby", "Has Garden Gnome Nearby")
local broken_mirror_bad_luck = field(ProtoField.bool, "broken_mirror_bad_luck", "Broken Mirror Bad Luck")
local equipment_bonus = field(ProtoField.float, "equipment_bonus", "Equipment Luck Bonus")
local coin_luck = field(ProtoField.float, "coin_luck", "Coin Luck")
local kite_luck_level = field(ProtoField.uint8, "kite_luck_level", "Kite Luck Level", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int32_le(ladybug_luck_time_remaining)
	payload:single_le(torch_luck)
	payload:uint8(luck_potion)
	payload:bool(has_garden_gnome_nearby)
	payload:bool(broken_mirror_bad_luck)
	payload:single_le(equipment_bonus)
	payload:single_le(coin_luck)
	payload:uint8(kite_luck_level)
end

return {
	id = 134,
	build = build,
	fields = {
		player_id,
		ladybug_luck_time_remaining,
		torch_luck,
		luck_potion,
		has_garden_gnome_nearby,
		broken_mirror_bad_luck,
		equipment_bonus,
		coin_luck,
		kite_luck_level,
	},
}
