-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/AverageJamz/ac-dissector (GameEvents/evtMessageBox.lua),
-- commit b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd du 16/03/2017.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

-- 0x00000004

fields.EvtMessageBoxText        = ProtoField.string("ac.evt.msg_box.text", "Text")

function evtMessageBox(event, tree)
  tree:append_text(" (Message box)")

  local text_len = event(4, 2):le_uint()
  local text_pad = calc_pad(text_len + 2, 4)

  tree:add(fields.EvtMessageBoxText, event(6, text_len + text_pad))
end