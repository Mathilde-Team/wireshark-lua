-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/AverageJamz/ac-dissector (util.lua),
-- commit b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd du 16/03/2017.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

function calc_pad(length, multiple)
  local rem = length % 4

  if rem == 0 then 
    return 0
  else
    return (length + multiple - rem) - length
  end
end