-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/AverageJamz/ac-dissector (messages/msgEnterPortalMode.lua),
-- commit b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd du 16/03/2017.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

-- 0xF751

fields.MsgEnterPortalModeSequence      = ProtoField.uint32("ac.msg.enter_portal_mode.seq", "Sequence")

function msgEnterPortalMode(message, tree)
  tree = tree:add("Enter portal mode")

  tree:add_le(fields.MsgEnterPortalModeSequence, message(4, 4))
end