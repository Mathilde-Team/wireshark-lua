-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/kill_projectile.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local projectile_key = require("terraria.payload.structures.projectile_key")

local key_fields = projectile_key.fields("terraria.kill_projectile")
local position = ProtoField.bytes("terraria.kill_projectile.position", "Position")
local position_x = ProtoField.float("terraria.kill_projectile.position_x", "Position X")
local position_y = ProtoField.float("terraria.kill_projectile.position_y", "Position Y")

---@param payload PayloadReader
local function build(payload)
	projectile_key.read(payload, key_fields)
	payload:vector2(position, position_x, position_y)
end

local fields = projectile_key.list(key_fields)
for _, field in ipairs({ position, position_x, position_y }) do
	fields[#fields + 1] = field
end

return {
	id = 29,
	build = build,
	fields = fields,
}
