-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/lock_and_unlock.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local unlock_type = ProtoField.uint8(
	"terraria.lock_and_unlock.unlock_type",
	"Unlock Type",
	base.DEC
)
local x = ProtoField.int16("terraria.lock_and_unlock.x", "X", base.DEC)
local y = ProtoField.int16("terraria.lock_and_unlock.y", "Y", base.DEC)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(unlock_type)
	payload:int16_le(x)
	payload:int16_le(y)
end

return {
	id = 52,
	build = build,
	fields = {
		unlock_type,
		x,
		y,
	},
}
