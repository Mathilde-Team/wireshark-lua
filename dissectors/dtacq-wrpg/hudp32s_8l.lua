-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/D-TACQ/CUSTOM_WRPG (CARE/dot.wireshark.plugins.hudp32s_8l.lua),
-- commit f1af2f5a0fa72fd260ffa13aaaa5f82bb004f095 du 10/05/2023.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
hudp32s_8l_protocol = Proto("HUDP",  "HUDP_32s_8l protocol")

--[[
struct wrtd_message {
        unsigned char hw_detect[3]; /* LXI */
        unsigned char domain;       /* 0 */
        unsigned char event_id[WRTD_ID_LEN];
        uint32_t seq;
        uint32_t ts_sec;
        uint32_t ts_ns;
        uint16_t ts_frac;
        uint16_t ts_hi_sec;
        uint8_t flags;
        uint8_t zero[2];
        uint8_t pad[1];
};
--]]

hudp_ch01  = ProtoField.int16("hudp.ch01", "CH01", base.DEC)
hudp_ch02  = ProtoField.int16("hudp.ch02", "CH02", base.DEC)
hudp_ch03  = ProtoField.int16("hudp.ch03", "CH03", base.DEC)
hudp_ch04  = ProtoField.int16("hudp.ch04", "CH04", base.DEC)
--[[
hudp_ch05  = ProtoField.int16("hudp.ch05", "CH05", base.DEC)
hudp_ch06  = ProtoField.int16("hudp.ch06", "CH06", base.DEC)
hudp_ch07  = ProtoField.int16("hudp.ch07", "CH07", base.DEC)
hudp_ch08  = ProtoField.int16("hudp.ch08", "CH08", base.DEC)
hudp_ch09  = ProtoField.int16("hudp.ch09", "CH09", base.DEC)
hudp_ch10  = ProtoField.int16("hudp.ch10", "CH10", base.DEC)
hudp_ch11  = ProtoField.int16("hudp.ch11", "CH11", base.DEC)
hudp_ch12  = ProtoField.int16("hudp.ch12", "CH12", base.DEC)
hudp_ch13  = ProtoField.int16("hudp.ch13", "CH13", base.DEC)
hudp_ch14  = ProtoField.int16("hudp.ch14", "CH14", base.DEC)
hudp_ch15  = ProtoField.int16("hudp.ch15", "CH15", base.DEC)
hudp_ch16  = ProtoField.int16("hudp.ch16", "CH16", base.DEC)
hudp_ch17  = ProtoField.int16("hudp.ch17", "CH17", base.DEC)
hudp_ch18  = ProtoField.int16("hudp.ch18", "CH18", base.DEC)
hudp_ch19 =  ProtoField.int16("hudp.ch19", "CH19", base.DEC)
hudp_ch20  = ProtoField.int16("hudp.ch20", "CH20", base.DEC)
hudp_ch21  = ProtoField.int16("hudp.ch21", "CH21", base.DEC)
hudp_ch22  = ProtoField.int16("hudp.ch22", "CH22", base.DEC)
hudp_ch23  = ProtoField.int16("hudp.ch23", "CH23", base.DEC)
hudp_ch24  = ProtoField.int16("hudp.ch24", "CH24", base.DEC)
hudp_ch25  = ProtoField.int16("hudp.ch25", "CH25", base.DEC)
hudp_ch26  = ProtoField.int16("hudp.ch26", "CH26", base.DEC)
hudp_ch27  = ProtoField.int16("hudp.ch27", "CH27", base.DEC)
hudp_ch28  = ProtoField.int16("hudp.ch28", "CH28", base.DEC)
--]]
hudp_ch29  = ProtoField.int16("hudp.ch29", "CH29", base.DEC)
hudp_ch30  = ProtoField.int16("hudp.ch30", "CH30", base.DEC)
hudp_ch31  = ProtoField.int16("hudp.ch31", "CH31", base.DEC)
hudp_ch32  = ProtoField.int16("hudp.ch32", "CH32", base.DEC)
hudp_spad0 = ProtoField.uint32("hudp.spad0", "SPAD0", base.DEC)
hudp_spad1 = ProtoField.uint32("hudp.spad1", "SPAD1", base.HEX)
hudp_spad2 = ProtoField.uint32("hudp.spad2", "SPAD2", base.HEX)
hudp_spad3 = ProtoField.uint32("hudp.spad3", "SPAD3", base.HEX)
hudp_spad4 = ProtoField.uint32("hudp.spad4", "SPAD4", base.HEX)
hudp_spad5 = ProtoField.uint32("hudp.spad5", "SPAD5", base.HEX)
hudp_spad6 = ProtoField.uint32("hudp.spad6", "SPAD6", base.HEX)
hudp_spad7 = ProtoField.uint32("hudp.spad7", "SPAD7", base.HEX)

