-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/AverageJamz/ac-dissector (messages/msgWieldObject.lua),
-- commit b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd du 16/03/2017.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

-- 0xF749

fields.MsgWieldObjectOwner             = ProtoField.uint32("ac.msg.wield_obj.owner", "Owner",  base.HEX)
fields.MsgWieldObjectObject            = ProtoField.uint32("ac.msg.wield_obj.obj", "ObjectID",  base.HEX)

function msgWieldObject(message, tree)
  tree = tree:add("Wield object")

  tree:add_le(fields.MsgWieldObjectOwner, message(4, 4))
  tree:add_le(fields.MsgWieldObjectObject, message(8, 4))
  tree:add_le(fields.FieldUnknownDWORD, message(12, 4))
  tree:add_le(fields.FieldUnknownDWORD, message(16, 4))
  tree:add_le(fields.FieldUnknownDWORD, message(20, 4))
end