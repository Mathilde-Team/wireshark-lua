-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/AverageJamz/ac-dissector (messages/msgLoginCharacter.lua),
-- commit b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd du 16/03/2017.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

-- 0xF746

fields.MsgLoginCharacterCharacter             = ProtoField.uint32("ac.msg.login_char_char", "ObjectID",  base.HEX)

function msgLoginCharacter(message, tree)
  tree = tree:add("Login character")

  tree:add_le(fields.MsgLoginCharacterCharacter, message(4, 4))
end