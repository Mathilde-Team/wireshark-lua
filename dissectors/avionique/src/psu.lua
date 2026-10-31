-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://github.com/diarmuidcwc/LuaDissectors,
-- commit 78bf79c9cb5634036b152baa51091c4f3c8de577 du 29/05/2026.
-- Licence amont : GPLv2 (fichier LICENSE) — voir README.md.

-- 
-- Check the current on the PSU

psu_proto = Proto("psu","PSU Current")

-- Declare a few fields that we are in
f_current1 = ProtoField.uint32("psu.current1","CurrentCh1",base.DEC)
f_current2 = ProtoField.uint32("psu.current2","CurrentCh2",base.DEC)

psu_proto.fields = {f_current1,f_current2}

-- create a function to dissect it
function psu_proto.dissector(buffer,pinfo,tree)

	pinfo.cols.protocol = "psu"
	local datasubtree = tree:add(psu_proto,buffer(),"PSU Current")
	local offset=0
	datasubtree:add(f_current1,buffer(offset,2))
	offset = offset + 2
	datasubtree:add(f_current2,buffer(offset,2))
	offset = offset + 2
end