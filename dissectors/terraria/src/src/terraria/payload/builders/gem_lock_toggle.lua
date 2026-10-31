-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/gem_lock_toggle.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local x = ProtoField.int16("terraria.gem_lock_toggle.x", "X", base.DEC)
local y = ProtoField.int16("terraria.gem_lock_toggle.y", "Y", base.DEC)
local on = ProtoField.bool("terraria.gem_lock_toggle.on", "On")

---@param payload PayloadReader
local function build(payload)
	payload:int16_le(x)
	payload:int16_le(y)
	payload:bool(on)
end

return {
	id = 105,
	build = build,
	fields = {
		x,
		y,
		on,
	},
}
