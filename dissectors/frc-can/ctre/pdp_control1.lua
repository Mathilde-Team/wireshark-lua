-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/truher/frc-can-dissector (ctre/pdp_control1.lua),
-- commit 8394af09f43d36e81249bca02b0135b3c32d4e98 du 06/01/2023.
-- Licence amont : MIT (LICENSE amont) — voir README.md.
-- CTRE PDP CONTROL_1
local M = {}

M.clear_sticky_faults_field = ProtoField.bool("can.frc.ctre.pdp.clear_sticky_faults", "Clear Sticky Faults", 8, nil, 0x80)
M.reset_energy_field = ProtoField.bool("can.frc.ctre.pdp.reset_energy", "Reset Energy", 8, nil, 0x40)

function M.insert(t)
  table.insert(t, M.clear_sticky_faults_field)
  table.insert(t, M.reset_energy_field)
  M.clear_sticky_faults = Field.new("can.frc.ctre.pdp.clear_sticky_faults")
  M.reset_energy = Field.new("can.frc.ctre.pdp.reset_energy")
end

function M.dissect(buffer, pinfo, subtree)
  subtree:add(M.clear_sticky_faults_field, buffer(8, 1))
  subtree:add(M.reset_energy_field, buffer(8,1))
end

return M
