-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/quests_count_sync.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local player_id = ProtoField.uint8(
	"terraria.quests_count_sync.player_id",
	"Player ID",
	base.DEC
)
local quests_completed = ProtoField.int32(
	"terraria.quests_count_sync.quests_completed",
	"Angler Quests Completed",
	base.DEC
)
local golfer_score = ProtoField.int32(
	"terraria.quests_count_sync.golfer_score",
	"Golfer Score",
	base.DEC
)

---@param payload PayloadReader
local function build(payload)
	payload:uint8(player_id)
	payload:int32_le(quests_completed)
	payload:int32_le(golfer_score)
end

return {
	id = 76,
	build = build,
	fields = {
		player_id,
		quests_completed,
		golfer_score,
	},
}
