-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/status_text_size.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local network_text = require("terraria.payload.structures.network_text")

local status_max = ProtoField.int32(
	"terraria.status_text_size.max",
	"Status Max",
	base.DEC
)
local message = ProtoField.bytes("terraria.status_text_size.message", "Message")
local text = ProtoField.string("terraria.status_text_size.text", "Status Text")
local text_flags = ProtoField.uint8(
	"terraria.status_text_size.text_flags",
	"Status Text Flags",
	base.HEX
)

---@param payload PayloadReader
local function build_message(payload)
	network_text.read(payload, text)
	payload:uint8(text_flags)
end

---@param payload PayloadReader
local function build(payload)
	payload:int32_le(status_max)
	payload:group(message, build_message)
end

return {
	id = 9,
	build = build,
	fields = {
		status_max,
		message,
		text,
		text_flags,
	},
}
