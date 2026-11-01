-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/murder_someone_elses_portal.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local projectile_owner = ProtoField.uint16(
	"terraria.murder_someone_elses_portal.projectile_owner",
	"Projectile Owner",
	base.DEC
)
local projectile_ai = ProtoField.uint8(
	"terraria.murder_someone_elses_portal.projectile_ai",
	"Projectile AI",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint16_le(projectile_owner)
	payload:uint8(projectile_ai)
end

return {
	id = 95,
	build = build,
	fields = {
		projectile_owner,
		projectile_ai,
	},
}
