-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/simple.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local M = {}

---@param _ PayloadReader
local function build_empty(_) end

---@param id integer
---@return PacketBuilderDefinition
function M.empty(id)
	return {
		id = id,
		build = build_empty,
		fields = {},
	}
end

--- A packet whose layout is unknown for this release.
---@param id integer
---@param name string field namespace, e.g. "sync_projectile_trackers"
---@param label string
---@return PacketBuilderDefinition
function M.raw(id, name, label)
	local data = ProtoField.bytes(string.format("terraria.%s.data", name), label)

	---@param payload PayloadReader
	local function build(payload)
		if payload:remaining() > 0 then
			payload:remaining_bytes(data)
		end
	end

	return {
		id = id,
		build = build,
		fields = {
			data,
		},
	}
end

--- Another id with the same layout as `definition`, whose fields are registered there.
---@param definition PacketBuilderDefinition
---@param id integer
---@return PacketBuilderDefinition
function M.alias(definition, id)
	return {
		id = id,
		build = definition.build,
		fields = {},
	}
end

return M
