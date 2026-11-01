-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/truher/frc-can-dissector (ctre/motor_status2.lua),
-- commit 8394af09f43d36e81249bca02b0135b3c32d4e98 du 06/01/2023.
-- Licence amont : MIT (LICENSE amont) — voir README.md.
function currentA(x)
  return tostring(x) * 0.125
end

local M = {}

M.talon_current_h8_field = ProtoField.uint8("can.frc.ctre.talon.current_h8", "Talon Current_h8", base.DEC, nil, 0xff)
M.talon_current_l2_field = ProtoField.uint8("can.frc.ctre.talon.current_l2", "Talon Current_l2", base.DEC, nil, 0xc0)

function M.insert(t)
  table.insert(t, M.talon_current_h8_field)
  table.insert(t, M.talon_current_l2_field)

  M.talon_current_h8 = Field.new("can.frc.ctre.talon.current_h8")
  M.talon_current_l2 = Field.new("can.frc.ctre.talon.current_l2")
end

function M.dissect(buffer, pinfo, subtree)
  subtree:add(M.talon_current_h8_field, buffer:range(10,1))
  subtree:add(M.talon_current_l2_field, buffer:range(9,1))
  subtree:add("Talon Current (A):", currentA(bit.bor(bit.lshift(M.talon_current_h8()(), 2), M.talon_current_l2()())))
end

return M
