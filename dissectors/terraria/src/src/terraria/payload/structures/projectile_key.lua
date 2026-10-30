-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/structures/projectile_key.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local M = {}

---@class ProjectileKeyFields
---@field key ProtoField
---@field owner ProtoField
---@field index ProtoField
---@field generation ProtoField

---@param prefix string field namespace, e.g. "terraria.projectile_update"
---@return ProjectileKeyFields
function M.fields(prefix)
	return {
		key = ProtoField.uint32(prefix .. ".key", "Projectile Key", base.HEX),
		owner = ProtoField.uint32(prefix .. ".owner", "Owner", base.DEC, nil, 0x000000FF),
		index = ProtoField.uint32(prefix .. ".index", "Index", base.DEC, nil, 0x0003FF00),
		generation = ProtoField.uint32(prefix .. ".generation", "Generation", base.DEC, nil, 0xFFFC0000),
	}
end

---@param fields ProjectileKeyFields
---@return ProtoField[]
function M.list(fields)
	return { fields.key, fields.owner, fields.index, fields.generation }
end

---@param payload PayloadReader
---@param fields ProjectileKeyFields
---@return integer
function M.read(payload, fields)
	return payload:bits(fields.key, { fields.owner, fields.index, fields.generation }, 4)
end

return M
