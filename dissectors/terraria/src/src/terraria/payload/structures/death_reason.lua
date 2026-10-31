-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/structures/death_reason.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local M = {}

---@class DeathReasonFields
---@field group ProtoField
---@field flags ProtoField
---@field killer_player_id ProtoField
---@field killer_npc_index ProtoField
---@field projectile_index ProtoField
---@field other_death_type ProtoField
---@field projectile_type ProtoField
---@field item_type ProtoField
---@field item_prefix ProtoField
---@field custom_reason ProtoField

local SOURCES_BY_FLAG_BIT = {
	{ name = "killer_player_id", label = "Killer Player ID", read = "int16_le" },
	{ name = "killer_npc_index", label = "Killer NPC Index", read = "int16_le" },
	{ name = "projectile_index", label = "Projectile Index", read = "int16_le" },
	{ name = "other_death_type", label = "Other Death Type", read = "uint8" },
	{ name = "projectile_type", label = "Projectile Type", read = "int16_le" },
	{ name = "item_type", label = "Item Type", read = "int16_le" },
	{ name = "item_prefix", label = "Item Prefix", read = "uint8" },
	{ name = "custom_reason", label = "Death Reason Text", read = "string" },
}

local FACTORIES = {
	int16_le = ProtoField.int16,
	uint8 = ProtoField.uint8,
}

---@param prefix string field namespace, e.g. "terraria.player_hurt_v2"
---@return DeathReasonFields
function M.fields(prefix)
	local fields = {
		group = ProtoField.bytes(prefix .. ".death_reason", "Death Reason"),
		flags = ProtoField.uint8(prefix .. ".death_reason_flags", "Death Reason Flags", base.HEX),
	}

	for _, source in ipairs(SOURCES_BY_FLAG_BIT) do
		local abbr = prefix .. "." .. source.name
		if source.read == "string" then
			fields[source.name] = ProtoField.string(abbr, source.label)
		else
			fields[source.name] = FACTORIES[source.read](abbr, source.label, base.DEC)
		end
	end

	return fields
end

---@param fields DeathReasonFields
---@return ProtoField[]
function M.list(fields)
	local list = { fields.group, fields.flags }
	for _, source in ipairs(SOURCES_BY_FLAG_BIT) do
		list[#list + 1] = fields[source.name]
	end
	return list
end

---@param payload PayloadReader
---@param fields DeathReasonFields
function M.read(payload, fields)
	payload:group(fields.group, function(payload)
		local flags = payload:uint8(fields.flags)

		for bit, source in ipairs(SOURCES_BY_FLAG_BIT) do
			if (flags & (1 << (bit - 1))) ~= 0 then
				payload[source.read](payload, fields[source.name])
			end
		end
	end)
end

return M
