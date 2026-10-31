-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/world_evil_tally.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local good = ProtoField.uint8("terraria.world_evil_tally.good", "Good", base.DEC)
local evil = ProtoField.uint8("terraria.world_evil_tally.evil", "Evil", base.DEC)
local crimson = ProtoField.uint8("terraria.world_evil_tally.crimson", "Crimson", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(good)
	payload:uint8(evil)
	payload:uint8(crimson)
end

return {
	id = 57,
	build = build,
	fields = {
		good,
		evil,
		crimson,
	},
}
