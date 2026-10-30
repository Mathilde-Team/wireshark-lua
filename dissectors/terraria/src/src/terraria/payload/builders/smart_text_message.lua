-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/smart_text_message.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local network_text = require("terraria.payload.structures.network_text")

local message_color = ProtoField.bytes(
	"terraria.smart_text_message.message_color",
	"Message Color"
)
local text = ProtoField.string("terraria.smart_text_message.text", "Message")
local message_length = ProtoField.int16(
	"terraria.smart_text_message.message_length",
	"Message Length",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:color(message_color)
	network_text.read(payload, text)
	payload:int16_le(message_length)
end

return {
	id = 107,
	build = build,
	fields = {
		message_color,
		text,
		message_length,
	},
}
