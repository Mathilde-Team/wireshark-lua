-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/fields.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local definitions = require("terraria.payload.builders")
local network_text = require("terraria.payload.structures.network_text")

---@type ProtoField[]
local fields = {}

for _, field in ipairs(network_text.fields) do
	fields[#fields + 1] = field
end

for _, definition in ipairs(definitions) do
	for _, field in ipairs(definition.fields) do
		fields[#fields + 1] = field
	end
end

return fields
