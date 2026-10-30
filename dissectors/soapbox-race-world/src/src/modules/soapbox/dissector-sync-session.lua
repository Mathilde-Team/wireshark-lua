-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/nilzao/soapbox-race-dissector (src/modules/soapbox/dissector-sync-session.lua),
-- commit 728072f5fe1c5292efa6c29e9d368b3184d3289d du 04/02/2018.
-- Licence amont : GPL-3.0 (LICENSE amont, sans mention « or later ») — voir README.md.

function setSyncSessionFields(buf, pkt, subtree)
  setCountField(buf,pkt,subtree)
  local bytePosIni =  4 + getIniSrv2PBytePos(buf,pkt)
  setTimeField(buf,subtree,bytePosIni)
  local cli_cli_type = detectDirection(pkt)
  bytePosIni =  15 + getIniSrv2PBytePos(buf,pkt)
  subtree:add(f_sb_session_id, buf(bytePosIni,4))
  subtree:add(f_sb_static_ff, buf(buf:len()-5,1))
  pkt.cols.protocol = 'SB-SYNC-S'
  pkt.cols.info = 'Sync Session Protocol ['..cli_cli_type..']'
end
