-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/sync_emote_bubble.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local emote_id = ProtoField.int32("terraria.sync_emote_bubble.emote_id", "Emote ID", base.DEC)
local anchor_type = ProtoField.uint8(
	"terraria.sync_emote_bubble.anchor_type",
	"Anchor Type",
	base.DEC
)
local player_id = ProtoField.uint16(
	"terraria.sync_emote_bubble.player_id",
	"Player ID",
	base.DEC
)
local emote_lifetime = ProtoField.uint16(
	"terraria.sync_emote_bubble.emote_lifetime",
	"Emote Lifetime",
	base.DEC
)
local emote = ProtoField.int8("terraria.sync_emote_bubble.emote", "Emote", base.DEC)
local emote_metadata = ProtoField.int16(
	"terraria.sync_emote_bubble.emote_metadata",
	"Emote Metadata",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:int32_le(emote_id)
	local anchor_type_value = payload:uint8(anchor_type)

	if anchor_type_value ~= 255 then
		payload:uint16_le(player_id)
		payload:uint16_le(emote_lifetime)
		local emote_value = payload:sbyte(emote)

		if emote_value < 0 then
			payload:int16_le(emote_metadata)
		end
	end
end

return {
	id = 91,
	build = build,
	fields = {
		emote_id,
		anchor_type,
		player_id,
		emote_lifetime,
		emote,
		emote_metadata,
	},
}
