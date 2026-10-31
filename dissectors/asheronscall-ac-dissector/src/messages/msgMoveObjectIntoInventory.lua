-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/AverageJamz/ac-dissector (messages/msgMoveObjectIntoInventory.lua),
-- commit b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd du 16/03/2017.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

-- 0xF74A

fields.MsgMoveObjectIntoInventoryObject            = ProtoField.uint32("ac.msg.move_obj_to_inv.obj", "ObjectID",  base.HEX)

function msgMoveObjectIntoInventory(message, tree)
  tree = tree:add("Move object into inventory")

  tree:add_le(fields.MsgMoveObjectIntoInventoryObject, message(4, 4))
  tree:add_le(fields.FieldUnknownWORD, message(8, 2))
  tree:add_le(fields.FieldUnknownWORD, message(10, 2))
end