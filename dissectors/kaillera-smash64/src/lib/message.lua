-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/smash64-dev/kaillera-dissector (lib/message.lua),
-- commit 96e5fc77a1aa29510b24394144d0820541e85488 du 01/05/2021.
-- Licence amont : MIT (fichier LICENSE, « Copyright (c) 2021 Smash64 Development ») — voir README.md.

-- message.lua

local class = require "lib.middleclass"
local ArrayField = require "lib.arrayfield"
local Field = require "lib.field"
local Message = class("Message")

function Message:initialize(args)
    -- required arguments
    self.name = assert(args.name)
    self.fields = assert(args.fields)

    -- optional arguments
    self.isOrigin = args.isOrigin or nil
    self.protocol = args.protocol or "protocol"

    self.hierarchy = {}
end

function Message:dissect(protoFields, data, tree)
    self.data = data
    self.hierarchy.message = {data = self.data or nil, tree = tree}
    self.origin = "unknown"

    -- first byte is message type
    if data:len() > 1 and #(self.fields) > 0 then
        self:dissectSection(protoFields, data:range(1):tvb(), self.fields)
    end
end

function Message:dissectField(field, data)
    field:setData(data, self.hierarchy)
    if self.origin ~= "unknown" then return end

    if self.isOrigin then
        self.origin = self.isOrigin(field)
    else
        self.origin = "unknwon"
    end
end

function Message:dissectSection(protoFields, data, fields, section)
    local offset = 0
    section = section or "base"

    for index, field in ipairs(fields) do
        if field.class.name == ArrayField.name then
            field:setSize(self.hierarchy)

            if not field.invalid then
                for _ = 1, field.count do
                    offset = offset + self:dissectSection(protoFields, data:range(offset):tvb(), field.fields, field.name)
                end
            end
        elseif field.class.name == Field.name then
            self:dissectField(field, data:range(offset):tvb())
            local abbr = self:fieldAbbr(self.name, section, index)
            local subtree = field:addToTree(self.hierarchy, protoFields, abbr, self.origin)

            if not field.invalid then
                if field.refName ~= 0 then
                    self.hierarchy[field.refName] = {data = field.value, tree = subtree}
                end
                offset = offset + (field.treeOnly and 0 or field.value:len())
            end
        else
            self.hierarchy.message.tree:add(string.format("%s: [%s]", self.class.name, "Unknown field type"))
        end
    end

    return offset
end

function Message:fieldAbbr(name, section, index)
    local name_section = section == "base" and name or string.format("%s.%s", name, section)
    name_section = string.lower(name_section:gsub(" ", "_"))
    return string.format("%s.%s.%s", string.lower(self.protocol), name_section, index)
end

function Message:protoFields()
    local protoFields = {}

    for index, field in ipairs(self.fields) do
        if field.class.name == ArrayField.name then
            for aindex, afield in ipairs(field.fields) do
                local abbr = self:fieldAbbr(self.name, field.name, aindex)
                protoFields[abbr] = afield:protoField(abbr)
            end
        elseif field.class.name == Field.name then
            local abbr = self:fieldAbbr(self.name, "base", index)
            protoFields[abbr] = field:protoField(abbr)
        else
            print(string.format("%s: %s", self.class.name, "Unknown field type"))
        end
    end

    return protoFields
end

-- static methods
function Message.static:buildMessageTypes(object)
    local types = {}
    for id, message in pairs(object) do
        types[id] = message.name
    end
    return types
end

function Message.static:buildProtoFields(object, protocol)
    local protoFields = {}
    for _, message in pairs(object) do
        message.protocol = protocol

        for key, value in pairs(message:protoFields()) do
            protoFields[key] = value
        end
    end
    return protoFields
end

return Message
