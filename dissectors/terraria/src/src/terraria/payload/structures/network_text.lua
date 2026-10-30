-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/structures/network_text.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local M = {}

local LITERAL = 0

-- Real messages nest one or two levels; the cap turns a hostile packet into a decode error
-- instead of a Lua stack overflow.
local MAX_NESTING = 32

local mode = ProtoField.uint8("terraria.network_text.mode", "Text Mode", base.DEC, {
	[0] = "Literal",
	[1] = "Formattable",
	[2] = "LocalizationKey",
})
local substitution_count = ProtoField.uint8(
	"terraria.network_text.substitution_count",
	"Substitution Count",
	base.DEC
)
local substitution = ProtoField.bytes("terraria.network_text.substitution", "Substitution")
local substitution_text = ProtoField.string("terraria.network_text.text", "Substitution Text")

M.fields = { mode, substitution_count, substitution, substitution_text }

---@param payload PayloadReader
---@param text_field ProtoField
---@param depth integer
---@return string
local function read_text(payload, text_field, depth)
	if depth > MAX_NESTING then
		error(string.format("NetworkText nests deeper than %d levels", MAX_NESTING), 0)
	end

	local text_mode = payload:uint8(mode)
	local text = payload:string(text_field)
	if text_mode == LITERAL then
		return text
	end

	for _ = 1, payload:uint8(substitution_count) do
		payload:group(substitution, function(payload)
			read_text(payload, substitution_text, depth + 1)
		end)
	end

	return text
end

--- The top-level string goes into the packet's own `text_field`, so filters can match on it.
---@param payload PayloadReader
---@param text_field ProtoField
---@return string
function M.read(payload, text_field)
	return read_text(payload, text_field, 1)
end

return M