hudp32s_8l_protocol.fields = { 
hudp_ch01, hudp_ch02, hudp_ch03, hudp_ch04, 
--[[
hudp_ch05, hudp_ch06, hudp_ch07, hudp_ch08,
hudp_ch09, hudp_ch10, hudp_ch11, hudp_ch12, hudp_ch13, hudp_ch14, hudp_ch15, hudp_ch16,
hudp_ch17, hudp_ch18, hudp_ch19, hudp_ch20, hudp_ch21, hudp_ch22, hudp_ch23, hudp_ch24,
hudp_ch25, hudp_ch26, hudp_ch27, hudp_ch28, 
--]]
hudp_ch29, hudp_ch30, hudp_ch31, hudp_ch32,
hudp_spad0, hudp_spad1, hudp_spad2, hudp_spad3, hudp_spad4, hudp_spad5, hudp_spad6, hudp_spad7 }

function hudp32s_8l_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = hudp32s_8l_protocol.name

  local subtree = tree:add(hudp32s_8l_protocol.name, buffer(), "HUDP 32s8l Protocol Data")
  subtree:add(hudp_ch01,  buffer(2,2))
  subtree:add(hudp_ch02,  buffer(0,2))
  subtree:add(hudp_ch03,  buffer(6,2))
  subtree:add(hudp_ch04,  buffer(4,2))
--[[
  subtree:add(hudp_ch05,  buffer(8,2))
  subtree:add(hudp_ch06,  buffer(10,2))
  subtree:add(hudp_ch07,  buffer(12,2))
  subtree:add(hudp_ch08,  buffer(14,2))
  subtree:add(hudp_ch09,  buffer(16,2))
  subtree:add(hudp_ch10,  buffer(18,2))
  subtree:add(hudp_ch11,  buffer(20,2))
  subtree:add(hudp_ch12,  buffer(22,2))
  subtree:add(hudp_ch13,  buffer(24,2))
  subtree:add(hudp_ch14,  buffer(26,2))
  subtree:add(hudp_ch15,  buffer(28,2))
  subtree:add(hudp_ch16,  buffer(30,2))
  subtree:add(hudp_ch17,  buffer(32,2))
  subtree:add(hudp_ch18,  buffer(34,2))
  subtree:add(hudp_ch19,  buffer(36,2))
  subtree:add(hudp_ch20,  buffer(38,2))
  subtree:add(hudp_ch21,  buffer(40,2))
  subtree:add(hudp_ch22,  buffer(42,2))
  subtree:add(hudp_ch23,  buffer(44,2))
  subtree:add(hudp_ch24,  buffer(46,2))
  subtree:add(hudp_ch25,  buffer(48,2))
  subtree:add(hudp_ch26,  buffer(50,2))
  subtree:add(hudp_ch27,  buffer(52,2))
  subtree:add(hudp_ch28,  buffer(54,2))
--]]
  subtree:add(hudp_ch29,  buffer(58,2))
  subtree:add(hudp_ch30,  buffer(56,2))
  subtree:add(hudp_ch31,  buffer(62,2))
  subtree:add(hudp_ch32,  buffer(60,2))
  subtree:add(hudp_spad0, buffer(64,4))
  subtree:add(hudp_spad1, buffer(68,4))
  subtree:add(hudp_spad2, buffer(72,4))
  subtree:add(hudp_spad3, buffer(76,4))
  subtree:add(hudp_spad4, buffer(80,4))
  subtree:add(hudp_spad5, buffer(84,4))
  subtree:add(hudp_spad6, buffer(88,4))
  subtree:add(hudp_spad7, buffer(92,4))

end

local port = DissectorTable.get("udp.port")
port:add(53676,hudp32s_8l_protocol)

