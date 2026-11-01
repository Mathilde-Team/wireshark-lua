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


local AstFactory    = require "ast.factory"
local StatementBase = require "ast.statement_base"


----------------------------------------
-- IgnoreStatement class, for "option" statements
--
local IgnoreStatement = {}
local IgnoreStatement_mt = { __index = IgnoreStatement }
setmetatable( IgnoreStatement, { __index = StatementBase } ) -- inherit from StatementBase
AstFactory:registerClass("EXTEND",     "IgnoreStatement", IgnoreStatement, true)
AstFactory:registerClass("EXTENSIONS", "IgnoreStatement", IgnoreStatement, true)
AstFactory:registerClass("RESERVED",   "IgnoreStatement", IgnoreStatement, true)
AstFactory:registerClass("SERVICE",    "IgnoreStatement", IgnoreStatement, true)


function IgnoreStatement.new(namespace, st)
    local new_class = StatementBase.new("IGNORE") -- the new instance
    setmetatable( new_class, IgnoreStatement_mt )
    return new_class
end


function IgnoreStatement:analyze()
end


return IgnoreStatement
