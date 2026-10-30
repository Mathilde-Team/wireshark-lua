-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/play_legacy_sound.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local x = ProtoField.float("terraria.play_legacy_sound.x", "X")
local y = ProtoField.float("terraria.play_legacy_sound.y", "Y")
local sound_id = ProtoField.uint16("terraria.play_legacy_sound.sound_id", "Sound ID", base.DEC)
local sound_flags = ProtoField.uint8("terraria.play_legacy_sound.sound_flags", "Sound Flags", base.HEX)
local style = ProtoField.int32("terraria.play_legacy_sound.style", "Style", base.DEC)
local volume = ProtoField.float("terraria.play_legacy_sound.volume", "Volume")
local pitch = ProtoField.float("terraria.play_legacy_sound.pitch", "Pitch")

---@param payload PayloadReader
local function build(payload)
	payload:single_le(x)
	payload:single_le(y)
	payload:uint16_le(sound_id)

	local flags_value = payload:uint8(sound_flags)

	if (flags_value & 0x01) ~= 0 then payload:int32_le(style) end
	if (flags_value & 0x02) ~= 0 then payload:single_le(volume) end
	if (flags_value & 0x04) ~= 0 then payload:single_le(pitch) end
end

return {
	id = 132,
	build = build,
	fields = {
		x,
		y,
		sound_id,
		sound_flags,
		style,
		volume,
		pitch,
	},
}
