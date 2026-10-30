-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/shimmer_actions.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local action = ProtoField.uint8(
	"terraria.shimmer_actions.action",
	"Action",
	base.DEC,
	{ [0] = "ShimmerEffect", [1] = "CoinLuck" }
)
local position = ProtoField.bytes("terraria.shimmer_actions.position", "Position")
local position_x = ProtoField.float("terraria.shimmer_actions.position_x", "Position X")
local position_y = ProtoField.float("terraria.shimmer_actions.position_y", "Position Y")
local coin_amount = ProtoField.int32("terraria.shimmer_actions.coin_amount", "Coin Amount", base.DEC)
local data = ProtoField.bytes("terraria.shimmer_actions.data", "Data")

local SHIMMER_EFFECT = 0
local COIN_LUCK = 1

---@param payload PayloadReader
local function build(payload)
	local action_value = payload:uint8(action)

	if action_value == SHIMMER_EFFECT or action_value == COIN_LUCK then
		payload:vector2(position, position_x, position_y)
	end

	if action_value == COIN_LUCK then
		payload:int32_le(coin_amount)
	end

	-- terrustia documents only the two actions above.
	if payload:remaining() > 0 then
		payload:remaining_bytes(data)
	end
end

return {
	id = 146,
	build = build,
	fields = {
		action,
		position,
		position_x,
		position_y,
		coin_amount,
		data,
	},
}
