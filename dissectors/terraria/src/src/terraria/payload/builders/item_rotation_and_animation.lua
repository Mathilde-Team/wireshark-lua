-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/item_rotation_and_animation.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.item_rotation_and_animation.player_id",
	"Player ID",
	base.DEC
)
local item_rotation = ProtoField.float(
	"terraria.item_rotation_and_animation.item_rotation",
	"Item Rotation"
)
local item_animation = ProtoField.int16(
	"terraria.item_rotation_and_animation.item_animation",
	"Item Animation",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:single_le(item_rotation)
	payload:int16_le(item_animation)
end

return {
	id = 41,
	build = build,
	fields = {
		player_id,
		item_rotation,
		item_animation,
	},
}
