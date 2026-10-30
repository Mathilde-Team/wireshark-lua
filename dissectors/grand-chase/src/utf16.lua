-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://codeberg.org/gcarlos/gc-wireshark-dissector (utf16.lua),
-- commit b75e846d20aa7da7081432f283dc0f2ae1da5ee6 du 18/11/2025.
-- Licence amont : GPLv3 (LICENSE, sans clause « or later ») — voir README.md.

function band(v1,v2)
	return v1 & v2
end

function rshift(v1,shift)
	return v1 >> shift
end

function lshift(v1,shift)
	return v1 << shift
end

function unpack16(buf,pos)
	local c1,c2 = string.byte(buf,pos,pos+1)
	if c1 == nil then c1 = 0 end
	if c2 == nil then c2 = 0 end

	return (c2 << 8) + c1
end

function utf16_to_utf8(tvbrange)
        data = tvbrange:bytes():raw()
	return convert(data , utf16le_dec , utf8_enc)
end

function convert(buf,decoder,encoder)
	local out = {}
	local cp,len,pos
	pos = 1
	len = #buf
	while pos<len + 1 do
		pos, cp = decoder(buf,pos)
		table.insert(out,encoder(cp))
	end
	return table.concat(out)
end

function utf16le_dec(buf,pos)
	local cp = unpack16(buf,pos)
	pos = pos + 2	--uchar( 2byte)
	if (cp >= 0xD800) and (cp <= 0xDFFF) then
		local high = lshift( cp - 0xD800,10 )
		cp = unpack16(buf,pos)
		pos = pos + 2	--uchar( 2byte)
		cp = 0x10000 + high + cp - 0xDC00
	end
	return pos, cp
end

function utf8_enc(cp)
	local shift,mask
	if cp <= 0x7F then
		return string.char(cp)
	elseif cp <= 0x7FF then		-- 2byte = 0xC0,xxxx
		shift = 6
		mask = 0xC0
	elseif cp <= 0xFFFF then	-- 3bytr = 0xE0,xxxx,xxxx
		shift = 12
		mask = 0xE0
	elseif cp <= 0x10FFFF then	-- 4byte = 0xF0,xxxx,xxxx,xxxx
		shift = 18
		mask = 0xF0
	else
		return nil
	end

	local ss = ""
	local cc
	cc = rshift(cp,shift)
	cc = band(cc,0x3F)
	ss = string.char(mask + cc)
	shift = shift - 6
	while shift >= 0 do
		cc = rshift(cp,shift)
		cc = band(cc,0x3F)
		ss = ss..string.char(0x80 + cc)
		shift = shift - 6
	end

	return ss
end

return utf16_to_utf8
