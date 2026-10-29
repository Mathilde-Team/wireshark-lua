-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/luamagician/protobuf_dissector,
-- commit a4a9d7e9fac9ce9fbf38dca2c9b9c0cbafaba028 du 03/09/2015.
-- Licence amont : MIT (128 Technology, Inc.) — voir README.md et LICENSE.txt.

----------------------------------------
--
-- Copyright (c) 2015, 128 Technology, Inc.
--
-- author: Hadriel Kaplan <hadriel@128technology.com>
--
-- This code is licensed under the MIT license.
--
-- Version: 1.0
--
------------------------------------------

-- prevent wireshark loading this file as a plugin
if not _G['protbuf_dissector'] then return end


local Settings = require "settings"
local dprint   = Settings.dprint
local dprint2  = Settings.dprint2
local dassert  = Settings.dassert
local derror   = Settings.derror

--------------------------------------------------------------------------------
-- our module table that we return to the caller of this script
local GenericDecoder = {}


GenericDecoder.decoders = {}

function GenericDecoder:register(wtype, decoder)
    dassert(not GenericDecoder.decoders[wtype], "Programming error: generic decoder already registered:", wtype)
    GenericDecoder.decoders[wtype] = decoder
end


function GenericDecoder:decode(decoder, tag, wtype)
    return GenericDecoder.decoders[wtype]:decode(decoder, tag)
end


return GenericDecoder
