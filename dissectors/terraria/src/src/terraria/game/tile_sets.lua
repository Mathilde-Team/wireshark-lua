-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/game/tile_sets.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

-- Tile type properties needed to walk tile data, transcribed from terrustia's tile_sets.rs
-- (Terraria 1.4.5.7/1.4.5.8).
local M = {}

M.TILE_COUNT = 754

-- Main.tileFrameImportant, 64 tile types per word. Lua wraps hex literals with the top bit set
-- to negative integers without changing their bits.
local FRAME_IMPORTANT_BITS = {
	0x2086041EBD3FFC38,
	0x600647FFFFFEE780,
	0x0F0478200021EFF3,
	0x40FFFA981F968200,
	0xF47FFFFFEFF8E000,
	0x17F01FDC200EC019,
	0x3FF83B987C600FFC,
	0xE60A6FF118FFE3F0,
	0x3FB1DFFBC43EFFC0,
	0xA5E1FBFFFFFFFFF8,
	0xFDE0000003977FFD,
	0x00038000207B1FEF,
}

---@param tile_type integer
---@return boolean
function M.is_frame_important(tile_type)
	if tile_type < 0 or tile_type >= M.TILE_COUNT then
		return false
	end

	local word = FRAME_IMPORTANT_BITS[(tile_type // 64) + 1]
	return (word & (1 << (tile_type % 64))) ~= 0
end

return M
