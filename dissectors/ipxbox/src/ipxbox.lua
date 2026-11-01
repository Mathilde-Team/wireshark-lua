-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://github.com/fragglet/ipxbox (wireshark/ipxbox.lua),
-- commit 221f9f6ea1749942805d7bfeab1ab0b9bfae0683 du 14/09/2026.
-- Licence amont : GPL-2.0 (COPYING.md amont, sans mention « or later ») — voir README.md.

-- This file doesn't contain an actual dissector, it just hooks in the
-- ipxbox default UDP port to the Wireshark built-in IPX dissector.
-- You can get the same effect by using "Decode As..." within the UI.
local ipx_dissector = Dissector.get("ipx")
DissectorTable.get("udp.port"):add(10000, ipx_dissector)
