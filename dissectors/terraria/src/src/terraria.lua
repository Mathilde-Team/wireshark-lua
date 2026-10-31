-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local Dissector = require("terraria.dissector")
local fields = require("terraria.fields")

local terraria = Proto("terraria", "Terraria Protocol")

terraria.fields = fields.list
terraria.experts = fields.experts

local dissector = Dissector.new(terraria, fields)

---@param tvb Tvb
---@param pinfi PInfo
---@param tree TreeItem
function terraria.dissector(tvb, pinfi, tree)
	dissector:dissect(tvb, pinfi, tree)
end

local tcp_port = assert(DissectorTable.get("tcp.port"), "tcp.port dissector table not found")

tcp_port:add(7777, terraria)
tcp_port:add_for_decode_as(terraria)
