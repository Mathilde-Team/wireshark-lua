-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/registry.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local definitions = require("terraria.payload.builders")
local packet_catalog = require("terraria.game.packet_catalog")

---@type table<integer, PayloadBuilder>
local decoders = {}

for _, definition in ipairs(definitions) do
	if decoders[definition.id] then
		error(string.format("two payload decoders are registered for packet id=%d", definition.id))
	end
	if not packet_catalog[definition.id] then
		error(string.format("payload decoder for packet id=%d has no catalog entry", definition.id))
	end
	decoders[definition.id] = definition.build
end

for id in pairs(packet_catalog) do
	if not decoders[id] then
		error(string.format("catalog packet id=%d has no payload decoder", id))
	end
end

return decoders
