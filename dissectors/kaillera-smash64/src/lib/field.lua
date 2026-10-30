-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/smash64-dev/kaillera-dissector (lib/field.lua),
-- commit 96e5fc77a1aa29510b24394144d0820541e85488 du 01/05/2021.
-- Licence amont : MIT (fichier LICENSE, « Copyright (c) 2021 Smash64 Development ») — voir README.md.

-- field.lua

local class = require "lib.middleclass"
local Field = class("Field")

function Field:initialize(args)
    -- required arguments
    self.args = assert(args)
    self.name = assert(args.name)
    self.type = assert(args.type)

    -- optional arguments for Message
    self.childOf = args.childOf or "message"
    self.client = args.client or 1
    self.hidden = args.hidden or 0
    self.refName = args.refName or 0
    self.server = args.server or 1
    self.size = args.size or nil
    self.sizeOf = args.sizeOf or nil

    -- optional arguments for ProtoField
    self.valuestring = args.valuestring or nil
    self.base = args.base or nil
    self.mask = args.mask or nil
    self.descr = args.descr or nil

    -- optional arguments for Tree
    self.encoding = args.encoding or nil
    self.treeOnly = args.treeOnly or nil

    self.invalid = false
    self.realSize = nil
    self.value = nil
end

-- TODO: add formatter, prefix, and suffix support
function Field:addToTree(trees, protoFields, name, origin)
    local parent = trees[self.childOf] and self.childOf or "message"

    if self.invalid then
        return trees[parent].tree:add(string.format("%s: [%s]", self.name, self.invalid))
    end

    if not self:isHidden(origin) and not self.invalid then
        local newtree = nil

        if self.treeOnly then
            newtree = trees[parent].tree:add(self.name)
        elseif self.encoding then
            newtree = trees[parent].tree:add_packet_field(protoFields[name], self.value, self.encoding)
        else
            newtree = trees[parent].tree:add_le(protoFields[name], self.value)
        end

        if newtree then return newtree end
    end

    return trees
end

function Field:isHidden(source)
    local hiddenClient = self.client == 0 and source == "client"
    local hiddenServer = self.server == 0 and source == "server"
    return self.hidden == 1 or hiddenClient or hiddenServer or false
end

function Field:protoField(abbr)
    return ProtoField.new(self.name, abbr, self.type, self.valuestring, self.base, self.mask, self.desc)
end

function Field:setData(data, trees)
    local size = self.size
    self.invalid = false

    -- handle sizeOf variable length
    if trees and self.sizeOf then
        size = self.size and self.size or trees[self.sizeOf].data:len()
        if size > data:len() then size = data:len() end
    end

    -- make sure the size is never more than the buffer
    if data:len() == 0 then self.invalid = "No space left for field data" end
    if (size or 0) > data:len() then self.invalid = "Not enough space for field data" end

    if self.invalid then
        self.realSize = data:len()
        self.value = ByteArray.new("00"):tvb("Invalid"):range()
    else
        self.realSize = (size ~= 0) and size or data:range():strsize()
        self.value = data:range(0, self.realSize)
    end
end

return Field
