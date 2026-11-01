-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/MISP/LuaMISP (sous-module `lib/LuaMISP` de
-- https://github.com/MISP/misp-wireshark, commit
-- be6d89df62503465d9b92e6839612111ea8fc068),
-- commit bd80c85bf22c5117b3946fd1b29ceb51fa26677e du 21/02/2022.
-- Licence amont : MIT (texte complet dans `LICENSE` de ce dossier) — voir README.md.

local LuaMISP = require 'LuaMISP'

local filepath = debug.getinfo(1).source:match("@?(.*)")
local f = assert(io.open(filepath, "rb"))
local bytes = f:read("*all")
local attribute_attachment = Attribute:new({type='attachment', value='filename', data=bytes})
assert(attribute_attachment.value == 'filename')

local event = Event:new({title='Test event from LuaMISP'})
assert(event.title == 'Test event from LuaMISP')
event:addTags({'tag1', 'tag2'})
assert(event.Tag[2].name == 'tag2') -- Table index start at 1 in Lua

local object = Object:new({type='domain-ip'})
assert(object.type == 'domain-ip')
local attribute_domain = Attribute:new({type='domain', value='google.com'})
local attribute_ip = Attribute:new({type='ip', value='8.8.8.8'})
object:addAttributes({attribute_domain, attribute_ip})
assert(object.Attribute[1].value == 'google.com')

object:addReference(attribute_attachment, 'test-reference')
assert(object.ObjectReference[1].relationship_type == 'test-reference')
assert(object.ObjectReference[1].object_uuid == object.uuid)
assert(object.ObjectReference[1].referenced_uuid == attribute_attachment.uuid)


event:addAttribute(attribute)
event:addObject(object)
local eventJson = event:toJson()
assert(type(eventJson) == 'string')
