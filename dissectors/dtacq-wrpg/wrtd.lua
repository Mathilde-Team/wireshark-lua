-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/D-TACQ/CUSTOM_WRPG (CARE/dot.wireshark.plugins.wrtd.lua),
-- commit f1af2f5a0fa72fd260ffa13aaaa5f82bb004f095 du 10/05/2023.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
wrtd_protocol = Proto("WRTD",  "WRTD Protocol")

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

wrtd_hw_detect= ProtoField.string("wrtd.hw_detect", "hw_detect")
wrtd_domain   = ProtoField.uint8("wrtd.domain", "domain", base.HEX)
wrtd_event_id = ProtoField.string("wrtd.event_id", "event_id")
wrtd_imask    = ProtoField.uint8("wrtd.imask", "imask", base.HEX)
wrtd_seq =      ProtoField.int32("wrtd.seq", "seq", base.DEC)
wrtd_ts_sec =   ProtoField.int32("wrtd.ts_sec", "ts_sec", base.DEC)
wrtd_ts_ns =    ProtoField.int32("wrtd.ts_ns", "ts_ns", base.DEC)

wrtd_protocol.fields = { wrtd_hw_detect, wrtd_domain, wrtd_event_id, wrtd_imask, wrtd_seq, wrtd_ts_sec, wrtd_ts_ns }

function wrtd_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = wrtd_protocol.name

  local subtree = tree:add(wrtd_protocol, buffer(), "WRTD Protocol Data")

  subtree:add(wrtd_hw_detect, buffer(0,3))
  subtree:add(wrtd_domain, buffer(3,1))
  subtree:add(wrtd_event_id, buffer(4,15))
  subtree:add(wrtd_imask, buffer(19,1))
  subtree:add_le(wrtd_seq, buffer(20,4))
  subtree:add_le(wrtd_ts_sec, buffer(24,4))
  subtree:add_le(wrtd_ts_ns, buffer(28,4))

end

local tcp_port = DissectorTable.get("udp.port")
tcp_port:add(5044, wrtd_protocol)


