-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/nilzao/soapbox-race-dissector (src/modules/soapbox/dissector-player.lua),
-- commit 728072f5fe1c5292efa6c29e9d368b3184d3289d du 04/02/2018.
-- Licence amont : GPL-3.0 (LICENSE amont, sans mention « or later ») — voir README.md.

function setPlayerFields(buf, pkt, subtree)
  local cli_cli_type = detectDirection(pkt)
  setPlayerField(buf, subtree)
  setPacketSizeField(buf,pkt,subtree)
  setCountField(buf,pkt,subtree)
  setBeforeHandShakeField(buf,pkt,subtree)
  setStaticFFp2pField(buf,pkt,subtree)
  if cli_cli_type == 'cli->srv' then
    setSubPackets(10,buf,pkt,subtree)
  else
    setSubPackets(8,buf,pkt,subtree)
  end
  pkt.cols.protocol = 'SB-PLAYER'
  pkt.cols.info = 'Player Protocol ['..cli_cli_type..']'
end
