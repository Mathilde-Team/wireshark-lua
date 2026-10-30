-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/AverageJamz/ac-dissector (messages/msgToggleObjectVisibility.lua),
-- commit b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd du 16/03/2017.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

-- 0xF74B

fields.MsgToggleObjectVisibilityObject            = ProtoField.uint32("ac.msg.tog_obj_vis.obj", "ObjectID",  base.HEX)
fields.MsgToggleObjectVisibilityPortalType        = ProtoField.uint16("ac.msg.tog_obj_vis.portal_type", "Portal type",  base.HEX)
fields.MsgToggleObjectVisibilityLogins            = ProtoField.uint16("ac.msg.tog_obj_vis.logins", "Logins #")
fields.MsgToggleObjectVisibilityLoginPortals      = ProtoField.uint16("ac.msg.tog_obj_vis.login_portals", "Login portals #")

function msgToggleObjectVisibility(message, tree)
  tree = tree:add("Toggle object visibility")

  tree:add_le(fields.MsgToggleObjectVisibilityObject, message(4, 4))
  tree:add_le(fields.MsgToggleObjectVisibilityPortalType, message(8, 2))
  tree:add_le(fields.FieldUnknownWORD, message(10, 2))
  tree:add_le(fields.MsgToggleObjectVisibilityLogins, message(12, 2))
  tree:add_le(fields.MsgToggleObjectVisibilityLoginPortals, message(14, 2))
end