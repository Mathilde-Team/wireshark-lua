-- SPDX-License-Identifier: MIT
-- Généré par wirdigen 0.3.0 (https://github.com/Cerclique/wirdigen),
-- commit amont fdbfb70444c1a88df285b7b5b1c2ef8037b23e28 du 26/10/2026,
-- à partir de `example/example_dissector.json` (copie conforme de l'amont, à côté).
-- Licence amont de l'outil : MIT (texte complet dans `LICENSE` de ce dossier).
-- Le dépôt ne collectant que du Lua, l'outil Rust n'est pas importé — voir README.md.


--[[
    Author: WIRDIGEN 0.3.0
    Date: 2026-10-29 07:20:43
    Description: Wireshark Dissector for "test"
]]--

local test = Proto("test", "test Protocol")

-- ValueString Declaration Section
local VALSTR_ANSWER_TO_UNIVERSE = { [42] = "FORTY-TWO" }
local VALSTR_TEMPERATURE = { [-273] = "ABSOLUTE ZERO" }


-- Fields Declaration Section
local bool_NONE = ProtoField.bool("test.bool_NONE", "bool_NONE", base.NONE)
local char_OCT = ProtoField.char("test.char_OCT", "char_OCT", base.OCT)
local char_HEX = ProtoField.char("test.char_HEX", "char_HEX", base.HEX)
local uint8_DEC = ProtoField.uint8("test.uint8_DEC", "uint8_DEC", base.DEC)
local uint8_OCT = ProtoField.uint8("test.uint8_OCT", "uint8_OCT", base.OCT)
local uint8_HEX = ProtoField.uint8("test.uint8_HEX", "uint8_HEX", base.HEX)
local uint8_DEC_HEX = ProtoField.uint8("test.uint8_DEC_HEX", "uint8_DEC_HEX", base.DEC_HEX)
local uint8_HEX_DEC = ProtoField.uint8("test.uint8_HEX_DEC", "uint8_HEX_DEC", base.HEX_DEC)
local uint16_DEC = ProtoField.uint16("test.uint16_DEC", "uint16_DEC", base.DEC)
local uint16_OCT = ProtoField.uint16("test.uint16_OCT", "uint16_OCT", base.OCT)
local uint16_HEX = ProtoField.uint16("test.uint16_HEX", "uint16_HEX", base.HEX)
local uint16_DEC_HEX = ProtoField.uint16("test.uint16_DEC_HEX", "uint16_DEC_HEX", base.DEC_HEX)
local uint16_HEX_DEC = ProtoField.uint16("test.uint16_HEX_DEC", "uint16_HEX_DEC", base.HEX_DEC)
local uint24_DEC = ProtoField.uint24("test.uint24_DEC", "uint24_DEC", base.DEC)
local uint24_OCT = ProtoField.uint24("test.uint24_OCT", "uint24_OCT", base.OCT)
local uint24_HEX = ProtoField.uint24("test.uint24_HEX", "uint24_HEX", base.HEX)
local uint24_DEC_HEX = ProtoField.uint24("test.uint24_DEC_HEX", "uint24_DEC_HEX", base.DEC_HEX)
local uint24_HEX_DEC = ProtoField.uint24("test.uint24_HEX_DEC", "uint24_HEX_DEC", base.HEX_DEC)
local uint32_DEC = ProtoField.uint32("test.uint32_DEC", "uint32_DEC", base.DEC)
local uint32_OCT = ProtoField.uint32("test.uint32_OCT", "uint32_OCT", base.OCT)
local uint32_HEX = ProtoField.uint32("test.uint32_HEX", "uint32_HEX", base.HEX)
local uint32_DEC_HEX = ProtoField.uint32("test.uint32_DEC_HEX", "uint32_DEC_HEX", base.DEC_HEX)
local uint32_HEX_DEC = ProtoField.uint32("test.uint32_HEX_DEC", "uint32_HEX_DEC", base.HEX_DEC)
local uint64_DEC = ProtoField.uint64("test.uint64_DEC", "uint64_DEC", base.DEC)
local uint64_OCT = ProtoField.uint64("test.uint64_OCT", "uint64_OCT", base.OCT)
local uint64_HEX = ProtoField.uint64("test.uint64_HEX", "uint64_HEX", base.HEX)
local uint64_DEC_HEX = ProtoField.uint64("test.uint64_DEC_HEX", "uint64_DEC_HEX", base.DEC_HEX)
local uint64_HEX_DEC = ProtoField.uint64("test.uint64_HEX_DEC", "uint64_HEX_DEC", base.HEX_DEC)
local int8_DEC = ProtoField.int8("test.int8_DEC", "int8_DEC", base.DEC)
local int16_DEC = ProtoField.int16("test.int16_DEC", "int16_DEC", base.DEC)
local int24_DEC = ProtoField.int24("test.int24_DEC", "int24_DEC", base.DEC)
local int32_DEC = ProtoField.int32("test.int32_DEC", "int32_DEC", base.DEC)
local int64_DEC = ProtoField.int64("test.int64_DEC", "int64_DEC", base.DEC)
local float_NONE = ProtoField.float("test.float_NONE", "float_NONE", base.NONE)
local double_NONE = ProtoField.double("test.double_NONE", "double_NONE", base.NONE)
local absolute_time_LOCAL = ProtoField.absolute_time("test.absolute_time_LOCAL", "absolute_time_LOCAL", base.LOCAL)
local absolute_time_UTC = ProtoField.absolute_time("test.absolute_time_UTC", "absolute_time_UTC", base.UTC)
local absolute_time_DOY_UTC = ProtoField.absolute_time("test.absolute_time_DOY_UTC", "absolute_time_DOY_UTC", base.DOY_UTC)
local relative_time_NONE = ProtoField.relative_time("test.relative_time_NONE", "relative_time_NONE", base.NONE)
local bytes_NONE = ProtoField.bytes("test.bytes_NONE", "bytes_NONE", base.NONE)
local bytes_DOT = ProtoField.bytes("test.bytes_DOT", "bytes_DOT", base.DOT)
local bytes_DASH = ProtoField.bytes("test.bytes_DASH", "bytes_DASH", base.DASH)
local bytes_COLON = ProtoField.bytes("test.bytes_COLON", "bytes_COLON", base.COLON)
local bytes_SPACE = ProtoField.bytes("test.bytes_SPACE", "bytes_SPACE", base.SPACE)
local unused = ProtoField.none("test.unused", "unused", base.NONE)
local ipv4_NONE = ProtoField.ipv4("test.ipv4_NONE", "ipv4_NONE", base.NONE)
local ipv6_NONE = ProtoField.ipv6("test.ipv6_NONE", "ipv6_NONE", base.NONE)
local ether_NONE = ProtoField.ether("test.ether_NONE", "ether_NONE", base.NONE)
local guid_NONE = ProtoField.guid("test.guid_NONE", "guid_NONE", base.NONE)
local oid_NONE = ProtoField.oid("test.oid_NONE", "oid_NONE", base.NONE)
local answer_to_universe = ProtoField.uint8("test.answer_to_universe", "answer_to_universe", base.DEC, VALSTR_ANSWER_TO_UNIVERSE)
local temperature = ProtoField.int32("test.temperature", "temperature", base.DEC, VALSTR_TEMPERATURE)

test.fields = {
    bool_NONE,
	char_OCT,
	char_HEX,
	uint8_DEC,
	uint8_OCT,
	uint8_HEX,
	uint8_DEC_HEX,
	uint8_HEX_DEC,
	uint16_DEC,
	uint16_OCT,
	uint16_HEX,
	uint16_DEC_HEX,
	uint16_HEX_DEC,
	uint24_DEC,
	uint24_OCT,
	uint24_HEX,
	uint24_DEC_HEX,
	uint24_HEX_DEC,
	uint32_DEC,
	uint32_OCT,
	uint32_HEX,
	uint32_DEC_HEX,
	uint32_HEX_DEC,
	uint64_DEC,
	uint64_OCT,
	uint64_HEX,
	uint64_DEC_HEX,
	uint64_HEX_DEC,
	int8_DEC,
	int16_DEC,
	int24_DEC,
	int32_DEC,
	int64_DEC,
	float_NONE,
	double_NONE,
	absolute_time_LOCAL,
	absolute_time_UTC,
	absolute_time_DOY_UTC,
	relative_time_NONE,
	bytes_NONE,
	bytes_DOT,
	bytes_DASH,
	bytes_COLON,
	bytes_SPACE,
	unused,
	ipv4_NONE,
	ipv6_NONE,
	ether_NONE,
	guid_NONE,
	oid_NONE,
	answer_to_universe,
	temperature,
}

-- Dissector Callback Declaration
function test.dissector(buffer, pinfo, tree)
    local length = buffer:len()
    if length == 0 then return end

    -- Adds dissector name to protocol column
    pinfo.cols.protocol = test.name
    
    -- Creates the subtree
    local subtree = tree:add(test, buffer(),"test Protocol Data")

    -- Adds Variables to the subtree
    subtree:add_le(bool_NONE, buffer(0, 1))
	subtree:add_le(char_OCT, buffer(1, 1))
	subtree:add_le(char_HEX, buffer(2, 1))
	subtree:add_le(uint8_DEC, buffer(3, 1))
	subtree:add_le(uint8_OCT, buffer(4, 1))
	subtree:add_le(uint8_HEX, buffer(5, 1))
	subtree:add_le(uint8_DEC_HEX, buffer(6, 1))
	subtree:add_le(uint8_HEX_DEC, buffer(7, 1))
	subtree:add_le(uint16_DEC, buffer(8, 2))
	subtree:add_le(uint16_OCT, buffer(10, 2))
	subtree:add_le(uint16_HEX, buffer(12, 2))
	subtree:add_le(uint16_DEC_HEX, buffer(14, 2))
	subtree:add_le(uint16_HEX_DEC, buffer(16, 2))
	subtree:add_le(uint24_DEC, buffer(18, 3))
	subtree:add_le(uint24_OCT, buffer(21, 3))
	subtree:add_le(uint24_HEX, buffer(24, 3))
	subtree:add_le(uint24_DEC_HEX, buffer(27, 3))
	subtree:add_le(uint24_HEX_DEC, buffer(30, 3))
	subtree:add_le(uint32_DEC, buffer(33, 4))
	subtree:add_le(uint32_OCT, buffer(37, 4))
	subtree:add_le(uint32_HEX, buffer(41, 4))
	subtree:add_le(uint32_DEC_HEX, buffer(45, 4))
	subtree:add_le(uint32_HEX_DEC, buffer(49, 4))
	subtree:add_le(uint64_DEC, buffer(53, 8))
	subtree:add_le(uint64_OCT, buffer(61, 8))
	subtree:add_le(uint64_HEX, buffer(69, 8))
	subtree:add_le(uint64_DEC_HEX, buffer(77, 8))
	subtree:add_le(uint64_HEX_DEC, buffer(85, 8))
	subtree:add_le(int8_DEC, buffer(93, 1))
	subtree:add_le(int16_DEC, buffer(94, 2))
	subtree:add_le(int24_DEC, buffer(96, 3))
	subtree:add_le(int32_DEC, buffer(99, 4))
	subtree:add_le(int64_DEC, buffer(103, 8))
	subtree:add_le(float_NONE, buffer(111, 4))
	subtree:add_le(double_NONE, buffer(115, 8))
	subtree:add_le(absolute_time_LOCAL, buffer(123, 8))
	subtree:add_le(absolute_time_UTC, buffer(131, 8))
	subtree:add_le(absolute_time_DOY_UTC, buffer(139, 8))
	subtree:add_le(relative_time_NONE, buffer(147, 8))
	subtree:add_le(bytes_NONE, buffer(155, 10))
	subtree:add_le(bytes_DOT, buffer(165, 10))
	subtree:add_le(bytes_DASH, buffer(175, 10))
	subtree:add_le(bytes_COLON, buffer(185, 10))
	subtree:add_le(bytes_SPACE, buffer(195, 10))
	subtree:add_le(unused, buffer(205, 3))
	subtree:add_le(ipv4_NONE, buffer(208, 4))
	subtree:add_le(ipv6_NONE, buffer(212, 16))
	subtree:add_le(ether_NONE, buffer(228, 6))
	subtree:add_le(guid_NONE, buffer(234, 16))
	subtree:add_le(oid_NONE, buffer(250, 16))
	subtree:add_le(answer_to_universe, buffer(266, 1))
	subtree:add_le(temperature, buffer(267, 4))
	
end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(60001, test)
udp_port:add(60002, test)

