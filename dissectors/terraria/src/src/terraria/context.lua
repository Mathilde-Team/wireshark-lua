-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/context.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local LENGTH_OFFSET = 0
local LENGTH_SIZE = 2
local ID_OFFSET = LENGTH_OFFSET + LENGTH_SIZE
local ID_SIZE = 1
local HEADER_SIZE = LENGTH_SIZE + ID_SIZE
local PAYLOAD_OFFSET = HEADER_SIZE

---@class PacketContext
---@field tvb Tvb
---@field len integer
---@field id integer
---@field payload_len integer
local PacketContext = {}
PacketContext.__index = PacketContext

---@param tvb Tvb
---@return PacketContext
function PacketContext.new(tvb)
	local len = tvb(LENGTH_OFFSET, LENGTH_SIZE):le_uint()

	return setmetatable({
		tvb = tvb,
		len = len,
		id = tvb(ID_OFFSET, ID_SIZE):uint(),
		payload_len = len - PAYLOAD_OFFSET,
	}, PacketContext)
end

---@return integer
function PacketContext.header_size()
	return HEADER_SIZE
end

---@param tvb Tvb
---@param _ PInfo
---@param offset integer
---@return integer
function PacketContext.pdu_len(tvb, _, offset)
	-- tcp_dissect_pdus rejects a length below the header with a generic error; claiming the
	-- header lets dissect_malformed report it.
	return math.max(tvb(offset + LENGTH_OFFSET, LENGTH_SIZE):le_uint(), HEADER_SIZE)
end

---@return boolean
function PacketContext:is_malformed()
	return self.len < HEADER_SIZE
end

---@return TvbRange
function PacketContext:full_range()
	return self.tvb()
end

---@return TvbRange
function PacketContext:length_range()
	return self.tvb(LENGTH_OFFSET, LENGTH_SIZE)
end

---@return TvbRange
function PacketContext:payload_range()
	return self.tvb(PAYLOAD_OFFSET, self.payload_len)
end

---@return TvbRange
function PacketContext:id_range()
	return self.tvb(ID_OFFSET, ID_SIZE)
end

return PacketContext
