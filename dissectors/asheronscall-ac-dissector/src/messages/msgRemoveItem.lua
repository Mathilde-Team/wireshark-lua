-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/AverageJamz/ac-dissector (messages/msgRemoveItem.lua),
-- commit b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd du 16/03/2017.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

-- 0xF747

fields.MsgRemoveItemObject             = ProtoField.uint32("ac.msg.remove_item.obj_id", "ObjectID",  base.HEX)

function msgRemoveItem(message, tree)
  tree = tree:add("Remove item")

  tree:add_le(fields.MsgRemoveItemObject, message(4, 4))
  tree:add_le(fields.FieldUnknownDWORD, message(8, 4))
end