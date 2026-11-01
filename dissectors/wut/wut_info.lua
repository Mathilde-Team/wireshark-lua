#!/usr/bin/env lua
-- SPDX-License-Identifier: ISC
-- Importé de https://github.com/FlorianKutzer/wut-dissector (wut_info.lua),
-- commit 875664a22f7a6263b4bb4939fa1d09e1bef5be33 du 27/02/2023.
-- Licence amont : ISC (LICENSE amont) — voir README.md.

--[[
-- Copyright (c) 2023 Florian Kutzer <info@florian-kutzer.de>
--
-- Permission to use, copy, modify, and distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]--

wut_protocol = Proto("WuT-Info", "W_T Info Protocol")

wut_protocol.fields = { }

function wut_protocol.dissector(buffer, pinfo, tree)
	length = buffer:len()
	if length == 0 then return end
	
	pinfo.cols.protocol = wut_protocol.name
	
	local subtree = tree:add(wut_protocol, buffer(), "WuT-Info Data")
	
end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(8513, wut_protocol)
