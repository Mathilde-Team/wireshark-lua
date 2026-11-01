-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/AverageJamz/ac-dissector (messages/msgRequestLogin.lua),
-- commit b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd du 16/03/2017.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

-- 0xF657

fields.MsgRequestLoginObjectId             = ProtoField.uint32("ac.msg.req_login.obj_id", "ObjectID",  base.HEX)
fields.MsgRequestLoginZoneName             = ProtoField.string("ac.msg.req_login.zone_name", "Zone name")

function msgRequestLogin(message, tree)
  tree = tree:add("Login request")

  local zone_name_len = message(8, 2):le_uint()
  tree:add_le(fields.MsgRequestLoginObjectId, message(4, 4))
  tree:add(fields.MsgRequestLoginZoneName, message(10, zone_name_len + calc_pad(zone_name_len+2, 4)))
end