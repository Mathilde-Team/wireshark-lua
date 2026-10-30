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

local Base = require "generic.base"


----------------------------------------
-- VarintDecoder class, for "fixed64" fields
--
local VarintDecoder = {}
local VarintDecoder_mt = { __index = VarintDecoder }
setmetatable( VarintDecoder, { __index = Base } ) -- make it inherit from Base



function VarintDecoder.new(pfield)
    local new_class = Base.new("VARINT", pfield)
    setmetatable( new_class, VarintDecoder_mt )
    return new_class
end


function VarintDecoder:decode(decoder, tag)
    dprint2("VarintDecoder:decode() called")
    return decoder:addFieldVarint64(self.pfield)
end


return VarintDecoder
