-- SPDX-License-Identifier: BSD-2-Clause OR GPL-3.0-only
-- Importé de https://github.com/Neopallium/lludp_dissector (init.lua),
-- commit 221e98da12cc3ce804330cb975c617f2bf1a480d du 12/09/2020.
-- Licence amont : BSD-2-Clause ou GPL-3.0 au choix (README amont) — voir README.md.

-- register http to handle tcp ports 8000-8010 and 9000
do
  local tcp_port_table = DissectorTable.get("tcp.port")
  local http_dissector = tcp_port_table:get_dissector(80)
  for port = 8000,8010 do
    tcp_port_table:add(port,http_dissector)
  end
  tcp_port_table:add(9000,http_dissector)
end

-- Load lludp protocol dissector.
require("lludp.dissector")
require("lludp.stats_tap")

