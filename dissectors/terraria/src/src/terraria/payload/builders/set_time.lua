-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/set_time.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local day_time = ProtoField.bool("terraria.set_time.day_time", "Day Time")
local time_value = ProtoField.int32("terraria.set_time.value", "Time Value", base.DEC)
local sun_mod_y = ProtoField.int16("terraria.set_time.sun_mod_y", "Sun Mod Y", base.DEC)
local moon_mod_y = ProtoField.int16("terraria.set_time.moon_mod_y", "Moon Mod Y", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:bool(day_time)
	payload:int32_le(time_value)
	payload:int16_le(sun_mod_y)
	payload:int16_le(moon_mod_y)
end

return {
	id = 18,
	build = build,
	fields = {
		day_time,
		time_value,
		sun_mod_y,
		moon_mod_y,
	},
}
