-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/nilzao/soapbox-race-dissector (src/modules/soapbox/dissector-id.lua),
-- commit 728072f5fe1c5292efa6c29e9d368b3184d3289d du 04/02/2018.
-- Licence amont : GPL-3.0 (LICENSE amont, sans mention « or later ») — voir README.md.

function setIdFields(start, buf, pkt, subtree)
  local cli_cli_type = detectDirection(pkt)
  subtree:add(f_persona_name, buf(start + 3,32))
  if(cli_cli_type == 'cli->srv') then
    subtree:add(f_persona_id, buf(start +35,4))
  end
end
