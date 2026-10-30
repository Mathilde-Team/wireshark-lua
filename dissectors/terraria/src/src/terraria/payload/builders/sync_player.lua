-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_player.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8("terraria.sync_player.player_id", "Player ID", base.DEC)
local skin_variant = ProtoField.uint8(
	"terraria.sync_player.skin_variant",
	"Skin Variant",
	base.DEC
)
local voice_variant = ProtoField.uint8(
	"terraria.sync_player.voice_variant",
	"Voice Variant",
	base.DEC
)
local voice_pitch_offset = ProtoField.float(
	"terraria.sync_player.voice_pitch_offset",
	"Voice Pitch Offset"
)
local hair = ProtoField.uint8("terraria.sync_player.hair", "Hair", base.DEC)
local name = ProtoField.string("terraria.sync_player.name", "Name")
local hair_dye = ProtoField.uint8("terraria.sync_player.hair_dye", "Hair Dye", base.DEC)
local hide_visuals = ProtoField.uint16(
	"terraria.sync_player.hide_visuals",
	"Hidden Accessories",
	base.HEX
)
local hide_misc = ProtoField.uint8(
	"terraria.sync_player.hide_misc",
	"Hide Misc",
	base.HEX
)
local hair_color = ProtoField.bytes("terraria.sync_player.hair_color", "Hair Color")
local skin_color = ProtoField.bytes("terraria.sync_player.skin_color", "Skin Color")
local eye_color = ProtoField.bytes("terraria.sync_player.eye_color", "Eye Color")
local shirt_color = ProtoField.bytes("terraria.sync_player.shirt_color", "Shirt Color")
local under_shirt_color = ProtoField.bytes(
	"terraria.sync_player.under_shirt_color",
	"Under Shirt Color"
)
local pants_color = ProtoField.bytes("terraria.sync_player.pants_color", "Pants Color")
local shoe_color = ProtoField.bytes("terraria.sync_player.shoe_color", "Shoe Color")
local difficulty_flags = ProtoField.uint8(
	"terraria.sync_player.difficulty_flags",
	"Difficulty Flags",
	base.HEX
)
local torch_flags = ProtoField.uint8(
	"terraria.sync_player.torch_flags",
	"Torch Flags",
	base.HEX
)
local consumable_flags = ProtoField.uint8(
	"terraria.sync_player.consumable_flags",
	"Consumable Flags",
	base.HEX
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:uint8(skin_variant)
	payload:uint8(voice_variant)
	payload:single_le(voice_pitch_offset)
	payload:uint8(hair)
	payload:string(name)
	payload:uint8(hair_dye)
	payload:uint16_le(hide_visuals)
	payload:uint8(hide_misc)
	payload:color(hair_color)
	payload:color(skin_color)
	payload:color(eye_color)
	payload:color(shirt_color)
	payload:color(under_shirt_color)
	payload:color(pants_color)
	payload:color(shoe_color)
	payload:uint8(difficulty_flags)
	payload:uint8(torch_flags)
	payload:uint8(consumable_flags)
end

return {
	id = 4,
	build = build,
	fields = {
		player_id,
		skin_variant,
		voice_variant,
		voice_pitch_offset,
		hair,
		name,
		hair_dye,
		hide_visuals,
		hide_misc,
		hair_color,
		skin_color,
		eye_color,
		shirt_color,
		under_shirt_color,
		pants_color,
		shoe_color,
		difficulty_flags,
		torch_flags,
		consumable_flags,
	},
}
