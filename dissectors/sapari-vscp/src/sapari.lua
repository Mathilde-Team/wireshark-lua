-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/modeco80/saparid (tools/wireshark/sapari.lua),
-- commit bafa7b574ef942c0e5b7f505ce2fbc12234ae5ae du 17/03/2023.
-- Licence amont : MIT (LICENSE) — voir README.md.

--[[
 * A fairly WIP Wireshark dissector for Sony SAPARi VSCP/VSAP.
 *
 * (C) 2023 Lily Tsuru/modeco80 <lily.modeco80@protonmail.ch>
 *
 * Usage:
 * Launch wireshark with somehting like `wireshark -X lua_script:sapari.lua`
 * (or place this into your plugins directory.)
 * Then open a PCAP capture (or do live capture. I'm not your dad)
 * ...
 * VSCP protocol elements should show up in the capture and be (somewhat) decoded!
]]


vscp_protocol = Proto("vscp", "Sony SAPARi VSCP")

-- FIELDS

-- Hello
hello_header = ProtoField.string("vscp.hello_string", "Hello magic thing")
-- s->c
hello_unk1 = ProtoField.uint32("vscp.hello_unk1", "Unknown 1", base.DEC)
hello_unk2 = ProtoField.uint32("vscp.hello_unk2", "Unknown 2", base.DEC)
-- c->s
hello_vscp_ver_maj = ProtoField.uint8("vscp.hello_vscp_ver_maj", "Client VSCP Version Major", base.DEC)
hello_vscp_ver_min = ProtoField.uint8("vscp.hello_vscp_ver_min", "Client VSCP Version Minor", base.DEC)

-- for regular VS(C|A)P messages
method_type = ProtoField.uint8("vscp.method", "Method type", base.DEC)
unk1 = ProtoField.uint32("vscp.unk1", "Unknown 1", base.DEC)
unk2 = ProtoField.uint32("vscp.unk2", "Unknown 2", base.DEC)

-- Type 0 header
message_type = ProtoField.uint32("vscp.type0_message_Type", "Message Type", base.DEC)
payload_size = ProtoField.uint32("vscp.type0_payload_size", "Payload Size", base.DEC)
payload      = ProtoField.bytes("vscp.type0_payload", "Payload Data", base.NONE)

-- TODO: Other types.

vscp_protocol.fields = {
	hello_header,
	hello_unk1, hello_unk2,
	hello_vscp_ver_maj, hello_vscp_ver_min,

	-- normal
	method_type, unk1, unk2,

	-- type 0
	message_type, payload_size, payload

}

function vscp_method_name(op)
	local name="Invalid"

	if     op == 0 then name = "TYPE0"
	elseif op == 1 then name = "TYPE1"
	elseif op == 2 then name = "TYPE2"
	elseif op == 3 then name = "HELLO/HELLA"
	elseif op == 4 then name = "REJECT"
	elseif op == 6 then name = "UNK6"
	end

	return name
end


function vscp_protocol.dissector(buffer, info, tree)
	if buffer:len() == 0 then return end

	info.cols.protocol = vscp_protocol.name

	local subtree = tree:add(vscp_protocol, buffer(), "Sony SAPARi VSCP/VSAP")

	-- Process hello messages
	if buffer(0,1):le_int() == 0x68 then -- 'h' in "hello"
		local hTree = subtree:add(vscp_protocol, buffer(), "Hello")

		hTree:add(hello_header, buffer(0, 5))
		if buffer(5, 1):le_int() == 0x0 then
			-- probably a server message then. This is a REALLY bad way of detecting it,
			-- but it's seemingly "ok" enough for a dissector.
			hTree:add(hello_unk1, buffer(6, 4))
			hTree:add(hello_unk2, buffer(10, 4))
		else
			-- a client message
			hTree:add(hello_vscp_ver_maj, buffer(5, 1))
			hTree:add(hello_vscp_ver_min, buffer(6, 1))
		end
		return
	end

	subtree:add(method_type, buffer(0, 1)):append_text(" (" .. vscp_method_name(buffer(0, 1):le_uint()) .. ")")
	subtree:add(unk1, buffer(1, 4))
	subtree:add(unk2, buffer(5, 4))

	-- Process TYPE0 method messages
	if buffer(0,1):le_int() == 0 then
		local t0Tree = subtree:add(vscp_protocol, buffer(), "TYPE0 Message")

		t0Tree:add(message_type, buffer(9, 4))
		t0Tree:add(payload_size, buffer(13, 4)):append_text(" bytes")
		t0Tree:add(payload, buffer(17))
	end
end

-- The VSCP protocol can run on any port, but
-- 5126 is the default for the Community Bureau,
-- so for simplicity's sake, use that.
DissectorTable.get("tcp.port"):add(5126, vscp_protocol)
