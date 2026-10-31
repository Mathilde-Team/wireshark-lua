-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/AverageJamz/ac-dissector (messages/msgCharacterLoginFailure.lua),
-- commit b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd du 16/03/2017.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

-- 0xF659

fields.MsgCharacterLoginFailureReason      = ProtoField.uint32("ac.msg.login_fail_reason", "Reason",  base.HEX)

function msgCharacterLoginFailure(message, tree)
  tree = tree:add("Character login failure")

  tree:add_le(fields.MsgCharacterLoginFailureReason, message(4, 4))
end