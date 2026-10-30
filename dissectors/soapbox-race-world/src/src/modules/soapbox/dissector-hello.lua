-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/nilzao/soapbox-race-dissector (src/modules/soapbox/dissector-hello.lua),
-- commit 728072f5fe1c5292efa6c29e9d368b3184d3289d du 04/02/2018.
-- Licence amont : GPL-3.0 (LICENSE amont, sans mention « or later ») — voir README.md.

function setHelloFields(buf, pkt, subtree)
  setCountField(buf,pkt,subtree)
  local cli_cli_type = detectDirection(pkt)
  if(cli_cli_type == 'srv->cli') then
    setTimeField(buf,subtree,4)
  end
  pkt.cols.protocol = 'SB-HELLO'
  pkt.cols.info = 'Hello Protocol ['..cli_cli_type..']'
end
