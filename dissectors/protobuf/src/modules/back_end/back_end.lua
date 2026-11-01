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
--[[

    This script is a Lua module (not stand-alone) for handling the "back-end"
    of the compiler. In this module's case, it coordinates/controls the
    creation of the Proto/ProtoField/Prefs for each Message "protocol", and
    generates run-time code to decode/dissect them; but the actual work is
    mostly performed in the AST nodes.

    This module follows the classic Lua module method of storing its public
    methods/functions in a table and passing back the table to the caller of
    this module file.

]]


-- prevent wireshark loading this file as a plugin
if not _G['protbuf_dissector'] then return end


local back_end = {}


function back_end:execute(global_ast)
    -- creates Protos, ProtoFields
    local proto_table = {}
    global_ast:createProtocols(proto_table)

    return proto_table
end

return back_end
